//%attributes = {}
//Inicio de sesión de escritorio: pide usuario@dominio + clave (formulario LOGIN, hasta 3 intentos).
//La validación está en Seg_Autenticar (la misma que usa la web).
#DECLARE() : Boolean
var $f; $aut : Object
var $emp : cs.EmpresasEntity
var $usu : cs.UsuariosEntity
var $intento : Integer

If (ds.Empresas.all().length=0)
	If (Not(Seg_Bootstrap()))
		return False
	End if
End if

$f:=New object("acceso"; ""; "clave"; ""; "mensaje"; "Ingrese usuario@dominio y clave"; "soloClave"; False)
$aut:=New object("ok"; False)

For ($intento; 1; 3)
	$f.clave:=""
	If (Not(Seg_Dialogo($f)))
		return False
	End if
	If (Position("@"; $f.acceso)=0)
		$f.mensaje:="Formato incorrecto. Use usuario@dominio"
	Else
		$aut:=Seg_Autenticar($f.acceso; $f.clave)
		If ($aut.ok)
			break
		End if
		//Mensaje genérico: no revela si falló el dominio, el usuario, la clave o el rol
		$f.mensaje:="Usuario, dominio o clave incorrectos (intento "+String($intento)+" de 3)"
	End if
End for

If (Not($aut.ok))
	ALERT("No se pudo iniciar sesión.")
	return False
End if

$usu:=$aut.usuario
$emp:=$aut.empresa
$usu.UltimoAcceso:=Current date
$usu.UltimoAccesoHora:=Current time
$usu.save()

<>Usuario:=New object(\
"id"; $usu.UsuariosID; \
"nombreAcceso"; $usu.NombreAcceso; \
"nombres"; $usu.Nombres; \
"rolID"; $usu.RolesID; \
"rol"; $usu.rol.Nombre; \
"accesos"; Seg_Accesos($usu.rol); \
"empresaID"; $emp.EmpresaID; \
"empresaNombre"; $emp.RazonSocial; \
"dominio"; $emp.Dominio; \
"sucursalID"; $usu.SucursalesID)
return True
