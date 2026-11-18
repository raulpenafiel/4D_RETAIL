//%attributes = {}
//Seg_Accesos(rol) -> {MODULO: {leer; crear; editar; anular}}
//Convierte los registros de Accesos del rol en un objeto para consultar con Seg_Permiso.
#DECLARE($rol : cs.RolesEntity) : Object
var $res : Object
var $a : cs.AccesosEntity

$res:=New object
If ($rol#Null)
	For each ($a; $rol.accesos)
		$res[$a.Modulo]:=New object("leer"; $a.Leer; "crear"; $a.Crear; "editar"; $a.Editar; "anular"; $a.Anular)
	End for each
End if
return $res
