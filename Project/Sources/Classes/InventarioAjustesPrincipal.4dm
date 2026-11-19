Class extends DataClass

//Aplica un ajuste de inventario en UNA transacción: graba la cabecera, registra un movimiento
//por línea (las líneas del ajuste SON sus InventarioMovimientos) y genera el asiento contable.
//$cab:    {empresaID; sucursalID; usuarioID; fecha; motivo}
//$lineas: colección de {inventarioID; tipo (ENTRADA/SALIDA); cantidad}  (se valoran al costo promedio)
exposed Function registrar($cab : Object; $lineas : Collection) : Object
	var $res; $l; $r; $mr; $ra : Object
	var $emp : cs.EmpresasEntity
	var $par : cs.ParametrosContablesEntity
	var $suc : cs.SucursalesEntity
	var $a : cs.InventarioAjustesPrincipalEntity
	var $asiento : Collection
	var $valE; $valS : Real

	$res:=New object("ok"; False; "mensaje"; "")
	If (($lineas=Null) || ($lineas.length=0))
		$res.mensaje:="El ajuste no tiene líneas."
		return $res
	End if
	If (String($cab.motivo)="")
		$res.mensaje:="El motivo es obligatorio."
		return $res
	End if
	$emp:=ds.Empresas.get(String($cab.empresaID))
	$suc:=ds.Sucursales.get(Num($cab.sucursalID))
	If (($emp=Null) || ($suc=Null) || ($suc.EmpresaID#$emp.EmpresaID))
		$res.mensaje:="Empresa o sucursal inválida."
		return $res
	End if

	//Cuentas de los asientos automáticos (Parámetros del Sistema > Parámetros Contables)
	$par:=$emp.parametrosContables.first()
	If ($par=Null)
		$res.mensaje:="Configure los Parámetros Contables de la empresa (cuentas para asientos automáticos)."
		return $res
	End if

	START TRANSACTION

	$a:=ds.InventarioAjustesPrincipal.new()
	$a.EmpresaID:=$emp.EmpresaID
	$a.SucursalesID:=$suc.SucursalesID
	$a.UsuariosID:=Num($cab.usuarioID)
	$a.Fecha:=Date($cab.fecha)
	If ($a.Fecha=!00-00-00!)
		$a.Fecha:=Current date
	End if
	$a.Motivo:=Substring(String($cab.motivo); 1; 200)
	$a.Estado:="APLICADO"
	$r:=$a.save()
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo grabar el ajuste."; [])
	End if

	For each ($l; $lineas)
		If (Num($l.cantidad)<=0)
			return Tx_Fallar($res; "Hay líneas con cantidad inválida."; [])
		End if
		$mr:=ds.InventarioMovimientos.registrar(New object(\
		"empresaID"; $emp.EmpresaID; "sucursalID"; $suc.SucursalesID; "inventarioID"; $l.inventarioID; \
		"fecha"; $a.Fecha; "tipo"; String($l.tipo); "cantidad"; Num($l.cantidad); \
		"tipoOrigen"; "AJUSTE"; "inventarioAjustesID"; $a.InventarioAjustesID))
		If (Not($mr.ok))
			return Tx_Fallar($res; $mr.mensaje; [])
		End if
		If ($l.tipo="ENTRADA")
			$valE+=Round(Num($l.cantidad)*$mr.costoUnit; 2)
		Else
			$valS+=Round(Num($l.cantidad)*$mr.costoUnit; 2)
		End if
	End for each

	$asiento:=New collection
	If ($valE>0)
		$asiento.push(New object("cuenta"; $par.CtaInventario; "debito"; $valE; "credito"; 0; "referencia"; "Ajuste entrada"))
		$asiento.push(New object("cuenta"; $par.CtaAjusteInventario; "debito"; 0; "credito"; $valE; "referencia"; "Ajuste entrada"))
	End if
	If ($valS>0)
		$asiento.push(New object("cuenta"; $par.CtaAjusteInventario; "debito"; $valS; "credito"; 0; "referencia"; "Ajuste salida"))
		$asiento.push(New object("cuenta"; $par.CtaInventario; "debito"; 0; "credito"; $valS; "referencia"; "Ajuste salida"))
	End if
	If ($asiento.length>0)
		$ra:=ds.ContabilidadPrincipal.registrar(New object("empresaID"; $emp.EmpresaID; "sucursalID"; $suc.SucursalesID; \
		"fecha"; $a.Fecha; "concepto"; "Ajuste de inventario "+String($a.InventarioAjustesID)+" - "+$a.Motivo; "origen"; "AJUSTE"); $asiento)
		If (Not($ra.ok))
			return Tx_Fallar($res; "Asiento contable: "+$ra.mensaje; [])
		End if
		$a.ContabilidadID:=$ra.id
		$r:=$a.save()
		If (Not($r.success))
			return Tx_Fallar($res; "No se pudo finalizar el ajuste."; [])
		End if
	End if

	VALIDATE TRANSACTION
	$res.ok:=True
	$res.id:=$a.InventarioAjustesID
	$res.numero:=String($a.InventarioAjustesID)
	return $res
