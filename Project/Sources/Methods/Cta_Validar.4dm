//%attributes = {}
//Cta_Validar(empresaID; codigo) -> mensaje ("" si la cuenta puede recibir asientos)
//Regla única: la cuenta debe existir en el plan de cuentas de la empresa, estar activa y ser de movimiento.
//La usan ContabilidadPrincipal.registrar (asientos manuales y automáticos) y ParametrosContablesEntity.validar.
//No usa <>Usuario ni Form: se ejecuta también en el servidor.
#DECLARE($empresaID : Text; $codigo : Text) : Text
var $cta : cs.PlanCuentasEntity

$codigo:=Trim($codigo)
If ($codigo="")
	return "Falta la cuenta contable."
End if
$cta:=ds.PlanCuentas.query("EmpresaID = :1 AND Codigo = :2"; $empresaID; $codigo).first()
If ($cta=Null)
	return "La cuenta "+$codigo+" no existe en el plan de cuentas."
End if
If (Not($cta.Activo))
	return "La cuenta "+$codigo+" ("+$cta.Nombre+") está inactiva."
End if
If (Not($cta.Movimiento))
	return "La cuenta "+$codigo+" ("+$cta.Nombre+") no es de movimiento: use una de sus subcuentas."
End if
return ""
