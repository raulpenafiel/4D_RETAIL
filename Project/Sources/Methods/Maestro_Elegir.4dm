//%attributes = {}
//Maestro_Elegir(campoFK; tabla; campoMostrar; propiedadEtiqueta)
//Pop-up con los registros activos de la empresa; asigna la llave primaria a la entidad
#DECLARE($fk : Text; $tabla : Text; $mostrar : Text; $label : Text)
var $sel : 4D.EntitySelection
var $menu : Text
var $i; $r : Integer

$sel:=ds[$tabla].query("EmpresaID = :1 AND Activo = :2"; <>Usuario.empresaID; True).orderBy($mostrar)
If ($sel.length=0)
	ALERT("No hay registros activos para elegir.")
	return
End if

For ($i; 0; $sel.length-1)
	$menu+=Replace string(String($sel[$i][$mostrar]); ";"; ",")+";"
End for
$menu:=Substring($menu; 1; Length($menu)-1)

$r:=Pop up menu($menu)
If ($r>0)
	Form.entidad[$fk]:=$sel[$r-1].getKey()
	Form[$label]:=String($sel[$r-1][$mostrar])
End if
