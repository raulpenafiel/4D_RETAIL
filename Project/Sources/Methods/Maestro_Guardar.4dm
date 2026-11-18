//%attributes = {}
//Botón Guardar de los *_DETALLE de maestros: valida con <Tabla>Entity.validar() y guarda
var $msg : Text
var $r : Object

//Usuarios: la clave se revisa antes de validar() y el hash se asigna solo si todo es válido
If (Form.tabla="Usuarios")
	If (Form.claveNueva#"")
		If ((Length(Form.claveNueva)<6) || (Form.claveNueva#Trim(Form.claveNueva)))
			ALERT("La clave debe tener al menos 6 caracteres y no empezar ni terminar con espacios.")
			return
		End if
		If (Form.claveNueva#Form.claveConfirmar)
			ALERT("La clave y su confirmación no coinciden.")
			return
		End if
	Else
		If (Form.entidad.ClaveHash="")
			ALERT("La clave es obligatoria: sin clave el usuario no puede iniciar sesión.")
			return
		End if
	End if
End if

$msg:=Form.entidad.validar()
If ($msg#"")
	ALERT($msg)
	return
End if

If ((Form.tabla="Usuarios") && (Form.claveNueva#""))
	Form.entidad.ClaveHash:=Generate password hash(Form.claveNueva)
End if

If (Form.tabla="Roles")
	$r:=Form.entidad.guardarConAccesos(Form.accesos)
Else
	$r:=Form.entidad.save()
End if
If ($r.success)
	ACCEPT
Else
	ALERT("No se pudo guardar: "+String($r.statusText))
End if
