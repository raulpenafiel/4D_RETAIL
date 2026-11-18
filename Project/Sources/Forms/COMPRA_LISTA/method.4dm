Case of
	: (Form event code=On Load)
		Form.tabla:="ProveedoresFacturaPrincipal"
		Form.modulo:="COMPRA"
		Form.campoBusqueda:="Numero"
		Form.orden:="ProveedoresFacturaID desc"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("COMPRA"; "crear"))
		OBJECT SET ENABLED(*; "bAnular"; Seg_Permiso("COMPRA"; "anular"))
End case
