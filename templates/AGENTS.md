# AGENTS.md

RESUMEN: qué es el proyecto y dónde está cada parte.

## Órdenes

- Compilar: ...
- Tests: ...
- Arrancar en desarrollo: ...

## Convenciones

- ...

## Límites

- Se hace exactamente lo que se pide, con la solución más simple. Si algo no pedido parece útil (funcionalidad, opción, parámetro, configuración…), se pregunta antes explicando en una frase qué sería y para qué. Lo imprescindible para que lo pedido funcione se hace sin preguntar, pero se dice en la respuesta.
- La documentación (`agents_docs/wiki/`, skills) cuenta solo cómo es ahora y por qué: cuando algo cambia se reescribe lo que lo describe, sin entradas "antes era X, ahora es Y" ni nombres o rutas que ya no existen.
- No se crea ningún `CLAUDE.md`.

## Documentación del proyecto

- Al empezar cualquier tarea, carga siempre `agents_docs/wiki/index.md` y `agents_docs/wiki/wiki-read.md`: el índice tiene el resumen del proyecto y la lista de páginas de la wiki con lo que contiene cada una, y `wiki-read.md` cómo buscar en ella (tipos de página, temas y decisiones). A partir de ahí lee las páginas que toque la tarea.
- Antes de escribir en `agents_docs/wiki/`, lee `agents_docs/wiki/wiki-update.md`. Una decisión nueva va en el `ADR.md` de lo que trata, con el formato de `wiki-update.md`; al crear, mover o borrar una página, o al cambiar su `description`, se actualiza `agents_docs/wiki/index.md`.
