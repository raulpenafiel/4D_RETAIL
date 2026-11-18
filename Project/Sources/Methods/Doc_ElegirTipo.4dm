//%attributes = {}
//Ajustes: tipo (ENTRADA/SALIDA) de las líneas que se agreguen
var $r : Integer
var $c : Collection
$c:=Split string("ENTRADA;SALIDA"; ";")
$r:=Pop up menu("ENTRADA;SALIDA")
If ($r>0)
	Form.tipo:=$c[$r-1]
End if
