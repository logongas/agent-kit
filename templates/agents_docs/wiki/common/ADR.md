---
type: decision
title: ADR común
description: "Decisiones comunes a todo el proyecto, empezando por el uso de OKF en la documentación (rutas, sources, subtype, temas e índices)"
tags: []
---

# ADR común

Cada decisión se explica con su **Contexto**, **Decisión**, **Alternativas descartadas** y **Consecuencias**. Si una decisión cambia, se reescribe aquí; este documento no es un histórico.

## ADR-01 · Una ruta con `/` inicial parte de `agents_docs/`, la raíz del bundle de OKF

**Contexto:** la documentación está en `agents_docs/`, en dos carpetas hermanas: `wiki/` y `planes/`. Un plan que nombra una página de la wiki con una ruta relativa tiene que subir niveles a mano (`../../wiki/front/bem/TEMA.md`), y la ruta se rompe si el plan cambia de carpeta. OKF resuelve las rutas con `/` inicial desde la raíz del bundle.

**Decisión:** el bundle de OKF es `agents_docs/`, y lo identifica su `index.md` con `okf_version`. En un enlace o en un atributo del frontmatter, una ruta sin `/` inicial es relativa a la carpeta del fichero que la contiene y una ruta con `/` inicial parte de `agents_docs/` (`/wiki/front/bem/TEMA.md`). Una ruta con esquema (`https:`) es una URL. La regla está en [OKF.md](../../OKF.md#rutas).

**Alternativas descartadas:**
- `/` como raíz del repositorio: es más corta de explicar y coincide con cómo se citan las rutas de código, pero se aparta de OKF, donde lo que está fuera del bundle es externo.
- El bundle solo en `wiki/`, con los planes fuera: un plan no podría nombrar una página de la wiki con `/`, y habría una regla distinta para cada carpeta.
- Solo rutas relativas al fichero: son las `../..` del contexto.

**Consecuencias:** la wiki y los planes comparten raíz y reglas, sin apartarse de OKF. El código, `AGENTS.md` y los skills quedan fuera del bundle: se citan en el texto con su ruta desde la raíz del repositorio. Un anexo de un plan nombra un plan de la raíz de su proyecto con `../`.

## ADR-02 · La cadena de planes se guarda en el atributo `sources` de OKF

**Contexto:** un plan puede partir de otro (por ejemplo, un diseño de un análisis), y los skills `do-plan` y `do-plan-aplicar` necesitan ese dato para saber cuál es el último plan de un proyecto y qué hay que leer antes de aplicarlo. OKF ya tiene un atributo que dice de qué deriva un documento, `sources`, y prevé que quien lee siga los `sources` de un documento a otro.

**Decisión:** el plan del que parte otro va en su `sources`, con las rutas del ADR-01. No es un atributo de los planes: lo puede llevar cualquier página, y puede nombrar también otras fuentes, como una página de la wiki, que se lee como parte de la cadena, o una URL, que no se sigue. El formato está en [OKF.md](../../OKF.md#sources) y la cadena la lee `.claude/skills/do-plan/planes.py`.

**Alternativas descartadas:**
- Un atributo propio (`based_on`) solo para la cadena: es más corto de escribir y solo significa «continúo este plan», pero es un campo fuera de OKF para un dato que OKF ya sabe guardar.
- Limitar `sources` a planes y anexos: leer también una página de la wiki en la que se apoya el plan da contexto a quien lo aplica, y lo único que hay que apartar son las URLs.

**Consecuencias:** un plan no tiene ningún atributo que no pueda llevar otra página, así que la wiki no describe la cabecera de los planes: la conocen solo los skills que los escriben. La cadena es todo aquello en lo que se apoya el plan, no solo los planes anteriores. Un plan que nombra en su `sources` a otro del mismo proyecto sin continuarlo hace que ese otro deje de ofrecerse como último plan.

## ADR-03 · El `subtype` es opcional y abierto, y nada depende de él

**Contexto:** dentro de un tipo hay clases de documento distintas, y OKF no tiene un atributo para decirlo. OKF tampoco quiere una taxonomía fija: los valores de `type` son libres y quien lee acepta los que no conoce.

**Decisión:** cualquier documento puede llevar un `subtype`, una clave de extensión de OKF, con la clase de documento que es dentro de su `type`. Es opcional y su vocabulario es abierto: lo elige quien escribe el documento, y la wiki no lleva ninguna lista de subtipos. Ningún skill ni script decide nada por él. Los planes no lo llevan: el nombre del fichero ya dice qué clase de plan es. La regla está en [wiki-update.md](../wiki-update.md#frontmatter).

**Alternativas descartadas:**
- Una lista de subtipos por tipo en la tabla de tipos de la wiki: obliga a tocar la wiki cada vez que un skill escribe una clase de documento nueva, y ata los planes a unas fases fijas.
- Que `do-plan-aplicar` solo aplique los planes de ciertas clases: saber si un plan se puede aplicar es cosa de quien lo pide.
- Un `subtype` obligatorio en los planes, igual al nombre del fichero: son dos sitios para el mismo dato, que dejan de coincidir si se renombra el fichero.

**Consecuencias:** los planes pueden tener cualquier formato y no siguen un ciclo de vida del software concreto: un skill nuevo que escriba otra clase de plan no cambia ni la wiki ni los otros skills. Como `subtype` no lleva el prefijo `x-` que OKF recomienda para las claves propias, una versión futura de OKF podría definirlo con otro significado.

## ADR-04 · Un tema se abre por su `TEMA.md`, no por un `index.md` de carpeta

**Contexto:** un tema es una carpeta con todo lo de un asunto amplio. Sus páginas son internas: solo tienen sentido leídas después de la idea del tema, así que necesita una entrada que la explique y liste esas páginas. OKF resuelve las carpetas con un `index.md` que lista lo que hay en ellas.

**Decisión:** la entrada de un tema es su `TEMA.md`, con `type: tema`: explica la idea del tema y lista sus páginas con una frase de cada una. Las demás páginas del tema llevan el tag `noindex` y el `type` que les corresponde, y desde fuera del tema solo se enlaza su `TEMA.md`. Las reglas están en [wiki-update.md](../wiki-update.md#temas).

**Alternativas descartadas:**
- Un `index.md` en la carpeta con la lista, y la idea del tema en una página normal: la lista queda separada de la idea y pone a la vista las páginas internas, que no se leen sin ella.
- Un `index.md` con la lista además del `TEMA.md` con la idea: el tema tiene dos entradas, y la lista sigue a la vista sin la idea.
- Renombrar `TEMA.md` a `index.md`: la idea del tema deja de ser un concepto, porque en OKF un `index.md` no lleva `type` ni `description`.

**Consecuencias:** `TEMA.md`, `type: tema` y `noindex` son convenciones propias, válidas en OKF porque sus tipos y tags son libres. `noindex` no impide encontrar una página interna buscando en la wiki: solo dice que no se enlaza desde fuera ni aparece en `index.md`. `AGENTS.md` y los skills nombran el `TEMA.md` de cada tema.

## ADR-05 · Hay dos `index.md`: el de `agents_docs/` marca el bundle y el de la wiki es la entrada

**Contexto:** OKF identifica un bundle por el `index.md` de su raíz, con `okf_version`, y el bundle es `agents_docs/` (ADR-01), que tiene la wiki, los planes y `OKF.md`. Al empezar una tarea, un agente necesita el resumen del proyecto y la lista de páginas de la wiki; los planes no cuentan cómo es ahora el proyecto, y `OKF.md` solo hace falta para escribir.

**Decisión:** hay dos índices. `agents_docs/index.md` es el único con frontmatter: identifica el bundle y lista sus tres partes (la wiki, `OKF.md` y `planes/`). [wiki/index.md](../index.md) tiene el resumen del proyecto y la lista de páginas de la wiki, y es el que `AGENTS.md` manda cargar al empezar cualquier tarea, junto con `wiki-read.md`. Cada índice lista lo que hay en su carpeta.

**Alternativas descartadas:**
- Que `AGENTS.md` mande entrar por `agents_docs/index.md`: añade una lectura en cada tarea solo para llegar al índice de la wiki, y lo único nuevo que se ve son los planes y `OKF.md`, que no hacen falta para empezar.
- Un solo índice en `agents_docs/`, con el resumen y las páginas de la wiki: lista páginas que no están en su carpeta, mezcla la wiki, que se mantiene, con los planes, que no se mantienen, y deja la wiki sin una entrada propia.
- Que `AGENTS.md` mande cargar los dos: dos lecturas fijas, y el contenido sigue repartido.

**Consecuencias:** `agents_docs/index.md` no lo lee ningún agente al empezar una tarea: está para OKF, y solo cambia si cambian las partes del bundle. Quien escribe llega a `OKF.md` desde `wiki-update.md`, y los planes los encuentran los skills `do-plan` y `do-plan-aplicar`. Los temas siguen la misma idea de no añadir índices de carpeta: se abren por su `TEMA.md` (ADR-04).
