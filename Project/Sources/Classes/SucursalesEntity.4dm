Class extends Entity

Function validar() : Text
	If (This.Codigo="")
		return "El código es obligatorio."
	End if
	If (This.Nombre="")
		return "El nombre es obligatorio."
	End if
	If ((Length(This.Establecimiento)#3) || (Length(This.PuntoEmision)#3))
		return "Establecimiento y punto de emisión deben tener 3 dígitos (ej. 001)."
	End if
	If (Val_Existe(This; "Codigo"))
		return "Ya existe una sucursal con ese código."
	End if
	return ""
