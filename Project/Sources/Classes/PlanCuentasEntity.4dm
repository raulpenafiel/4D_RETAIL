Class extends Entity

//Valida una cuenta del plan de cuentas contra la estructura definida en ParametrosContables.
//Calcula Nivel y Grupo a partir del código; si la naturaleza está vacía, la toma del grupo.
Function validar() : Text
	var $par : cs.ParametrosContablesEntity
	var $padre; $antes : cs.PlanCuentasEntity
	var $a : Object
	var $sep : Text

	This.Codigo:=Trim(String(This.Codigo))
	This.Nombre:=Trim(String(This.Nombre))
	If (This.Codigo="")
		return "El código de la cuenta es obligatorio."
	End if
	If (This.Nombre="")
		return "El nombre de la cuenta es obligatorio."
	End if

	$par:=ds.ParametrosContables.query("EmpresaID = :1"; This.EmpresaID).first()
	If ($par=Null)
		return "Defina primero la estructura de cuentas en Parámetros del Sistema > Parámetros Contables."
	End if
	$a:=Cta_Analizar(This.Codigo; $par.Mascara)
	If (Not($a.ok))
		return $a.mensaje
	End if
	If (Not($par.grupos().includes($a.grupo)))
		return "El grupo "+String($a.grupo)+" no es un grupo principal de la estructura de cuentas."
	End if
	This.Nivel:=$a.nivel
	This.Grupo:=$a.grupo

	If (String(This.Naturaleza)="")
		This.Naturaleza:=$par.naturaleza($a.grupo)
	End if
	If (Not(["DEUDORA"; "ACREEDORA"].includes(This.Naturaleza)))
		return "La naturaleza debe ser DEUDORA o ACREEDORA."
	End if

	If (Val_Existe(This; "Codigo"))
		return "Ya existe una cuenta con ese código."
	End if

	If ($a.padre#"")
		$padre:=ds.PlanCuentas.query("EmpresaID = :1 AND Codigo = :2"; This.EmpresaID; $a.padre).first()
		If ($padre=Null)
			return "Primero cree la cuenta superior "+$a.padre+"."
		End if
		If ($padre.Movimiento)
			return "La cuenta superior "+$a.padre+" es de movimiento: no puede tener subcuentas."
		End if
	End if

	If (This.getStamp()#0)
		$sep:=Cta_Mascara($par.Mascara).separador
		$antes:=ds.PlanCuentas.get(This.getKey())  //valores guardados
		If (($antes#Null) && ($antes.Codigo#This.Codigo))
			If ($antes.tieneSubcuentas($sep))
				return "No se puede cambiar el código: la cuenta tiene subcuentas."
			End if
			If (ds.ContabilidadDetalle.query("EmpresaID = :1 AND Cuenta = :2"; This.EmpresaID; $antes.Codigo).length>0)
				return "No se puede cambiar el código: la cuenta ya tiene asientos."
			End if
			If ($par.usaCuenta($antes.Codigo))
				return "No se puede cambiar el código: la cuenta se usa en los Parámetros Contables."
			End if
		End if
		If (This.Movimiento && This.tieneSubcuentas($sep))
			return "Una cuenta con subcuentas no puede ser de movimiento."
		End if
	End if
	return ""

Function tieneSubcuentas($sep : Text) : Boolean
	return (ds.PlanCuentas.query("EmpresaID = :1 AND Codigo = :2"; This.EmpresaID; This.Codigo+$sep+"@").length>0)
