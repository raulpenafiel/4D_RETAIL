Case of
	: (Form event code=On Load)
		Form.tabla:="Roles"
		Form.modulo:="ROL"
		Form.campoBusqueda:="Nombre"
		Form.orden:="Nombre"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("ROL"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("ROL"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("ROL"; "editar"))
End case
