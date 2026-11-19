//%attributes = {}
//Modulo_Abrir(modulo): abre el formulario del módulo en su propio proceso
//Abre X_LISTA, o el "formulario" que indique Seg_Modulos para ese módulo.
#DECLARE($mod : Text)
var $form : Text
var $m : Object
var $pid : Integer

If ($mod="PRINCIPAL")
	$form:="MENU_PRINCIPAL"
Else
	If (Not(Seg_Permiso($mod; "ver")))
		ALERT("No tiene permisos para este módulo.")
		return
	End if
	$form:=$mod+"_LISTA"
	$m:=Seg_Modulos().query("codigo = :1"; $mod).first()
	If ($m#Null)
		If (String($m.formulario)#"")
			$form:=$m.formulario
		End if
	End if
End if

$pid:=New process("Modulo_Proceso"; 0; "Mod_"+$mod; $form; *)
If ($pid>0)
	BRING TO FRONT($pid)
End if
