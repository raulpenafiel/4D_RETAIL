//%attributes = {}
//Seg_RolCrear(empresaID; nombre; permisos) -> rol (Null si no se pudo guardar)
//permisos: {MODULO: "VCEA"}  V=ver(Leer) C=crear E=editar A=anular. Se usa al inicializar la base.
//Debe llamarse dentro de una transacción: si devuelve Null, quien llama la cancela.
#DECLARE($empresaID : Text; $nombre : Text; $permisos : Object) : cs.RolesEntity
var $rol : cs.RolesEntity
var $acc : cs.AccesosEntity
var $m : Object
var $p : Text

$rol:=ds.Roles.new()
$rol.EmpresaID:=$empresaID
$rol.Nombre:=$nombre
$rol.Activo:=True
If (Val_Guardar($rol)#"")
	return Null
End if

For each ($m; Seg_Modulos())
	$p:=String($permisos[$m.codigo])
	If ($p#"")
		$acc:=ds.Accesos.new()
		$acc.EmpresaID:=$empresaID
		$acc.RolesID:=$rol.RolesID
		$acc.Modulo:=$m.codigo
		$acc.Leer:=(Position("V"; $p)>0)
		$acc.Crear:=(Position("C"; $p)>0)
		$acc.Editar:=(Position("E"; $p)>0)
		$acc.Anular:=(Position("A"; $p)>0)
		If (Val_Guardar($acc)#"")
			return Null
		End if
	End if
End for each
return $rol
