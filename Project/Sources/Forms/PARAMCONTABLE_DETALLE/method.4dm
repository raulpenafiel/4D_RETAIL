//Parámetros contables de la empresa de la sesión (un registro por empresa).
//Pestañas: 1 Estructura de Cuentas (máscara y grupos principales), 2 Cuentas Contables (Cta*).
var $c : Object

Case of
	: (Form event code=On Load)
		Form.tabla:="ParametrosContables"
		Form.modulo:="PARAMCONTABLE"
		Form.entidad:=ds.ParametrosContables.query("EmpresaID = :1"; <>Usuario.empresaID).first()
		If (Form.entidad=Null)
			Form.entidad:=ds.ParametrosContables.new()
			Form.entidad.EmpresaID:=<>Usuario.empresaID
			Form.entidad.Mascara:="9.9.99.999"
			Form.entidad.GrupoActivo:=1
			Form.entidad.GrupoPasivo:=2
			Form.entidad.GrupoPatrimonio:=3
			Form.entidad.GrupoIngresos:=4
			Form.entidad.GrupoCostos:=5
			Form.entidad.GrupoGastos:=6
			//Las cuentas quedan vacías (no Null): se completan en la pestaña Cuentas Contables
			For each ($c; Form.entidad.cuentas())
				Form.entidad[$c.campo]:=""
			End for each
		End if
		Param_Refrescar
		If (Not(Seg_Permiso("PARAMCONTABLE"; "editar")))
			OBJECT SET ENABLED(*; "b@"; False)
			OBJECT SET ENABLED(*; "bCerrar"; True)
			OBJECT SET ENTERABLE(*; "i_@"; False)
		End if

	: (Form event code=On Data Change)
		Param_Refrescar
End case
