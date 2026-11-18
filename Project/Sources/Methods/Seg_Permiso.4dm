//%attributes = {}
//Seg_Permiso(modulo; accion) -> Boolean
//módulos: ver Seg_Modulos.  acciones: ver crear editar anular
//Los permisos salen de la tabla Accesos del rol del usuario (cargados en <>Usuario.accesos al iniciar sesión).
//El rol llamado ADMIN tiene acceso total (evita quedarse sin acceso al configurar roles).
#DECLARE($modulo : Text; $accion : Text) : Boolean
var $a : Object

If (($modulo="EMPRESA") && ($accion="crear"))
	return False  //la empresa se identifica por su dominio; se edita, no se crean más desde la app
End if

If (String(<>Usuario.rol)="ADMIN")
	return True
End if

If (<>Usuario.accesos=Null)
	return False
End if
$a:=<>Usuario.accesos[$modulo]
If ($a=Null)
	return False
End if

Case of
	: ($accion="ver")
		return Bool($a.leer)
	: ($accion="crear")
		return Bool($a.crear)
	: ($accion="editar")
		return Bool($a.editar)
	: ($accion="anular")
		return Bool($a.anular)
End case
return False
