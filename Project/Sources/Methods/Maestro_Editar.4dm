//%attributes = {}
//Abre el detalle del registro seleccionado
If (Form.actual=Null)
	ALERT("Seleccione un registro.")
	return
End if
If (Not(Seg_Permiso(Form.modulo; "editar")))
	ALERT("No tiene permiso para editar en este módulo.")
	return
End if
Maestro_Abrir(Form.actual)
