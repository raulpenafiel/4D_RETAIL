Class extends Entity

Function validar() : Text
	If (This.EmpresaID="")
		return "El código de empresa (EmpresaID) es obligatorio."
	End if
	If ((Length(This.EmpresaID)>5) || (Position(" "; This.EmpresaID)>0))
		return "El código de empresa admite máximo 5 caracteres, sin espacios."
	End if
	If ((This.getStamp()=0) && (ds.Empresas.get(This.EmpresaID)#Null))
		return "Ya existe una empresa con ese código."
	End if
	If (This.RUC="")
		return "El RUC es obligatorio."
	End if
	If (This.RazonSocial="")
		return "La razón social es obligatoria."
	End if
	This.Dominio:=Lowercase(Trim(This.Dominio))
	If (This.Dominio="")
		return "El dominio es obligatorio (los usuarios entran como usuario@dominio)."
	End if
	If ((Position(" "; This.Dominio)>0) || (Position("@"; This.Dominio)>0) || (Position("\\"; This.Dominio)>0))
		return "El dominio no puede tener espacios, '@' ni barra invertida."
	End if
	If (Val_Existe(This; "Dominio"))
		return "Ya existe otra empresa con ese dominio."
	End if
	If (Val_Existe(This; "RUC"))
		return "Ya existe otra empresa con ese RUC."
	End if
	return ""
