//%attributes = {}
//Menu_Construir -> referencia de barra de menús
//Un menú por grupo de Seg_Modulos, con los módulos que el usuario puede ver.
#DECLARE() : Text
var $barra; $mArch; $m; $grupo : Text
var $mod : Object

$barra:=Create menu

$mArch:=Create menu
APPEND MENU ITEM($mArch; "Menú principal")
SET MENU ITEM METHOD($mArch; -1; "Menu_Ejecutar")
SET MENU ITEM PARAMETER($mArch; -1; "PRINCIPAL")
APPEND MENU ITEM($mArch; "Salir")
SET MENU ITEM METHOD($mArch; -1; "Menu_Ejecutar")
SET MENU ITEM PARAMETER($mArch; -1; "SALIR")
APPEND MENU ITEM($barra; "Archivo"; $mArch)

For each ($grupo; ["Inventarios"; "Clientes"; "Proveedores"; "Contabilidad"; "Administración"])
	$m:=Create menu
	For each ($mod; Seg_Modulos().query("grupo = :1"; $grupo))
		If (Seg_Permiso($mod.codigo; "ver"))
			APPEND MENU ITEM($m; $mod.nombre)
			SET MENU ITEM METHOD($m; -1; "Menu_Ejecutar")
			SET MENU ITEM PARAMETER($m; -1; $mod.codigo)
		End if
	End for each
	If (Count menu items($m)>0)
		APPEND MENU ITEM($barra; $grupo; $m)
	Else
		RELEASE MENU($m)
	End if
End for each

return $barra
