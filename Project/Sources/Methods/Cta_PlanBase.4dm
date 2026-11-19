//%attributes = {}
//Cta_PlanBase(empresaID) -> mensaje ("" si todo se guardó)
//Crea los parámetros contables (máscara 9.9.99.999, grupos 1 a 6) y un plan de cuentas básico
//con las cuentas de los asientos automáticos. Lo usa Seg_Bootstrap dentro de su transacción.
#DECLARE($empresaID : Text) : Text
var $par : cs.ParametrosContablesEntity
var $cta : cs.PlanCuentasEntity
var $plan : Collection
var $l : Object
var $msg : Text

$par:=ds.ParametrosContables.new()
$par.EmpresaID:=$empresaID
$par.Mascara:="9.9.99.999"
$par.GrupoActivo:=1
$par.GrupoPasivo:=2
$par.GrupoPatrimonio:=3
$par.GrupoIngresos:=4
$par.GrupoCostos:=5
$par.GrupoGastos:=6
$msg:=$par.validar()
If ($msg="")
	$msg:=Val_Guardar($par)
End if
If ($msg#"")
	return $msg
End if

//codigo; nombre; movimiento (las superiores van antes que sus subcuentas)
$plan:=New collection
$plan.push(New object("c"; "1"; "n"; "ACTIVO"; "m"; False))
$plan.push(New object("c"; "1.1"; "n"; "ACTIVO CORRIENTE"; "m"; False))
$plan.push(New object("c"; "1.1.01"; "n"; "CAJA Y BANCOS"; "m"; True))
$plan.push(New object("c"; "1.1.02"; "n"; "CUENTAS POR COBRAR CLIENTES"; "m"; True))
$plan.push(New object("c"; "1.1.03"; "n"; "INVENTARIO DE MERCADERÍAS"; "m"; True))
$plan.push(New object("c"; "1.1.04"; "n"; "IVA EN COMPRAS"; "m"; True))
$plan.push(New object("c"; "2"; "n"; "PASIVO"; "m"; False))
$plan.push(New object("c"; "2.1"; "n"; "PASIVO CORRIENTE"; "m"; False))
$plan.push(New object("c"; "2.1.01"; "n"; "CUENTAS POR PAGAR PROVEEDORES"; "m"; True))
$plan.push(New object("c"; "2.1.02"; "n"; "IVA EN VENTAS"; "m"; True))
$plan.push(New object("c"; "3"; "n"; "PATRIMONIO"; "m"; False))
$plan.push(New object("c"; "3.1"; "n"; "CAPITAL"; "m"; False))
$plan.push(New object("c"; "3.1.01"; "n"; "CAPITAL SOCIAL"; "m"; True))
$plan.push(New object("c"; "4"; "n"; "INGRESOS"; "m"; False))
$plan.push(New object("c"; "4.1"; "n"; "INGRESOS OPERACIONALES"; "m"; False))
$plan.push(New object("c"; "4.1.01"; "n"; "VENTAS DE MERCADERÍAS"; "m"; True))
$plan.push(New object("c"; "5"; "n"; "COSTOS"; "m"; False))
$plan.push(New object("c"; "5.1"; "n"; "COSTO DE VENTAS"; "m"; False))
$plan.push(New object("c"; "5.1.01"; "n"; "COSTO DE VENTAS"; "m"; True))
$plan.push(New object("c"; "5.1.02"; "n"; "AJUSTES DE INVENTARIO"; "m"; True))
$plan.push(New object("c"; "6"; "n"; "GASTOS"; "m"; False))
$plan.push(New object("c"; "6.1"; "n"; "GASTOS ADMINISTRATIVOS"; "m"; False))

For each ($l; $plan)
	$cta:=ds.PlanCuentas.new()
	$cta.EmpresaID:=$empresaID
	$cta.Codigo:=$l.c
	$cta.Nombre:=$l.n
	$cta.Movimiento:=$l.m
	$cta.Activo:=True
	$msg:=$cta.validar()
	If ($msg="")
		$msg:=Val_Guardar($cta)
	End if
	If ($msg#"")
		return "Plan de cuentas ("+$l.c+"): "+$msg
	End if
End for each

//Cuentas de ejemplo para los asientos automáticos: ajústelas en Parámetros Contables
$par.CtaCaja:="1.1.01"
$par.CtaCxC:="1.1.02"
$par.CtaInventario:="1.1.03"
$par.CtaIVACompras:="1.1.04"
$par.CtaCxP:="2.1.01"
$par.CtaIVAVentas:="2.1.02"
$par.CtaVentas:="4.1.01"
$par.CtaCostoVentas:="5.1.01"
$par.CtaAjusteInventario:="5.1.02"
$msg:=$par.validar()
If ($msg="")
	$msg:=Val_Guardar($par)
End if
return $msg
