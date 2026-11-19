Class extends DataClass

//Registra un asiento (cabecera + detalle) en una transacción. Regla: suma Debe = suma Haber.
//Lo usan los asientos manuales y, dentro de su propia transacción, facturas, compras y ajustes.
//$cab:    {empresaID; sucursalID; fecha; concepto; origen (MANUAL/FACTURA_CLIENTE/FACTURA_PROVEEDOR/AJUSTE)}
//$lineas: colección de {cuenta; debito; credito; referencia}  (las líneas en cero se omiten)
exposed Function registrar($cab : Object; $lineas : Collection) : Object
	var $res; $l; $r : Object
	var $validas : Collection
	var $emp : cs.EmpresasEntity
	var $a : cs.ContabilidadPrincipalEntity
	var $d : cs.ContabilidadDetalleEntity
	var $deb; $cre; $tDeb; $tCre : Real
	var $msg : Text

	$res:=New object("ok"; False; "mensaje"; "")
	If (String($cab.concepto)="")
		$res.mensaje:="El concepto es obligatorio."
		return $res
	End if

	$validas:=New collection
	If ($lineas#Null)
		For each ($l; $lineas)
			$deb:=Round(Num($l.debito); 2)
			$cre:=Round(Num($l.credito); 2)
			Case of
				: (($deb=0) && ($cre=0))
					//línea en cero: se omite
				: (($deb<0) || ($cre<0) || (($deb#0) && ($cre#0)))
					$res.mensaje:="Cada línea debe tener un valor positivo solo en Debe o solo en Haber."
					return $res
				: (String($l.cuenta)="")
					$res.mensaje:="Hay líneas sin cuenta contable. Revise las cuentas en Parámetros del Sistema > Parámetros Contables."
					return $res
				Else
					$validas.push(New object("cuenta"; String($l.cuenta); "debito"; $deb; "credito"; $cre; "referencia"; String($l.referencia)))
					$tDeb+=$deb
					$tCre+=$cre
			End case
		End for each
	End if
	If ($validas.length<2)
		$res.mensaje:="El asiento necesita al menos dos líneas con valor."
		return $res
	End if
	If (Round($tDeb-$tCre; 2)#0)
		$res.mensaje:="El asiento no cuadra: Debe "+String($tDeb)+" / Haber "+String($tCre)+"."
		return $res
	End if

	//Cada cuenta debe existir en el plan de cuentas de la empresa, activa y de movimiento
	For each ($l; $validas)
		$msg:=Cta_Validar(String($cab.empresaID); $l.cuenta)
		If ($msg#"")
			$res.mensaje:=$msg
			If (String($cab.origen)#"MANUAL")
				$res.mensaje:=$msg+" Revise Parámetros del Sistema > Parámetros Contables."
			End if
			return $res
		End if
	End for each

	START TRANSACTION

	$emp:=ds.Empresas.get(String($cab.empresaID))
	If ($emp=Null)
		return Tx_Fallar($res; "Empresa inválida."; [])
	End if
	If (Not(Tx_Bloquear($emp)))
		return Tx_Fallar($res; "No se pudo numerar el asiento (empresa en uso). Reintente."; [])
	End if
	$emp.SecuencialAsiento:=$emp.SecuencialAsiento+1

	$a:=ds.ContabilidadPrincipal.new()
	$a.EmpresaID:=$emp.EmpresaID
	$a.SucursalesID:=Num($cab.sucursalID)
	$a.Fecha:=Date($cab.fecha)
	If ($a.Fecha=!00-00-00!)
		$a.Fecha:=Current date
	End if
	$a.Numero:=$emp.SecuencialAsiento
	$a.Concepto:=Substring(String($cab.concepto); 1; 200)
	$a.Origen:=String($cab.origen)
	$a.Estado:="REGISTRADO"
	$r:=$a.save()
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo grabar la cabecera del asiento."; [$emp])
	End if

	For each ($l; $validas)
		$d:=ds.ContabilidadDetalle.new()
		$d.EmpresaID:=$emp.EmpresaID
		$d.ContabilidadID:=$a.ContabilidadID
		$d.Cuenta:=$l.cuenta
		$d.Debito:=$l.debito
		$d.Credito:=$l.credito
		$d.Referencia:=Substring($l.referencia; 1; 100)
		$r:=$d.save()
		If (Not($r.success))
			return Tx_Fallar($res; "No se pudo grabar el detalle del asiento."; [$emp])
		End if
	End for each

	$r:=$emp.save()
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo actualizar el secuencial de asientos."; [$emp])
	End if
	$emp.unlock()

	VALIDATE TRANSACTION
	$res.ok:=True
	$res.id:=$a.ContabilidadID
	$res.numero:=$a.Numero
	return $res
