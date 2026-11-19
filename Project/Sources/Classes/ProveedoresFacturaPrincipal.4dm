Class extends DataClass

//Registra una compra (factura de proveedor) en UNA transacción: graba cabecera y detalle,
//registra la ENTRADA de inventario por línea (actualiza costo promedio) y genera el asiento contable.
//$cab:    {empresaID; sucursalID; usuarioID; proveedoresID; numero; fecha; formaPago; observacion}
//$lineas: colección de {inventarioID; cantidad; costo; descuento}  (el IVA se toma de InventarioFicha)
exposed Function registrar($cab : Object; $lineas : Collection) : Object
	var $res; $l; $r; $mr; $ra : Object
	var $emp : cs.EmpresasEntity
	var $par : cs.ParametrosContablesEntity
	var $prov : cs.ProveedoresFichaEntity
	var $suc : cs.SucursalesEntity
	var $prod : cs.InventarioFichaEntity
	var $f : cs.ProveedoresFacturaPrincipalEntity
	var $d : cs.ProveedoresFacturaDetalleEntity
	var $asiento : Collection
	var $ctaPago : Text
	var $sub; $desc; $iva; $lsub; $liva; $ldesc; $cant; $costo : Real

	$res:=New object("ok"; False; "mensaje"; "")
	If (($lineas=Null) || ($lineas.length=0))
		$res.mensaje:="La compra no tiene líneas."
		return $res
	End if
	If (String($cab.numero)="")
		$res.mensaje:="El número de factura del proveedor es obligatorio."
		return $res
	End if
	$emp:=ds.Empresas.get(String($cab.empresaID))
	$suc:=ds.Sucursales.get(Num($cab.sucursalID))
	If (($emp=Null) || ($suc=Null) || ($suc.EmpresaID#$emp.EmpresaID))
		$res.mensaje:="Empresa o sucursal inválida."
		return $res
	End if
	$prov:=ds.ProveedoresFicha.get(Num($cab.proveedoresID))
	If (($prov=Null) || ($prov.EmpresaID#$emp.EmpresaID))
		$res.mensaje:="Seleccione un proveedor válido."
		return $res
	End if
	If (ds.ProveedoresFacturaPrincipal.query("ProveedoresID = :1 AND Numero = :2 AND Estado # :3"; $prov.ProveedoresID; String($cab.numero); "ANULADA").length>0)
		$res.mensaje:="La factura "+String($cab.numero)+" de este proveedor ya está registrada."
		return $res
	End if

	//Cuentas de los asientos automáticos (Parámetros del Sistema > Parámetros Contables)
	$par:=$emp.parametrosContables.first()
	If ($par=Null)
		$res.mensaje:="Configure los Parámetros Contables de la empresa (cuentas para asientos automáticos)."
		return $res
	End if

	START TRANSACTION

	$f:=ds.ProveedoresFacturaPrincipal.new()
	$f.EmpresaID:=$emp.EmpresaID
	$f.SucursalesID:=$suc.SucursalesID
	$f.UsuariosID:=Num($cab.usuarioID)
	$f.ProveedoresID:=$prov.ProveedoresID
	$f.Numero:=String($cab.numero)
	$f.Fecha:=Date($cab.fecha)
	If ($f.Fecha=!00-00-00!)
		$f.Fecha:=Current date
	End if
	$f.FormaPago:=String($cab.formaPago)
	$f.Observacion:=String($cab.observacion)
	$f.Estado:="REGISTRADA"
	$f.Subtotal:=0
	$f.Descuento:=0
	$f.Impuesto:=0
	$f.Total:=0
	$r:=$f.save()
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo grabar la cabecera."; [])
	End if

	For each ($l; $lineas)
		$cant:=Num($l.cantidad)
		$costo:=Num($l.costo)
		$prod:=ds.InventarioFicha.get(Num($l.inventarioID))
		If (($prod=Null) || ($prod.EmpresaID#$emp.EmpresaID))
			return Tx_Fallar($res; "Producto inexistente."; [])
		End if
		If (($cant<=0) || ($costo<0))
			return Tx_Fallar($res; "Cantidad o costo inválido: "+$prod.Nombre; [])
		End if

		$ldesc:=Round(Num($l.descuento); 2)
		$lsub:=Round(($cant*$costo)-$ldesc; 2)
		If (($ldesc<0) || ($lsub<0))
			return Tx_Fallar($res; "Descuento inválido: "+$prod.Nombre; [])
		End if
		$liva:=Round($lsub*$prod.PorcentajeIVA/100; 2)

		$d:=ds.ProveedoresFacturaDetalle.new()
		$d.EmpresaID:=$emp.EmpresaID
		$d.ProveedoresFacturaID:=$f.ProveedoresFacturaID
		$d.InventarioID:=$prod.InventarioID
		$d.Cantidad:=$cant
		$d.CostoUnitario:=$costo
		$d.Descuento:=$ldesc
		$d.PorcentajeIVA:=$prod.PorcentajeIVA
		$d.Subtotal:=$lsub
		$d.ValorIVA:=$liva
		$d.Total:=$lsub+$liva
		$r:=$d.save()
		If (Not($r.success))
			return Tx_Fallar($res; "Error al grabar el detalle."; [])
		End if

		//costo unitario neto de descuento
		$mr:=ds.InventarioMovimientos.registrar(New object(\
		"empresaID"; $emp.EmpresaID; "sucursalID"; $suc.SucursalesID; "inventarioID"; $prod.InventarioID; \
		"fecha"; $f.Fecha; "tipo"; "ENTRADA"; "cantidad"; $cant; "costoUnit"; Round($lsub/$cant; 4); \
		"tipoOrigen"; "PROVEEDOR"; "proveedoresID"; $prov.ProveedoresID; "proveedoresFacturaID"; $f.ProveedoresFacturaID))
		If (Not($mr.ok))
			return Tx_Fallar($res; $mr.mensaje; [])
		End if

		$sub+=$lsub
		$desc+=$ldesc
		$iva+=$liva
	End for each

	$f.Subtotal:=Round($sub; 2)
	$f.Descuento:=Round($desc; 2)
	$f.Impuesto:=Round($iva; 2)
	$f.Total:=$f.Subtotal+$f.Impuesto

	//Asiento: Inventario + IVA compras contra Caja (o CxP si es a crédito)
	$ctaPago:=$par.CtaCaja
	If ($f.FormaPago="CREDITO")
		$ctaPago:=$par.CtaCxP
	End if
	$asiento:=New collection
	$asiento.push(New object("cuenta"; $par.CtaInventario; "debito"; $f.Subtotal; "credito"; 0; "referencia"; $f.Numero))
	$asiento.push(New object("cuenta"; $par.CtaIVACompras; "debito"; $f.Impuesto; "credito"; 0; "referencia"; $f.Numero))
	$asiento.push(New object("cuenta"; $ctaPago; "debito"; 0; "credito"; $f.Total; "referencia"; $f.Numero))
	$ra:=ds.ContabilidadPrincipal.registrar(New object("empresaID"; $emp.EmpresaID; "sucursalID"; $suc.SucursalesID; \
	"fecha"; $f.Fecha; "concepto"; "Compra "+$f.Numero+" - "+$prov.Nombre; "origen"; "FACTURA_PROVEEDOR"); $asiento)
	If (Not($ra.ok))
		return Tx_Fallar($res; "Asiento contable: "+$ra.mensaje; [])
	End if
	$f.ContabilidadID:=$ra.id

	$r:=$f.save()
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo finalizar la compra."; [])
	End if

	VALIDATE TRANSACTION
	$res.ok:=True
	$res.numero:=$f.Numero
	$res.id:=$f.ProveedoresFacturaID
	return $res
