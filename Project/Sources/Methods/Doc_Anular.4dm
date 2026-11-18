//%attributes = {}
//Botón Anular de las listas de documentos: llama a <Tabla>Entity.anular()
var $r : Object

If (Form.actual=Null)
	ALERT("Seleccione un registro.")
	return
End if
If (Not(Seg_Permiso(Form.modulo; "anular")))
	ALERT("No tiene permiso para anular en este módulo.")
	return
End if
CONFIRM("¿Anular el documento seleccionado? Se revierten sus movimientos de inventario y su asiento contable."; "Anular"; "Cancelar")
If (OK=1)
	$r:=Form.actual.anular()
	If ($r.ok)
		ALERT("Documento anulado.")
	Else
		ALERT($r.mensaje)
	End if
	Maestro_Refrescar
End if
