//%attributes = {}
//Val_MismaEmpresa(entidad; relaciones) -> mensaje ("" si todo es correcto)
//Regla: un registro nunca se relaciona con otro de distinta empresa.
//relaciones: nombres de las relaciones N->1 a revisar, p. ej. ["sucursal"; "rol"]
#DECLARE($e : 4D.Entity; $relaciones : Collection) : Text
var $rel : Text

For each ($rel; $relaciones)
	If ($e[$rel]#Null)
		If ($e[$rel].EmpresaID#$e.EmpresaID)
			return "El registro relacionado ("+$rel+") pertenece a otra empresa."
		End if
	End if
End for each
return ""
