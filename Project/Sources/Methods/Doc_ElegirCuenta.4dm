//%attributes = {}
//Doc_ElegirCuenta: asigna una cuenta de movimiento a la línea seleccionada del asiento manual
var $codigo : Text

If (Form.lineaActual=Null)
	ALERT("Seleccione una línea.")
	return
End if
$codigo:=Cta_Elegir
If ($codigo#"")
	Form.lineaActual.cuenta:=$codigo
	Form.lineas:=Form.lineas  //refresca el list box
End if
