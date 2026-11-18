Class extends Entity

Function validar() : Text
	This.NombreAcceso:=Lowercase(Trim(This.NombreAcceso))
	If (This.NombreAcceso="")
		return "El nombre de acceso es obligatorio (se entra como nombre@dominio)."
	End if
	If ((Position(" "; This.NombreAcceso)>0) || (Position("@"; This.NombreAcceso)>0) || (Position("\\"; This.NombreAcceso)>0))
		return "El nombre de acceso no puede tener espacios, '@' ni barra invertida (el dominio sale de la empresa)."
	End if
	If (This.Nombres="")
		return "Los nombres son obligatorios."
	End if
	If (Num(This.RolesID)=0)
		return "Seleccione un rol."
	End if
	If (Num(This.SucursalesID)=0)
		return "Seleccione una sucursal."
	End if
	If (Val_Existe(This; "NombreAcceso"))
		return "Ya existe ese nombre de acceso en la empresa."
	End if
	return Val_MismaEmpresa(This; ["sucursal"; "rol"])
