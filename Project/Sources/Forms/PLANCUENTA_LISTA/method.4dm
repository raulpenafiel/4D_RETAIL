Case of
	: (Form event code=On Load)
		Form.tabla:="PlanCuentas"
		Form.modulo:="PLANCUENTA"
		Form.campoBusqueda:="Nombre"
		Form.orden:="Codigo"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("PLANCUENTA"; "crear"))
		OBJECT SET ENABLED(*; "bEditar"; Seg_Permiso("PLANCUENTA"; "editar"))
		OBJECT SET ENABLED(*; "bEstado"; Seg_Permiso("PLANCUENTA"; "editar"))
End case
