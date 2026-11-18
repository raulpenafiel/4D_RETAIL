//%attributes = {}
//Maestro_ElegirLista(atributo; "A;B;C")
#DECLARE($attr : Text; $opciones : Text)
var $col : Collection
var $r : Integer

$col:=Split string($opciones; ";")
$r:=Pop up menu($opciones)
If ($r>0)
	Form.entidad[$attr]:=$col[$r-1]
End if
