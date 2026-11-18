Class extends DataClass

//Emite una factura de cliente en UNA transacción: numera con el secuencial de la sucursal,
//graba cabecera y detalle, registra la SALIDA de inventario por línea y genera el asiento contable.
//$cab:    {empresaID; sucursalID; usuarioID; clientesID; formaPago; observacion}
//$lineas: colección de {inventarioID; cantidad; descuento}  (precio e IVA se toman de InventarioFicha)
exposed Function emitir($cab : Object; $lineas : Collection) : Object
	var $res; $l; $r; $mr; $ra : Object
	var $emp : cs.EmpresasEntity
	var $cli : cs.ClientesFichaEntity
	var $suc : cs.SucursalesEntity
	var $prod : cs.InventarioFichaEntity
	var $f : cs.ClientesFacturaPrincipalEntity
	var $d : cs.ClientesFacturaDetalleEntity
	var $asiento : Collection
	var $ctaCobro : Text
	var $sub; $desc; $iva; $costo; $lsub; $liva; $ldesc; $cant : Real

	$res:=New object("ok"; False; "mensaje"; "")
	If (($lineas=Null) || ($lineas.length=0))
		$res.mensaje:="La factura no tiene líneas."
		return $res
	End if
	$emp:=ds.Empresas.get(String($cab.empresaID))
	If ($emp=Null)
		$res.mensaje:="Empresa inválida."
		return $res
	End if
	$cli:=ds.ClientesFicha.get(Num($cab.clientesID))
	If (($cli=Null) || ($cli.EmpresaID#$emp.EmpresaID))
		$res.mensaje:="Seleccione un cliente válido."
		return $res
	End if

	START TRANSACTION

	$suc:=ds.Sucursales.get(Num($cab.sucursalID))
	If (($suc=Null) || ($suc.EmpresaID#$emp.EmpresaID))
		return Tx_Fallar($res; "Sucursal inválida."; [])
	End if
	If (Not(Tx_Bloquear($suc)))
		return Tx_Fallar($res; "No se pudo obtener el secuencial de la sucursal (en uso). Reintente."; [])
	End if

	$f:=ds.ClientesFacturaPrincipal.new()
	$f.EmpresaID:=$emp.EmpresaID
	$f.SucursalesID:=$suc.SucursalesID
	$f.UsuariosID:=Num($cab.usuarioID)
	$f.ClientesID:=$cli.ClientesID
	$f.FormaPago:=String($cab.formaPago)
	$f.Observacion:=String($cab.observacion)
	$f.Fecha:=Current date
	$f.Hora:=Current time
	$f.Estado:="EMITIDA"
	$f.Subtotal:=0
	$f.Descuento:=0
	$f.Impuesto:=0
	$f.Total:=0
	$suc.SecuencialFactura:=$suc.SecuencialFactura+1
	$f.Numero:=$suc.Establecimiento+"-"+$suc.PuntoEmision+"-"+String($suc.SecuencialFactura; "000000000")
	$r:=$f.save()
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo grabar la cabecera."; [$suc])
	End if

	For each ($l; $lineas)
		$cant:=Num($l.cantidad)
		$prod:=ds.InventarioFicha.get(Num($l.inventarioID))
		If (($prod=Null) || ($prod.EmpresaID#$emp.EmpresaID))
			return Tx_Fallar($res; "Producto inexistente."; [$suc])
		End if
		If ($cant<=0)
			return Tx_Fallar($res; "Cantidad inválida: "+$prod.Nombre; [$suc])
		End if

		$ldesc:=Round(Num($l.descuento); 2)
		$lsub:=Round(($cant*$prod.Precio)-$ldesc; 2)
		If (($ldesc<0) || ($lsub<0))
			return Tx_Fallar($res; "Descuento inválido: "+$prod.Nombre; [$suc])
		End if
		$liva:=Round($lsub*$prod.PorcentajeIVA/100; 2)

		$d:=ds.ClientesFacturaDetalle.new()
		$d.EmpresaID:=$emp.EmpresaID
		$d.ClientesFacturaID:=$f.ClientesFacturaID
		$d.InventarioID:=$prod.InventarioID
		$d.Cantidad:=$cant
		$d.PrecioUnitario:=$prod.Precio
		$d.Descuento:=$ldesc
		$d.PorcentajeIVA:=$prod.PorcentajeIVA
		$d.Subtotal:=$lsub
		$d.ValorIVA:=$liva
		$d.Total:=$lsub+$liva
		$r:=$d.save()
		If (Not($r.success))
			return Tx_Fallar($res; "Error al grabar el detalle."; [$suc])
		End if

		$mr:=ds.InventarioMovimientos.registrar(New object(\
		"empresaID"; $emp.EmpresaID; "sucursalID"; $suc.SucursalesID; "inventarioID"; $prod.InventarioID; \
		"fecha"; $f.Fecha; "tipo"; "SALIDA"; "cantidad"; $cant; \
		"tipoOrigen"; "CLIENTE"; "clientesID"; $cli.ClientesID; "clientesFacturaID"; $f.ClientesFacturaID))
		If (Not($mr.ok))
			return Tx_Fallar($res; $mr.mensaje; [$suc])
		End if

		$costo+=Round($cant*$mr.costoUnit; 2)
		$sub+=$lsub
		$desc+=$ldesc
		$iva+=$liva
	End for each

	$f.Subtotal:=Round($sub; 2)
	$f.Descuento:=Round($desc; 2)
	$f.Impuesto:=Round($iva; 2)
	$f.Total:=$f.Subtotal+$f.Impuesto

	//Asiento: Caja (o CxC si es a crédito) contra Ventas + IVA; y Costo de ventas contra Inventario
	$ctaCobro:=$emp.CtaCaja
	If ($f.FormaPago="CREDITO")
		$ctaCobro:=$emp.CtaCxC
	End if
	$asiento:=New collection
	$asiento.push(New object("cuenta"; $ctaCobro; "debito"; $f.Total; "credito"; 0; "referencia"; $f.Numero))
	$asiento.push(New object("cuenta"; $emp.CtaVentas; "debito"; 0; "credito"; $f.Subtotal; "referencia"; $f.Numero))
	$asiento.push(New object("cuenta"; $emp.CtaIVAVentas; "debito"; 0; "credito"; $f.Impuesto; "referencia"; $f.Numero))
	$asiento.push(New object("cuenta"; $emp.CtaCostoVentas; "debito"; $costo; "credito"; 0; "referencia"; $f.Numero))
	$asiento.push(New object("cuenta"; $emp.CtaInventario; "debito"; 0; "credito"; $costo; "referencia"; $f.Numero))
	$ra:=ds.ContabilidadPrincipal.registrar(New object("empresaID"; $emp.EmpresaID; "sucursalID"; $suc.SucursalesID; \
	"fecha"; $f.Fecha; "concepto"; "Factura "+$f.Numero+" - "+$cli.Nombre; "origen"; "FACTURA_CLIENTE"); $asiento)
	If (Not($ra.ok))
		return Tx_Fallar($res; "Asiento contable: "+$ra.mensaje; [$suc])
	End if
	$f.ContabilidadID:=$ra.id

	$r:=$f.save()
	If ($r.success)
		$r:=$suc.save()
	End if
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo finalizar la factura."; [$suc])
	End if
	$suc.unlock()

	VALIDATE TRANSACTION
	$res.ok:=True
	$res.numero:=$f.Numero
	$res.id:=$f.ClientesFacturaID
	return $res
