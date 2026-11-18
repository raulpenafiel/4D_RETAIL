//%attributes = {}
//Elige la forma de pago (CREDITO va a cuentas por cobrar/pagar en el asiento)
var $r : Integer
var $c : Collection
$c:=Split string("EFECTIVO;TARJETA;TRANSFERENCIA;CREDITO"; ";")
$r:=Pop up menu("EFECTIVO;TARJETA;TRANSFERENCIA;CREDITO")
If ($r>0)
	Form.formaPago:=$c[$r-1]
End if
