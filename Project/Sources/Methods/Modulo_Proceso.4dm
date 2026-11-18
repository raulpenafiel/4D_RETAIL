//%attributes = {}
//Proceso de un módulo: abre ventana y muestra el formulario
#DECLARE($form : Text)
var $win : Integer

If (<>MenuBar#"")
	SET MENU BAR(<>MenuBar)
End if 

$win:=Open form window($form; Plain form window; Horizontally centered; Vertically centered)
DIALOG($form; New object)
CLOSE WINDOW($win)

If ($form="MENU_PRINCIPAL")
	If (Is compiled mode)
		QUIT 4D
	Else 
		CANCEL
	End if 
End if 
