//%attributes = {}
//Cta_Elegir -> código de cuenta ("" si se cancela)
//Pop-up con las cuentas activas de movimiento del plan de cuentas de la empresa de la sesión.
//Lo usan Parámetros Contables (Param_ElegirCuenta) y el asiento manual (CONTABILIDAD_DETALLE).
#DECLARE() : Text
var $sel : 4D.EntitySelection
var $cta : cs.PlanCuentasEntity
var $menu; $item : Text
var $r : Integer

$sel:=ds.PlanCuentas.query("EmpresaID = :1 AND Activo = :2 AND Movimiento = :3"; <>Usuario.empresaID; True; True).orderBy("Codigo")
If ($sel.length=0)
	ALERT("No hay cuentas activas de movimiento en el plan de cuentas.")
	return ""
End if

For each ($cta; $sel)
	$item:=$cta.Codigo+"   "+$cta.Nombre
	//Caracteres especiales de Pop up menu
	$item:=Replace string(Replace string(Replace string($item; ";"; ","); "/"; "-"); "("; "[")
	$menu+=$item+";"
End for each
$menu:=Substring($menu; 1; Length($menu)-1)

$r:=Pop up menu($menu)
If ($r>0)
	return $sel[$r-1].Codigo
End if
return ""
