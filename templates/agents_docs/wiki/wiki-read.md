---
type: esquema
title: Cómo se lee la wiki
description: "Cómo está organizada la wiki y cómo buscar en ella: tipos de página, temas, decisiones e índice"
tags: []
---

# Cómo se lee la wiki

La wiki documenta un proyecto de software para que un LLM (o una persona) que llega a él entienda qué hace, cómo está construido y por qué, sin tener que deducirlo del código. Es una carpeta de Markdown en castellano que sigue OKF (Open Knowledge Format): lo que se usa de él (frontmatter, `sources`, rutas, índices) está en [OKF.md](../OKF.md). Cómo se escribe o se modifica está en [wiki-update.md](wiki-update.md).

## Cómo se busca

- Se empieza por [index.md](index.md): tiene el resumen del proyecto y todas las páginas con su `description`. Con la descripción se elige qué página leer sin abrir ninguna.
- El `type` del frontmatter de cada página dice qué clase de cosa cuenta (ver [Tipos](#tipos)): sirve para saber en qué ficheros buscar.
- La wiki cuenta solo cómo es ahora el proyecto y por qué. Lo que dice está vigente; no hay histórico (está en git).
- Si una página contradice al código, manda el código.
- Una ruta (un enlace o un atributo del frontmatter) sin `/` inicial es relativa a la carpeta del fichero que la contiene, y con `/` inicial, a `agents_docs/` (`/wiki/index.md`); ver [OKF.md](../OKF.md#rutas). Las rutas de código que se citan en el texto (`back/src/...`) son relativas a la raíz del repositorio.
- Lo que no está en la wiki se busca en el código: la wiki no copia listas que ya están en él (endpoints, componentes, ficheros).

## Tipos

Todas las páginas, salvo `index.md`, llevan en el frontmatter un `type`:

| Tipo | Qué contiene | Dónde buscarlo |
|------|--------------|----------------|
| intencion | Qué hace la aplicación, para quién y por qué: usuarios, conceptos del dominio y pantallas | Dudas de producto o de dominio |
| tecnico | Cómo está hecho o cómo se trabaja: arquitectura, tecnología, diseño gráfico, despliegue, commits… | Antes de tocar código o de compilar, desplegar o commitear |
| decision | Registro de decisiones y alternativas descartadas (ver [Decisiones](#decisiones)) | Antes de proponer un cambio en lo que trata |
| tema | La entrada de un tema; solo la lleva un `TEMA.md` (ver [Temas](#temas)) | Para trabajar en un asunto amplio |
| esquema | Las reglas de la propia documentación: `wiki-read.md`, `wiki-update.md` y `OKF.md` | Para leer o escribir la wiki |
| plan | Un documento que prepara algo que se hará después. No cuenta cómo es ahora el proyecto ni se mantiene; está en `agents_docs/planes/`, fuera de la wiki, y lo escriben y lo aplican los skills de planes | Para continuar o aplicar un plan |
| sin-tipo | Documentación a la que aún no se le ha dado tipo | Cuando no aparece en ningún otro tipo |

Un documento de cualquier tipo puede llevar además un `subtype`, que dice qué clase de documento es dentro de su tipo. Es opcional y su vocabulario es abierto: lo elige quien escribe el documento, y un valor que no se conoce se lee como una etiqueta más, no como un error.

### Buscar por tipo

El `type` está siempre en una línea propia del frontmatter (`type: decision`), así que con `grep` se encuentran las páginas de un tipo sin abrir ninguna. Las órdenes se lanzan desde la raíz del repositorio:

- Qué ficheros son de un tipo (por ejemplo, todos los de decisiones):

  ```bash
  grep -rl --include=*.md "^type: decision" agents_docs/wiki/
  ```

- Esos ficheros con su `description`, para elegir cuál abrir:

  ```bash
  grep -rl --include=*.md "^type: tecnico" agents_docs/wiki/ | xargs grep -H "^description:"
  ```

- Cuántas páginas hay de cada tipo:

  ```bash
  grep -rh --include=*.md -m1 "^type:" agents_docs/wiki/ | sort | uniq -c
  ```

El `^` ancla la búsqueda al principio de la línea, para no encontrar la palabra `type:` en mitad del texto, y `-m1` se queda con la primera aparición de cada fichero, que es la del frontmatter (un bloque de código con `type:`, como el de [wiki-update.md](wiki-update.md#frontmatter), queda detrás).

## Temas

Un tema es una carpeta con todo lo necesario sobre un asunto amplio: qué es, cómo se hace y por qué.

- Para trabajar en un tema se lee su `TEMA.md`: lo primero que tiene es un índice de todos los ficheros del tema, cada uno con una frase de lo que contiene. Desde él se abre lo que haga falta.
- Solo su `TEMA.md` aparece en `index.md`; el resto de ficheros llevan el tag `noindex` y se llega a ellos desde el `TEMA.md`.
- Subcarpetas que puede tener:
  - `templates/`: plantillas literales con huecos, para generar un fichero.
  - `examples/`: cómo queda lo que hay que generar.
  - `references/`: documentación de referencia, como la documentación oficial de una librería.
  - `scripts/`: scripts que hacen parte de la tarea; si existe uno para algo, se usa en vez de hacerlo a mano.
  - `assets/`: esquemas, XSD, imágenes…

## Decisiones

Un fichero de decisiones es el que lleva `type: decision` (lo habitual es que se llame `ADR.md`). Explica por qué algo es como es y qué se descartó, para no volver a probarlo.

- Hay que leerlo entero antes de proponer un cambio en lo que trata, para no repetir algo ya descartado.
- Cada decisión es una sección `ADR-nn · Título que dice la decisión` con contexto, decisión, alternativas descartadas y consecuencias. Se citan por su número: "ADR-03 de `carpeta/ADR.md`".
- Todas las decisiones de un fichero están vigentes.
