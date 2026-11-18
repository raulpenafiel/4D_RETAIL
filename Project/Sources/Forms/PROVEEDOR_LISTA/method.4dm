Case of
	: (Form event code=On Load)
		Form.tabla:="ProveedoresFicha"
		Form.modulo:="PROVEEDOR"
		Form.campoBusqueda:="Nombre"
		Form.orden:="Nombre"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("PROVEEDOR"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("PROVEEDOR"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("PROVEEDOR"; "editar"))
End case
