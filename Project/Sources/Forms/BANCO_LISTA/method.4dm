Case of
	: (Form event code=On Load)
		Form.tabla:="FichaBancos"
		Form.modulo:="BANCO"
		Form.campoBusqueda:="Banco"
		Form.orden:="Banco"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("BANCO"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("BANCO"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("BANCO"; "editar"))
End case
