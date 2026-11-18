//%attributes = {}
//Recarga Form.lista según tabla, texto de búsqueda y empresa del usuario
//Todas las tablas (incluida Empresas) tienen EmpresaID.
var $sel : 4D.EntitySelection

$sel:=ds[Form.tabla].query("EmpresaID = :1"; <>Usuario.empresaID)

If (Form.texto#"")
	$sel:=$sel.query(Form.campoBusqueda+" = :1"; "@"+Form.texto+"@")
End if

Form.lista:=$sel.orderBy(Form.orden)
