Case of
	: (Form event code=On Load)
		Form.tabla:="Sucursales"
		Form.modulo:="SUCURSAL"
		Form.campoBusqueda:="Nombre"
		Form.orden:="Nombre"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("SUCURSAL"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("SUCURSAL"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("SUCURSAL"; "editar"))
End case
