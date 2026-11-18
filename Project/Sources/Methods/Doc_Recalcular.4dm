//%attributes = {}
//Recalcula líneas y totales del documento según Form.modulo
var $l : Object
var $a; $b; $c; $lsub; $liva : Real

Case of
	: (Form.modulo="CONTABILIDAD")
		For each ($l; Form.lineas)
			$a+=Num($l.debito)
			$b+=Num($l.credito)
		End for each
		Form.totDebito:=Round($a; 2)
		Form.totCredito:=Round($b; 2)
		Form.diferencia:=Round(Form.totDebito-Form.totCredito; 2)

	: (Form.modulo="AJUSTE")
		For each ($l; Form.lineas)
			$l.total:=Round(Num($l.cantidad)*Num($l.precio); 2)
		End for each

	Else
		//FACTURA y COMPRA
		For each ($l; Form.lineas)
			$lsub:=Round((Num($l.cantidad)*Num($l.precio))-Num($l.descuento); 2)
			$liva:=Round($lsub*Num($l.iva)/100; 2)
			$l.total:=$lsub+$liva
			$a+=$lsub
			$b+=Num($l.descuento)
			$c+=$liva
		End for each
		Form.subtotal:=Round($a; 2)
		Form.descuento:=Round($b; 2)
		Form.iva:=Round($c; 2)
		Form.total:=Form.subtotal+Form.iva
End case
Form.lineas:=Form.lineas.copy()
