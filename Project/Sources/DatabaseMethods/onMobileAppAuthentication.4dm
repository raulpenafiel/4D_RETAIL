//On Mobile App Authentication
//El campo "email" de la app móvil se valida contra Usuarios.Email (usuario activo, de una empresa activa).
C_OBJECT($1; $0)

var $usu : cs.UsuariosEntity

$0:=New object("success"; False; "statusText"; "Usuario no autorizado")
$usu:=ds.Usuarios.query("Email = :1 AND Activo = :2"; $1.email; True).first()
If ($usu#Null)
	If (($usu.empresa#Null) && ($usu.empresa.Activo))
		If (($usu.ClaveHash#"") && (Verify password hash($1.password; $usu.ClaveHash)))
			$0.success:=True
			$0.statusText:="OK"
		End if
	End if
End if
