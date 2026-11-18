//%attributes = {}
//Crea una entidad nueva y abre el detalle
var $e : 4D.Entity

If (Not(Seg_Permiso(Form.modulo; "crear")))
	ALERT("No tiene permiso para crear registros en este módulo.")
	return
End if

$e:=ds[Form.tabla].new()
$e.EmpresaID:=<>Usuario.empresaID
If (ds[Form.tabla].Activo#Null)
	$e.Activo:=True
End if
Case of
	: (Form.tabla="Sucursales")
		$e.SecuencialFactura:=0
	: (Form.tabla="InventarioFicha")
		$e.PorcentajeIVA:=15
		$e.Unidad:="UND"
	: (Form.tabla="FichaBancos")
		$e.Moneda:="USD"
End case
Maestro_Abrir($e)
