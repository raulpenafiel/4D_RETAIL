Class extends Entity

Function validar() : Text
	If (This.Nombre="")
		return "El nombre del rol es obligatorio."
	End if
	If (Val_Existe(This; "Nombre"))
		return "Ya existe un rol con ese nombre."
	End if
	return ""

//Guarda el rol y sus Accesos en una transacción.
//$accesos: colección de {modulo; leer; crear; editar; anular} (ver Maestro_DetalleCargar)
Function guardarConAccesos($accesos : Collection) : Object
	var $r; $a : Object
	var $acc : cs.AccesosEntity
	var $i : Integer

	START TRANSACTION
	$r:=This.save()
	If ($accesos=Null)
		$accesos:=New collection
	End if
	$i:=0
	While (($r.success) && ($i<$accesos.length))
		$a:=$accesos[$i]
		$acc:=ds.Accesos.query("RolesID = :1 AND Modulo = :2"; This.RolesID; $a.modulo).first()
		If ($acc=Null)
			$acc:=ds.Accesos.new()
			$acc.EmpresaID:=This.EmpresaID
			$acc.RolesID:=This.RolesID
			$acc.Modulo:=$a.modulo
		End if
		$acc.Leer:=Bool($a.leer)
		$acc.Crear:=Bool($a.crear)
		$acc.Editar:=Bool($a.editar)
		$acc.Anular:=Bool($a.anular)
		$r:=$acc.save()
		$i+=1
	End while
	If ($r.success)
		VALIDATE TRANSACTION
	Else
		CANCEL TRANSACTION
	End if
	return $r
