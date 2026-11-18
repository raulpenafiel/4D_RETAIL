Class extends Entity

Function validar() : Text
	If (This.Codigo="")
		return "El código es obligatorio."
	End if
	If (This.TipoIdentificacion="")
		return "Seleccione el tipo de identificación."
	End if
	If (This.Identificacion="")
		return "La identificación es obligatoria."
	End if
	If ((This.TipoIdentificacion="CI") && (Length(This.Identificacion)#10))
		return "La cédula debe tener 10 dígitos."
	End if
	If ((This.TipoIdentificacion="RU") && (Length(This.Identificacion)#13))
		return "El RUC debe tener 13 dígitos."
	End if
	If (This.Nombre="")
		return "El nombre es obligatorio."
	End if
	If (Val_Existe(This; "Codigo"))
		return "Ya existe un cliente con ese código."
	End if
	If (Val_Existe(This; "Identificacion"))
		return "Ya existe un cliente con esa identificación."
	End if
	return ""
