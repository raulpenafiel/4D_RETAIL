//%attributes = {}
//Doc_DatosBase(modo) -> objeto Form inicial de los formularios *_DETALLE de documentos
//Todas las propiedades que usan FACTURA, COMPRA, AJUSTE y CONTABILIDAD.
#DECLARE($modo : Text) : Object
return New object(\
"modo"; $modo; "modulo"; Form.modulo; "lineas"; New collection; "lineaActual"; Null; \
"numero"; ""; "fecha"; Current date; "observacion"; ""; "codigo"; ""; \
"terceroID"; 0; "terIdent"; ""; "terNombre"; ""; "formaPago"; "EFECTIVO"; \
"subtotal"; 0; "descuento"; 0; "iva"; 0; "total"; 0; \
"motivo"; ""; "tipo"; "ENTRADA"; \
"concepto"; ""; "totDebito"; 0; "totCredito"; 0; "diferencia"; 0)
