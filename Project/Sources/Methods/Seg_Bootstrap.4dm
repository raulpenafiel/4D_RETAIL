//%attributes = {}
//Primer arranque (base vacía): crea Empresa + Sucursal matriz + roles base + usuario administrador.
//Pide EmpresaID, Dominio (obligatorio), nombre de acceso y clave del administrador.
//Las reglas de dominio y nombre de acceso se aplican con validar() de cada entidad.
//Todo va en una transacción: si algo falla, se cancela completa.
#DECLARE() : Boolean
var $e : cs.EmpresasEntity
var $s : cs.SucursalesEntity
var $u : cs.UsuariosEntity
var $admin : cs.RolesEntity
var $todo; $super : Object
var $m; $f : Object
var $id; $dominio; $acceso; $clave; $msg : Text

CONFIRM("La base está vacía. ¿Crear la empresa y el usuario administrador?"; "Inicializar"; "Cancelar")
If (OK=0)
	return False
End if

$id:=Request("Código de la empresa (EmpresaID, máximo 5 caracteres):"; "EMP01")
If (OK=0)
	return False
End if
$id:=Uppercase(Trim($id))

$dominio:=Request("Dominio de la empresa (obligatorio; se usa para entrar como usuario@dominio):"; "")
If (OK=0)
	return False
End if

$acceso:=Request("Nombre de acceso del administrador:"; "admin")
If (OK=0)
	return False
End if

$f:=New object("acceso"; ""; "clave"; ""; "mensaje"; "Clave del administrador (mínimo 6 caracteres)"; "soloClave"; True)
If (Not(Seg_Dialogo($f)))
	return False
End if
$clave:=$f.clave
If ((Length($clave)<6) || ($clave#Trim($clave)))
	ALERT("La clave debe tener al menos 6 caracteres y no empezar ni terminar con espacios.")
	return False
End if
$f.clave:=""
$f.mensaje:="Repita la clave del administrador"
If (Not(Seg_Dialogo($f)))
	return False
End if
If ($f.clave#$clave)
	ALERT("Las claves no coinciden.")
	return False
End if

START TRANSACTION

//Otra estación pudo inicializar mientras se llenaban los datos
If (ds.Empresas.all().length>0)
	CANCEL TRANSACTION
	ALERT("Otra estación ya inicializó el sistema. Inicie sesión normalmente.")
	return False
End if

$e:=ds.Empresas.new()
$e.EmpresaID:=$id
$e.RUC:="0000000000001"
$e.RazonSocial:="EMPRESA NUEVA"
$e.Dominio:=$dominio
$e.SecuencialAsiento:=0
//Cuentas de ejemplo: ajústelas al plan de cuentas real en Administración > Empresa
$e.CtaCaja:="1.1.01"
$e.CtaCxC:="1.1.02"
$e.CtaInventario:="1.1.03"
$e.CtaIVACompras:="1.1.04"
$e.CtaCxP:="2.1.01"
$e.CtaIVAVentas:="2.1.02"
$e.CtaVentas:="4.1.01"
$e.CtaCostoVentas:="5.1.01"
$e.CtaAjusteInventario:="5.1.02"
$e.Activo:=True
$msg:=$e.validar()
If ($msg="")
	$msg:=Val_Guardar($e)
End if

If ($msg="")
	$s:=ds.Sucursales.new()
	$s.EmpresaID:=$id
	$s.Codigo:="MATRIZ"
	$s.Nombre:="Sucursal Matriz"
	$s.Establecimiento:="001"
	$s.PuntoEmision:="001"
	$s.SecuencialFactura:=0
	$s.Activo:=True
	$msg:=$s.validar()
	If ($msg="")
		$msg:=Val_Guardar($s)
	End if
End if

If ($msg="")
	//Roles base (equivalentes a los permisos fijos de la versión anterior)
	$todo:=New object
	$super:=New object
	For each ($m; Seg_Modulos())
		$todo[$m.codigo]:="VCEA"
		If (Not(["EMPRESA"; "SUCURSAL"; "ROL"; "USUARIO"].includes($m.codigo)))
			$super[$m.codigo]:="VCEA"
		End if
	End for each
	$admin:=Seg_RolCrear($id; "ADMIN"; $todo)
	If (($admin=Null) \
		 || (Seg_RolCrear($id; "SUPERVISOR"; $super)=Null) \
		 || (Seg_RolCrear($id; "CAJERO"; New object("FACTURA"; "VC"; "CLIENTE"; "VCE"; "INVENTARIO"; "V"))=Null) \
		 || (Seg_RolCrear($id; "CONSULTA"; New object("INVENTARIO"; "V"; "CLIENTE"; "V"; "FACTURA"; "V"))=Null))
		$msg:="No se pudieron crear los roles base."
	End if
End if

If ($msg="")
	$u:=ds.Usuarios.new()
	$u.EmpresaID:=$id
	$u.SucursalesID:=$s.SucursalesID
	$u.RolesID:=$admin.RolesID
	$u.NombreAcceso:=$acceso
	$u.Nombres:="Administrador"
	$u.Activo:=True
	$msg:=$u.validar()
	If ($msg="")
		$u.ClaveHash:=Generate password hash($clave)
		$msg:=Val_Guardar($u)
	End if
End if

If ($msg#"")
	CANCEL TRANSACTION
	ALERT("No se inicializó el sistema: "+$msg)
	return False
End if

VALIDATE TRANSACTION
//validar() normaliza a minúsculas: se muestran los valores guardados
ALERT("Sistema inicializado. Entre como "+$u.NombreAcceso+"@"+$e.Dominio+" y complete los datos y las cuentas contables de la empresa en Administración.")
return True
