//%attributes = {}
//Modulo_Abrir(modulo): abre el formulario del módulo en su propio proceso
#DECLARE($mod : Text)
var $form : Text
var $pid : Integer

If ($mod="PRINCIPAL")
	$form:="MENU_PRINCIPAL"
Else
	If (Not(Seg_Permiso($mod; "ver")))
		ALERT("No tiene permisos para este módulo.")
		return
	End if
	$form:=$mod+"_LISTA"
End if

$pid:=New process("Modulo_Proceso"; 0; "Mod_"+$mod; $form; *)
If ($pid>0)
	BRING TO FRONT($pid)
End if
