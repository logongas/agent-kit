---
type: esquema
title: Cómo se modifica la wiki
description: "Reglas para escribir en la wiki: qué se documenta, nombres, frontmatter, temas, decisiones e índice"
tags: []
---

# Cómo se modifica la wiki

Cómo está organizada y cómo se lee está en [wiki-read.md](wiki-read.md), que hay que conocer antes de escribir. La fuente de todo lo que se escribe es el código del proyecto.

## Formato

La wiki sigue OKF (Open Knowledge Format): una carpeta de Markdown con frontmatter YAML en la que toda página lleva `type`, y `index.md` es el punto de entrada. Lo que se usa de OKF (los atributos del frontmatter, `sources`, las rutas, los índices) está en [OKF.md](../OKF.md), que hay que conocer antes de escribir. Se escribe en castellano. Es Markdown estándar y no depende de ninguna herramienta.

## Qué se documenta

- Qué hace la aplicación, para quién y con qué conceptos del dominio.
- Cómo está construida: arquitectura de cada parte, cómo se comunican, modelo de datos, convenciones.
- Por qué es así: decisiones tomadas y alternativas descartadas.
- Cómo se compila, configura, arranca y despliega, y cómo se trabaja (commits, issues).

**Fuera:**
- Lo que ya dice el código y se consulta en él.
- El histórico de cambios.
- Las instrucciones generales para agentes, que van en `AGENTS.md`.

## Nombres

- Ficheros en minúsculas con `-` entre palabras, salvo siglas (`ADR.md`).
- `index.md` está reservado para el índice de la raíz y `TEMA.md` para la entrada de un tema.

## Frontmatter

Todas las páginas, salvo `index.md`, llevan:

```yaml
---
type: intencion | tecnico | decision | tema | esquema | sin-tipo
subtype: opcional, qué clase de documento es dentro de su type
title: Título legible
description: Una frase que dice qué contiene la página
tags: []
---
```

- El `type` se elige con la tabla de tipos de [wiki-read.md](wiki-read.md#tipos). `tema` solo lo lleva un `TEMA.md` y `esquema` solo `wiki-read.md`, `wiki-update.md` y `OKF.md`; `sin-tipo` es para lo que aún no tiene tipo. `plan` no lo lleva ninguna página de la wiki.
- `subtype` es opcional y dice qué clase de documento es dentro de su `type`. Su vocabulario es abierto: lo elige quien escribe el documento y la wiki no lleva ninguna lista de subtipos. Se escribe en minúsculas, sin tildes ni ñ y con guiones (ADR-03 de [common/ADR.md](common/ADR.md)).
- Una página puede llevar además `sources`, con los materiales de los que deriva (ver [OKF.md](../OKF.md#sources)).
- Un valor que lleve `: ` va entre comillas, para que el frontmatter sea YAML válido.
- `description` es la misma frase que acompaña a la página en `index.md`. Si cambia una, se cambia la otra.
- El tag `noindex` marca una página que no se enlaza desde fuera de su tema ni aparece en `index.md`: lo llevan todos los `.md` de un tema salvo su `TEMA.md`.

## Cómo se añade o cambia una página

- Cuando algo cambia se reescribe la página que lo describe, sin entradas "antes era X, ahora es Y" ni nombres o rutas que ya no existen.
- Una ruta (un enlace o un atributo del frontmatter) sin `/` inicial es relativa a la carpeta del fichero que la contiene; con `/` inicial, a `agents_docs/`, la raíz del bundle (`/wiki/index.md`). Es la regla de OKF (ver [OKF.md](../OKF.md#rutas) y ADR-01 de [common/ADR.md](common/ADR.md)).
- Se cita el código con rutas relativas a la raíz del repositorio, y con línea cuando ayuda. Lo que no se pueda comprobar en el código no se afirma.
- No se copian listas que ya están en el código: se dice dónde consultarlas.
- Una decisión nueva va en el fichero de decisiones de su tema o, si no es de ningún tema, en el de lo que trata, y la regla que sale de ella se escribe también en la página que la aplica.
- Si una página contradice al código, se corrige la página. Si contradice a otra página, se corrigen las dos para que digan lo mismo.

## Temas

Un tema es una carpeta con todo lo necesario sobre un asunto amplio: qué es, cómo se hace y por qué. Puede estar en cualquier carpeta de la wiki.

- Su única entrada es `TEMA.md`, con `type: tema` (ADR-04 de [common/ADR.md](common/ADR.md)).
- Lo primero del contenido de `TEMA.md` es un índice de todos los ficheros del tema, cada uno con una frase de lo que contiene.
- Es cerrado: desde fuera solo se enlaza su `TEMA.md`. Dentro, los ficheros pueden enlazarse entre sí.
- No contiene otros temas: no hay ningún `TEMA.md` en sus subcarpetas.
- Todos sus `.md` salvo `TEMA.md` llevan el tag `noindex`, y cada uno el `type` que le corresponde.
- Si el tema es largo, se parte en varios ficheros en su carpeta.
- Si en el tema se han tomado decisiones, van en su fichero de decisiones: ahí se explica por qué el tema es como es y qué se descartó.
- Subcarpetas, todas opcionales:
  - `templates/`: plantillas literales con huecos, para cuando hay que generar un fichero.
  - `examples/`: cómo queda lo que hay que generar. Mejor un buen ejemplo que una buena descripción.
  - `references/`: documentación de referencia, como la documentación oficial de una librería.
  - `scripts/`: scripts (bash, Python…) que hacen parte de la tarea. Si algo se puede hacer con un script en vez de gastar tokens, se hace con un script.
  - `assets/`: esquemas, XSD, imágenes…

## Decisiones

Un fichero de decisiones es el que lleva `type: decision`; se puede llamar como se quiera (lo habitual es `ADR.md`). Explica por qué algo es como es y qué se descartó, para no volver a probarlo.

Cada decisión es una sección con este formato:

```markdown
## ADR-01 · Título que dice la decisión

**Contexto:** qué problema había.
**Decisión:** qué se hace.
**Alternativas descartadas:** qué se probó o se pensó y por qué no.
**Consecuencias:** qué implica.
```

- El número es correlativo dentro del fichero (`ADR-01`, `ADR-02`…) y no se reutiliza: sirve para citar la decisión desde otras páginas ("ADR-03 de `carpeta/ADR.md`"). Una decisión nueva va al final con el número siguiente.
- El título dice la decisión, no el tema: "Las rutas usan hash", no "Rutas".
- Si una decisión cambia, se reescribe; si deja de valer, se quita. No se dejan dos decisiones que se contradigan ni se escribe "antes era…": el fichero cuenta solo lo vigente.
- La regla que sale de una decisión se escribe también en la página que la aplica.

## Índice

El `index.md` de la wiki es la entrada que carga `AGENTS.md` y no lleva frontmatter (solo lo lleva el de la raíz del bundle, `agents_docs/index.md`, que está para OKF; ADR-05 de [common/ADR.md](common/ADR.md)). Empieza con un resumen del proyecto y qué documenta la wiki, y después lista todas las páginas agrupadas por carpeta (de cada tema, solo su `TEMA.md`; nunca las que llevan el tag `noindex`), una por línea, con su `description`:

```
- [Título](carpeta/pagina.md) — description de la página
```

Al crear, mover o borrar una página, o al cambiar su `description`, se actualiza `index.md`.
