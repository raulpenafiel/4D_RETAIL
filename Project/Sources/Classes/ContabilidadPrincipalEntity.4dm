Class extends Entity

//Anula un asiento MANUAL. Los asientos automáticos se anulan desde su documento de origen.
exposed Function anular() : Object
	var $res; $r : Object

	$res:=New object("ok"; False; "mensaje"; "")
	If (This.Origen#"MANUAL")
		$res.mensaje:="Este asiento se generó desde un documento ("+This.Origen+"): anule el documento de origen."
		return $res
	End if
	If (This.Estado#"REGISTRADO")
		$res.mensaje:="El asiento ya está anulado."
		return $res
	End if
	$r:=This.marcarAnulado()
	$res.ok:=$r.success
	If (Not($r.success))
		$res.mensaje:="No se pudo anular el asiento."
	End if
	return $res

//Marca el asiento como ANULADO (se llama dentro de la transacción del documento de origen)
Function marcarAnulado() : Object
	This.Estado:="ANULADO"
	return This.save()
