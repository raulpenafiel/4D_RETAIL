//%attributes = {}
var $r : Object
If (Form.actual=Null)
	ALERT("Seleccione un registro.")
	return
End if
If (Not(Seg_Permiso(Form.modulo; "editar")))
	ALERT("No tiene permiso.")
	return
End if
CONFIRM("¿Cambiar el estado (activo/inactivo) del registro seleccionado?"; "Sí"; "No")
If (OK=1)
	Form.actual.Activo:=Not(Form.actual.Activo)
	$r:=Form.actual.save()
	If (Not($r.success))
		ALERT($r.statusText)
	End if
	Maestro_Refrescar
End if
