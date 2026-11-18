Case of
	: (Form event code=On Load)
		Form.tabla:="InventarioMovimientos"
		Form.modulo:="KARDEX"
		Form.campoBusqueda:="inventario.Nombre"
		Form.orden:="InventarioMovimientosID desc"
		Form.texto:=""
		Maestro_Refrescar
End case
