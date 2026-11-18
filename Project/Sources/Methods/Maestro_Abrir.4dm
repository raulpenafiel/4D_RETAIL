//%attributes = {}
//Maestro_Abrir(entidad): abre Form.modulo+"_DETALLE" con la entidad
#DECLARE($e : 4D.Entity)
var $win : Integer
var $form : Text
var $data : Object

$form:=Form.modulo+"_DETALLE"
$data:=New object("entidad"; $e; "tabla"; Form.tabla; "modulo"; Form.modulo; "claveNueva"; ""; "claveConfirmar"; ""; "sucursalNombre"; ""; "rolNombre"; "")

$win:=Open form window($form; Movable form dialog box; Horizontally centered; Vertically centered)
DIALOG($form; $data)
CLOSE WINDOW($win)
Maestro_Refrescar
