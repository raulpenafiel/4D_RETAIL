Case of
	: (Form event code=On Load)
		Form.tabla:="Empresas"
		Form.modulo:="EMPRESA"
		Form.campoBusqueda:="RazonSocial"
		Form.orden:="RazonSocial"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("EMPRESA"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("EMPRESA"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("EMPRESA"; "editar"))
End case
