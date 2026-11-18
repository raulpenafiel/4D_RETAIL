Case of
	: (Form event code=On Load)
		Form.tabla:="ClientesFicha"
		Form.modulo:="CLIENTE"
		Form.campoBusqueda:="Nombre"
		Form.orden:="Nombre"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("CLIENTE"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("CLIENTE"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("CLIENTE"; "editar"))
End case
