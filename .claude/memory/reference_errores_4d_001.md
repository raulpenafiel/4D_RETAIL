# Errores conocidos — 4D 21.x

> Archivo 001. Síntoma, causa y solución.

## 2026-11-18 — Los métodos de formulario y de objeto no se ejecutan
- **Síntoma:** los botones no hacen nada y el On Load no corre. Check Syntax no muestra errores.
- **Causa:** los `.4dm` existían en `Forms/<F>/method.4dm` y `Forms/<F>/ObjectMethods/`, pero el `form.4DForm` no los declaraba. 4D no los asocia solo por el nombre del archivo.
- **Solución:** declarar `"method": "method.4dm"` en la raíz del formulario y `"method": "ObjectMethods/<objeto>.4dm"` en cada objeto, además de sus `"events"`. Se corrigieron los 27 formularios con un script de auditoría (139 enlaces).
