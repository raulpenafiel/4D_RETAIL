//%attributes = {}
//Param_ElegirCuenta(campo): botón "..." de cada cuenta Cta* en PARAMCONTABLE_DETALLE
#DECLARE($campo : Text)
var $codigo : Text

$codigo:=Cta_Elegir
If ($codigo#"")
	Form.entidad[$campo]:=$codigo
	Param_Refrescar
End if
