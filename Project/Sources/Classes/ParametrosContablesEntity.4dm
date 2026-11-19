Class extends Entity

//Un registro por empresa: estructura del plan de cuentas (máscara y grupos principales)
//y cuentas de los asientos automáticos (Cta*).

//Números de los grupos principales, en orden: activo, pasivo, patrimonio, ingresos, costos, gastos
Function grupos() : Collection
	return New collection(This.GrupoActivo; This.GrupoPasivo; This.GrupoPatrimonio; This.GrupoIngresos; This.GrupoCostos; This.GrupoGastos)

//Naturaleza por defecto de las cuentas del grupo
Function naturaleza($grupo : Integer) : Text
	If (New collection(This.GrupoActivo; This.GrupoCostos; This.GrupoGastos).includes($grupo))
		return "DEUDORA"
	End if
	return "ACREEDORA"

//Campos Cta* con su descripción (los usa el formulario PARAMCONTABLE_DETALLE)
Function cuentas() : Collection
	var $c : Collection
	$c:=New collection
	$c.push(New object("campo"; "CtaCaja"; "nombre"; "Caja / bancos"))
	$c.push(New object("campo"; "CtaCxC"; "nombre"; "Cuentas por cobrar"))
	$c.push(New object("campo"; "CtaVentas"; "nombre"; "Ventas"))
	$c.push(New object("campo"; "CtaIVAVentas"; "nombre"; "IVA en ventas"))
	$c.push(New object("campo"; "CtaInventario"; "nombre"; "Inventario"))
	$c.push(New object("campo"; "CtaCostoVentas"; "nombre"; "Costo de ventas"))
	$c.push(New object("campo"; "CtaCxP"; "nombre"; "Cuentas por pagar"))
	$c.push(New object("campo"; "CtaIVACompras"; "nombre"; "IVA en compras"))
	$c.push(New object("campo"; "CtaAjusteInventario"; "nombre"; "Ajustes de inventario"))
	return $c

Function usaCuenta($codigo : Text) : Boolean
	var $c : Object
	For each ($c; This.cuentas())
		If (String(This[$c.campo])=$codigo)
			return True
		End if
	End for each
	return False

Function validar() : Text
	var $m; $a; $c : Object
	var $g : Collection
	var $i : Integer
	var $msg : Text
	var $cta : cs.PlanCuentasEntity

	This.Mascara:=Trim(String(This.Mascara))
	$m:=Cta_Mascara(This.Mascara)
	If (Not($m.ok))
		return $m.mensaje
	End if

	$g:=This.grupos()
	For ($i; 0; $g.length-1)
		If (($g[$i]<=0) || (Length(String($g[$i]))>$m.niveles[0]))
			return "Los números de grupo deben ser mayores que 0 y caber en el primer nivel de la máscara ("+String($m.niveles[0])+" dígito(s))."
		End if
		If ($g.indexOf($g[$i])#$i)
			return "Los números de los grupos principales no pueden repetirse."
		End if
	End for

	If (Val_Existe(This; "EmpresaID"))
		return "La empresa ya tiene parámetros contables."
	End if

	//Si cambió la estructura, el plan de cuentas existente debe seguir cumpliéndola
	For each ($cta; ds.PlanCuentas.query("EmpresaID = :1"; This.EmpresaID))
		$a:=Cta_Analizar($cta.Codigo; This.Mascara)
		If (Not($a.ok))
			return "La cuenta "+$cta.Codigo+" no cumple la máscara: "+$a.mensaje
		End if
		If (Not($g.includes($a.grupo)))
			return "La cuenta "+$cta.Codigo+" es del grupo "+String($a.grupo)+", que no está entre los grupos principales."
		End if
	End for each

	//Cuentas de los asientos automáticos: deben existir en el plan, activas y de movimiento
	For each ($c; This.cuentas())
		//String(): en una entidad nueva los campos sin asignar valen Null (Null # "" es verdadero)
		This[$c.campo]:=Trim(String(This[$c.campo]))
		If (This[$c.campo]#"")
			$msg:=Cta_Validar(This.EmpresaID; This[$c.campo])
			If ($msg#"")
				return "Cuenta de "+$c.nombre+": "+$msg
			End if
		End if
	End for each
	return ""
