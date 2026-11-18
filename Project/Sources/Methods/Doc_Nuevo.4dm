//%attributes = {}
//Botón Nuevo de las listas de documentos
var $data : Object

If (Not(Seg_Permiso(Form.modulo; "crear")))
	ALERT("No tiene permiso para crear documentos en este módulo.")
	return
End if

$data:=Doc_DatosBase("nuevo")
Case of
	: (Form.modulo="FACTURA")
		$data.numero:="(se asigna al emitir)"
	: ((Form.modulo="AJUSTE") || (Form.modulo="CONTABILIDAD"))
		$data.numero:="(se asigna al registrar)"
End case
Doc_Abrir($data)
