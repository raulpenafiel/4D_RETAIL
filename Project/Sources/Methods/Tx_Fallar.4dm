//%attributes = {}
//Tx_Fallar(resultado; mensaje; entidadesBloqueadas) -> resultado
//Libera los bloqueos, cancela la transacción en curso y devuelve el resultado con el mensaje.
#DECLARE($res : Object; $msg : Text; $bloqueadas : Collection) : Object
var $e : 4D.Entity

If ($bloqueadas#Null)
	For each ($e; $bloqueadas)
		If ($e#Null)
			$e.unlock()
		End if
	End for each
End if
CANCEL TRANSACTION
$res.ok:=False
$res.mensaje:=$msg
return $res
