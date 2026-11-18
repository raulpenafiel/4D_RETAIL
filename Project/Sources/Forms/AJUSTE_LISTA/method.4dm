Case of
	: (Form event code=On Load)
		Form.tabla:="InventarioAjustesPrincipal"
		Form.modulo:="AJUSTE"
		Form.campoBusqueda:="Motivo"
		Form.orden:="InventarioAjustesID desc"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("AJUSTE"; "crear"))
		OBJECT SET ENABLED(*; "bAnular"; Seg_Permiso("AJUSTE"; "anular"))
End case
