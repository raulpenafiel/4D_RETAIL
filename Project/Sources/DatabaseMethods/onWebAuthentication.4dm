//On Web Authentication
//Usuario web:  usuario@dominio   (dominio = Empresas.Dominio; usuario = Usuarios.NombreAcceso)
//Clave: la registrada en Usuarios.ClaveHash. La validación está en Seg_Autenticar (igual que el escritorio).
C_TEXT($1; $2; $3; $4; $5; $6)
C_BOOLEAN($0)

var $aut : Object

$0:=False
$aut:=Seg_Autenticar($5; $6)
If ($aut.ok)
	Use (Session.storage)
		Session.storage.usuario:=New shared object("id"; $aut.usuario.UsuariosID; "rol"; $aut.usuario.rol.Nombre; "empresaID"; $aut.empresa.EmpresaID; "sucursalID"; $aut.usuario.SucursalesID)
	End use
	$0:=True
End if
