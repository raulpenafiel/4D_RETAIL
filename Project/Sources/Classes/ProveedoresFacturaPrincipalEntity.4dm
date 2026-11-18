Class extends Entity

//Anula la compra: retira el stock (SALIDA marcada como anulación por cada ENTRADA original)
//y anula su asiento contable, en una transacción. El costo promedio no se recalcula.
exposed Function anular() : Object
	var $res; $r; $mr : Object
	var $mov : cs.InventarioMovimientosEntity

	$res:=New object("ok"; False; "mensaje"; "")
	If (This.Estado#"REGISTRADA")
		$res.mensaje:="Solo se pueden anular compras registradas."
		return $res
	End if

	START TRANSACTION
	For each ($mov; This.movimientos.query("Anulacion = :1"; False))
		$mr:=ds.InventarioMovimientos.registrar(New object(\
		"empresaID"; This.EmpresaID; "sucursalID"; $mov.SucursalesID; "inventarioID"; $mov.InventarioID; \
		"fecha"; Current date; "tipo"; "SALIDA"; "cantidad"; $mov.Cantidad; "costoUnit"; $mov.CostoUnit; \
		"tipoOrigen"; "PROVEEDOR"; "proveedoresID"; This.ProveedoresID; "proveedoresFacturaID"; This.ProveedoresFacturaID; "anulacion"; True))
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
	This.Estado:="ANULADA"
	$r:=This.save()
	If (Not($r.success))
		return Tx_Fallar($res; "No se pudo anular la compra."; [])
	End if
	VALIDATE TRANSACTION
	$res.ok:=True
	return $res
