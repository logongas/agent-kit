---
type: esquema
title: Lo que se usa de OKF
description: "Lo básico de OKF que sigue la documentación de agents_docs/: bundle, frontmatter, sources, rutas, índices y claves de extensión"
tags: []
sources:
  - resource: https://okf.md/spec/
    title: Especificación de OKF
---

# Lo que se usa de OKF

Toda la documentación de `agents_docs/` (la wiki y los planes) sigue [OKF (Open Knowledge Format)](https://github.com/open-knowledge-format/open-knowledge-format/blob/main/SPEC.md), versión 0.3: una carpeta de Markdown con frontmatter YAML que se lee sin ninguna herramienta. Aquí está solo lo que se usa de él y cómo; lo demás se consulta en la especificación. Lo propio de la wiki (sus tipos, temas y decisiones) está en [wiki-read.md](wiki/wiki-read.md) y [wiki-update.md](wiki/wiki-update.md).

## Bundle

- El **bundle** es `agents_docs/`: esa carpeta es su raíz, y la identifica su [index.md](index.md), que es el único `index.md` con frontmatter (`okf_version`, `title`, `description`).
- Un **concepto** es un `.md` con frontmatter y un `type`. Un `.md` sin `type` no es un concepto y no molesta.
- `index.md` y `log.md` son nombres reservados en cualquier carpeta: no se usan para una página.
- Lo que empieza por `.` (`.obsidian/`) no forma parte del bundle.

## Frontmatter

El frontmatter va entre dos líneas `---` al principio del fichero y tiene que ser YAML válido: un valor que lleve `: ` o empiece por un carácter especial va entre comillas.

| Atributo | De OKF | Qué es |
|----------|--------|--------|
| `type` | Sí, el único obligatorio | Qué clase de documento es. Sus valores son libres: OKF no tiene una lista y quien lee acepta los que no conoce |
| `title` | Sí | Nombre legible |
| `description` | Sí | Una frase que resume el documento; es la que se copia en `index.md` |
| `tags` | Sí | Lista de etiquetas transversales |
| `sources` | Sí | De dónde sale el documento (ver [Sources](#sources)) |
| `subtype` | No, es una clave de extensión | Qué clase de documento es dentro de su `type`. Opcional y de valores libres |

OKF permite añadir claves propias y obliga a quien edita un fichero a conservar las que no conoce. No se usan `resource`, `generated`, `verified`, `status`, `superseded_by` ni `stale_after`.

## Sources

`sources` dice de qué materiales deriva un documento, sean de dentro o de fuera del bundle. Lo puede llevar cualquier página. Es una lista con una entrada por fuente:

```yaml
sources:
  - resource: analisis.md
  - resource: /wiki/front/bem/TEMA.md
  - resource: https://angular.dev/guide/signals
    title: Guía de signals de Angular
```

- `resource` es obligatorio en cada entrada: una ruta (ver [Rutas](#rutas)) o una URL. `title` es opcional.
- Cuando un `resource` apunta a otro documento del bundle, quien lee puede seguir a su vez los `sources` de ese documento. Así se forma una cadena: de un documento a aquellos de los que parte, hasta el primero.

## Rutas

Un enlace de Markdown y un atributo que contiene una ruta (`sources[].resource`) se resuelven igual:

| Cómo empieza | Desde dónde se resuelve | Ejemplo |
|--------------|-------------------------|---------|
| Con un esquema | Es una URL | `https://okf.md/spec/` |
| Con `/` | Desde la raíz del bundle, `agents_docs/` | `/wiki/front/bem/TEMA.md` |
| Con cualquier otra cosa | Desde la carpeta del fichero que la contiene | `../front/ADR.md` |

- Las dos formas de dentro del bundle valen; se usa la que quede más corta y clara.
- Solo `[texto](destino)` es un enlace. Los `[[wikilinks]]` no lo son.
- Lo que está fuera de `agents_docs/` (el código, `AGENTS.md`, los skills) es externo al bundle: se cita en el texto con su ruta desde la raíz del repositorio (`back/src/...`), no con una ruta con `/`.

## Índices

Un `index.md` lista lo que hay en su carpeta, una entrada por línea con la `description` del documento, para elegir qué leer sin abrir nada. Solo el de la raíz del bundle lleva frontmatter.
