//%attributes = {}
//Tx_Bloquear(entidad) -> Boolean
//Intenta bloquear la entidad (recargándola si cambió) durante ~1 segundo antes de rendirse.
#DECLARE($e : 4D.Entity) : Boolean
var $r : Object
var $i : Integer

For ($i; 1; 20)
	$r:=$e.lock(dk reload if stamp changed)
	If ($r.success)
		return True
	End if
	DELAY PROCESS(Current process; 3)
End for
return False
