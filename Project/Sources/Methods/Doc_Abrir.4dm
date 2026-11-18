//%attributes = {}
//Doc_Abrir(datos): abre datos.modulo+"_DETALLE" y al cerrar refresca la lista
#DECLARE($data : Object)
var $win : Integer
var $form : Text

$form:=$data.modulo+"_DETALLE"
$win:=Open form window($form; Movable form dialog box; Horizontally centered; Vertically centered)
DIALOG($form; $data)
CLOSE WINDOW($win)
Maestro_Refrescar
