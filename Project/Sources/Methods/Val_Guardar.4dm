//%attributes = {}
//Val_Guardar(entidad) -> mensaje ("" si se guardó)
//Guarda la entidad y devuelve un mensaje legible si save() falla.
#DECLARE($e : 4D.Entity) : Text
var $r : Object

$r:=$e.save()
If ($r.success)
	return ""
End if
return "No se pudo guardar en "+$e.getDataClass().getInfo().name+": "+String($r.statusText)
