//%attributes = {}
//Val_Existe(entidad; campo) -> Boolean
//True si OTRO registro de la misma empresa tiene el mismo valor en el campo.
//En Empresas la unicidad es global. Se excluye el propio registro cuando ya está guardado.
#DECLARE($e : 4D.Entity; $campo : Text) : Boolean
var $info : Object
var $sel : 4D.EntitySelection

$info:=$e.getDataClass().getInfo()
If ($info.name="Empresas")
	$sel:=ds.Empresas.query($campo+" = :1"; $e[$campo])
Else
	$sel:=ds[$info.name].query($campo+" = :1 AND EmpresaID = :2"; $e[$campo]; $e.EmpresaID)
End if

If ($e.getStamp()#0)
	$sel:=$sel.query($info.primaryKey+" # :1"; $e.getKey())
End if
return ($sel.length>0)
