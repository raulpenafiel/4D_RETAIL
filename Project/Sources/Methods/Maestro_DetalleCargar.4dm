//%attributes = {}
//On Load de los formularios *_DETALLE de maestros
var $m : Object
var $a : cs.AccesosEntity
var $par : cs.ParametrosContablesEntity

Case of
	: (Form.tabla="Usuarios")
		If (Form.entidad.sucursal#Null)
			Form.sucursalNombre:=Form.entidad.sucursal.Nombre
		End if
		If (Form.entidad.rol#Null)
			Form.rolNombre:=Form.entidad.rol.Nombre
		End if

	: (Form.tabla="Empresas")
		//EmpresaID es la llave primaria: solo se escribe al crear
		OBJECT SET ENTERABLE(*; "i_EmpresaID"; Form.entidad.getStamp()=0)

	: (Form.tabla="PlanCuentas")
		$par:=ds.ParametrosContables.query("EmpresaID = :1"; Form.entidad.EmpresaID).first()
		If ($par=Null)
			Form.ayuda:="Defina primero la estructura en Parámetros del Sistema > Parámetros Contables."
		Else
			Form.ayuda:="Máscara: "+$par.Mascara+"   (la naturaleza vacía se toma del grupo)"
		End if

	: (Form.tabla="Roles")
		//Una fila por módulo con los accesos actuales del rol
		Form.accesos:=New collection
		For each ($m; Seg_Modulos())
			$a:=Null
			If (Form.entidad.getStamp()#0)
				$a:=Form.entidad.accesos.query("Modulo = :1"; $m.codigo).first()
			End if
			If ($a=Null)
				Form.accesos.push(New object("modulo"; $m.codigo; "nombre"; $m.nombre; "leer"; False; "crear"; False; "editar"; False; "anular"; False))
			Else
				Form.accesos.push(New object("modulo"; $m.codigo; "nombre"; $m.nombre; "leer"; $a.Leer; "crear"; $a.Crear; "editar"; $a.Editar; "anular"; $a.Anular))
			End if
		End for each
End case
