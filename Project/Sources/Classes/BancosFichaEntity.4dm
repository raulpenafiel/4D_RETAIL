Class extends Entity

Function validar() : Text
	If (This.Banco="")
		return "El banco es obligatorio."
	End if
	If (This.NumeroCuenta="")
		return "El número de cuenta es obligatorio."
	End if
	If (Not(["AHORROS"; "CORRIENTE"].includes(This.Tipo)))
		return "Seleccione el tipo de cuenta."
	End if
	If (Length(This.Moneda)#3)
		return "La moneda debe ser un código ISO de 3 letras (ej. USD)."
	End if
	If (Val_Existe(This; "NumeroCuenta"))
		return "Ya existe una cuenta con ese número."
	End if
	return ""
