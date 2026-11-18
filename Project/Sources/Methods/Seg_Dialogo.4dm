//%attributes = {}
//Abre el formulario LOGIN en una ventana modal. Devuelve True si el usuario aceptó.
//$f: {acceso; clave; mensaje; soloClave}; el formulario escribe en acceso y clave.
#DECLARE($f : Object) : Boolean
var $win : Integer

$win:=Open form window("LOGIN"; Modal form dialog box; Horizontally centered; Vertically centered)
DIALOG("LOGIN"; $f)
CLOSE WINDOW($win)
return (OK=1)
