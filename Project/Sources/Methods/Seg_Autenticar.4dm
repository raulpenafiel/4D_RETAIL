//%attributes = {}
//Seg_Autenticar(acceso; clave) -> {ok; usuario; empresa}
//acceso = "NombreAcceso@Dominio". Lo usan Seg_Login (escritorio) y onWebAuthentication (web).
//Exige: empresa activa, usuario activo con clave, clave correcta y rol activo.
//No usa <>Usuario ni Form: puede ejecutarse en el cliente o en el servidor.
#DECLARE($acceso : Text; $clave : Text) : Object
var $res : Object
var $partes : Collection
var $emp : cs.EmpresasEntity
var $usu : cs.UsuariosEntity

$res:=New object("ok"; False; "usuario"; Null; "empresa"; Null)

$partes:=Split string(Trim($acceso); "@")
If (($partes.length#2) || ($partes[0]="") || ($partes[1]=""))
	return $res
End if

$emp:=ds.Empresas.query("Dominio = :1 AND Activo = :2"; $partes[1]; True).first()
If ($emp=Null)
	return $res
End if

$usu:=ds.Usuarios.query("EmpresaID = :1 AND NombreAcceso = :2 AND Activo = :3"; $emp.EmpresaID; $partes[0]; True).first()
If ($usu=Null)
	return $res
End if
If ($usu.ClaveHash="")
	return $res
End if
If (Not(Verify password hash($clave; $usu.ClaveHash)))
	return $res
End if
If ($usu.rol=Null)
	return $res
End if
If (Not($usu.rol.Activo))
	return $res
End if

$res.ok:=True
$res.usuario:=$usu
$res.empresa:=$emp
return $res
