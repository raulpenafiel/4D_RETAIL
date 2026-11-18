//Diálogo de acceso. Form: {acceso; clave; mensaje; soloClave}
//soloClave=True oculta el usuario (se usa en Seg_Bootstrap para pedir la clave del administrador)
Case of
	: (Form event code=On Load)
		If (Bool(Form.soloClave))
			OBJECT SET VISIBLE(*; "lAcceso"; False)
			OBJECT SET VISIBLE(*; "iAcceso"; False)
			GOTO OBJECT(*; "iClave")
		Else
			GOTO OBJECT(*; "iAcceso")
		End if
End case
