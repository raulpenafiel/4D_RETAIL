//%attributes = {}
//Método asociado a todas las opciones del menú
var $p : Text
$p:=Get selected menu item parameter

If ($p="SALIR")
	QUIT 4D
Else
	Modulo_Abrir($p)
End if
