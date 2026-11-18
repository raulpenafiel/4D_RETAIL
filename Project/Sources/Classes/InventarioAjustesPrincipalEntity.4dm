Class extends Entity

//Anula el ajuste: registra el movimiento contrario de cada línea (marcado como anulación)
//y anula su asiento, en una transacción.
exposed Function anular() : Object
	var $res; $r; $mr : Object
	var $mov : cs.InventarioMovimientosEntity
	var $tipo : Text

	$res:=New object("ok"; False; "mensaje"; "")
	If (This.Estado#"APLICADO")
		$res.mensaje:="Solo se pueden anular ajustes aplicados."
		return $res
	End if

	START TRANSACTION
	For each ($mov; This.movimientos.query("Anulacion = :1"; False))
		$tipo:="ENTRADA"
		If ($mov.Tipo="ENTRADA")
			$tipo:="SALIDA"
		End if
		$mr:=ds.InventarioMovimientos.registrar(New object(\
		"empresaID"; This.EmpresaID; "sucursalID"; $mov.SucursalesID; "inventarioID"; $mov.InventarioID; \
		"fecha"; Current date; "tipo"; $tipo; "cantidad"; $mov.Cantidad; "costoUnit"; $mov.CostoUnit; \
		"tipoOrigen"; "AJUSTE"; "inventarioAjustesID"; This.InventarioAjustesID; "anulacion"; True))
		If (Not($mr.ok))
			return Tx_Fallar($res; $mr.mensaje; [])
		End if
	End for each
	If (This.asiento#Null)
		$r:=This.asiento.marcarAnulado()
		If (Not($r.success))
			return Tx_Fallar($res; "No se pudo anular el asiento contable."; [])
		End if
	End if
	This.Estado:="ANULADO"
	$r:=This.save()
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo anular el ajuste."; [])
	End if
	VALIDATE TRANSACTION
	$res.ok:=True
	return $res
