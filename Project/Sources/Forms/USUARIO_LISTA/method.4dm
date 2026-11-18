Case of
	: (Form event code=On Load)
		Form.tabla:="Usuarios"
		Form.modulo:="USUARIO"
		Form.campoBusqueda:="Nombres"
		Form.orden:="Nombres"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("USUARIO"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("USUARIO"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("USUARIO"; "editar"))
End case
