Case of
	: (Form event code=On Load)
		Form.tabla:="InventarioFicha"
		Form.modulo:="INVENTARIO"
		Form.campoBusqueda:="Nombre"
		Form.orden:="Nombre"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("INVENTARIO"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("INVENTARIO"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("INVENTARIO"; "editar"))
End case
