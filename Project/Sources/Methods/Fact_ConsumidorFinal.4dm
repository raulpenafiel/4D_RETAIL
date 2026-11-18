//%attributes = {}
//Asigna (y crea si no existe) el cliente CONSUMIDOR FINAL de la empresa
var $c : cs.ClientesFichaEntity

$c:=ds.ClientesFicha.query("EmpresaID = :1 AND Identificacion = :2"; <>Usuario.empresaID; "9999999999").first()
If ($c=Null)
	$c:=ds.ClientesFicha.new()
	$c.EmpresaID:=<>Usuario.empresaID
	$c.Codigo:="CF"
	$c.TipoIdentificacion:="CI"
	$c.Identificacion:="9999999999"
	$c.Nombre:="CONSUMIDOR FINAL"
	$c.Activo:=True
	$c.save()
End if
Form.terceroID:=$c.ClientesID
Form.terIdent:=$c.Identificacion
Form.terNombre:=$c.Nombre
