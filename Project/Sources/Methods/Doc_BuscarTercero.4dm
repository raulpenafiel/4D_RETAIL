//%attributes = {}
//Busca el cliente (FACTURA) o proveedor (COMPRA) por identificación
var $t : 4D.Entity
var $dc : Text

If (Form.terIdent="")
	return
End if
$dc:="ClientesFicha"
If (Form.modulo="COMPRA")
	$dc:="ProveedoresFicha"
End if

$t:=ds[$dc].query("EmpresaID = :1 AND Identificacion = :2 AND Activo = :3"; <>Usuario.empresaID; Form.terIdent; True).first()
If ($t=Null)
	If (Form.modulo="COMPRA")
		ALERT("Proveedor no encontrado. Créelo en Proveedores > Proveedores.")
	Else
		ALERT("Cliente no encontrado. Créelo en Clientes > Clientes.")
	End if
	Form.terceroID:=0
	Form.terNombre:=""
Else
	Form.terceroID:=$t.getKey()
	Form.terNombre:=$t.Nombre
End if
