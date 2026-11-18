Class extends Entity

//Anula la factura: devuelve el stock (ENTRADA marcada como anulación por cada SALIDA original)
//y anula su asiento contable, en una transacción. El permiso se valida en el cliente con Seg_Permiso.
exposed Function anular() : Object
	var $res; $r; $mr : Object
	var $mov : cs.InventarioMovimientosEntity

	$res:=New object("ok"; False; "mensaje"; "")
	If (This.Estado#"EMITIDA")
		$res.mensaje:="Solo se pueden anular facturas emitidas."
		return $res
	End if

	START TRANSACTION
	For each ($mov; This.movimientos.query("Anulacion = :1"; False))
		$mr:=ds.InventarioMovimientos.registrar(New object(\
		"empresaID"; This.EmpresaID; "sucursalID"; $mov.SucursalesID; "inventarioID"; $mov.InventarioID; \
		"fecha"; Current date; "tipo"; "ENTRADA"; "cantidad"; $mov.Cantidad; "costoUnit"; $mov.CostoUnit; \
		"tipoOrigen"; "CLIENTE"; "clientesID"; This.ClientesID; "clientesFacturaID"; This.ClientesFacturaID; "anulacion"; True))
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
		return Tx_Fallar($res; "No se pudo anular la factura."; [])
	End if
	VALIDATE TRANSACTION
	$res.ok:=True
	return $res
