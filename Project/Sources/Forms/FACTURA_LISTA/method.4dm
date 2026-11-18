Case of
	: (Form event code=On Load)
		Form.tabla:="ClientesFacturaPrincipal"
		Form.modulo:="FACTURA"
		Form.campoBusqueda:="Numero"
		Form.orden:="ClientesFacturaID desc"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("FACTURA"; "crear"))
		OBJECT SET ENABLED(*; "bAnular"; Seg_Permiso("FACTURA"; "anular"))
End case
