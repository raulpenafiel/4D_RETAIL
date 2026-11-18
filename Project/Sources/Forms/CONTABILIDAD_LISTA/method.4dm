Case of
	: (Form event code=On Load)
		Form.tabla:="ContabilidadPrincipal"
		Form.modulo:="CONTABILIDAD"
		Form.campoBusqueda:="Concepto"
		Form.orden:="Numero desc"
		Form.texto:=""
		Maestro_Refrescar
		OBJECT SET ENABLED(*; "bNuevo"; Seg_Permiso("CONTABILIDAD"; "crear"))
		OBJECT SET ENABLED(*; "bAnular"; Seg_Permiso("CONTABILIDAD"; "anular"))
End case
