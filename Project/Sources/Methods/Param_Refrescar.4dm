//%attributes = {}
//Param_Refrescar: actualiza los textos de ayuda del formulario PARAMCONTABLE_DETALLE
//Form.infoMascara: niveles de la máscara y un ejemplo.  Form.nombres: nombre de cada cuenta Cta*.
var $m; $c : Object
var $cta : cs.PlanCuentasEntity
var $ejemplo : Text
var $n : Integer

$m:=Cta_Mascara(String(Form.entidad.Mascara))
If ($m.ok)
	For each ($n; $m.niveles)
		$ejemplo+=Choose($ejemplo=""; ""; $m.separador)+("0"*($n-1))+"1"
	End for each
	Form.infoMascara:=String($m.niveles.length)+" niveles; dígitos por nivel: "+$m.niveles.join(" - ")+".  Ejemplo de cuenta del último nivel: "+$ejemplo
Else
	Form.infoMascara:=$m.mensaje
End if

Form.nombres:=New object
For each ($c; Form.entidad.cuentas())
	Form.nombres[$c.campo]:=""
	If (String(Form.entidad[$c.campo])#"")
		$cta:=ds.PlanCuentas.query("EmpresaID = :1 AND Codigo = :2"; Form.entidad.EmpresaID; Form.entidad[$c.campo]).first()
		If ($cta=Null)
			Form.nombres[$c.campo]:="(no existe en el plan de cuentas)"
		Else
			Form.nombres[$c.campo]:=$cta.Nombre
		End if
	End if
End for each
