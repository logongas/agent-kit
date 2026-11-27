#!/usr/bin/env bash
# agent-kit-install.sh — instala el agent-kit con enlaces simbólicos.
#
# 1. Siempre: enlaza skills/global/* en ~/.claude/skills (y quita los enlaces
#    del kit que ya no existen).
# 2. En la carpeta desde la que se lanza (si no es $HOME ni el propio kit):
#    pregunta qué grupos (java, angular, gh, glab…) enlazar en ./.claude/skills
#    y, si no existe, si se crea agents_docs/ (wiki) y AGENTS.md desde la plantilla.
#
# Solo toca enlaces que apuntan al kit: una carpeta real o un enlace a otro
# sitio con el mismo nombre se respeta y se avisa.

set -euo pipefail

KIT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
SKILLS="$KIT/skills"
GLOBAL_DEST="$HOME/.claude/skills"
MARCA_INI="# >>> agent-kit (lo gestiona agent-kit-install.sh, no editar) >>>"
MARCA_FIN="# <<< agent-kit <<<"

uso() {
    cat <<EOF
Uso: agent-kit-install.sh [opciones]

Sin opciones pregunta qué grupos instalar en el proyecto de la carpeta actual.

  --grupos java,gh   Grupos a dejar instalados en el proyecto, sin preguntar
                     (--grupos "" quita todos). Disponibles: $(grupos_disponibles | tr '\n' ' ')
  --wiki | --no-wiki Crear o no agents_docs/ y AGENTS.md si no existen, sin preguntar
  --solo-global      Solo actualizar ~/.claude/skills
  -h, --help         Esta ayuda
EOF
}

info() { printf '%s\n' "$*"; }
aviso() { printf '⚠ %s\n' "$*" >&2; }

grupos_disponibles() {
    local d
    for d in "$SKILLS"/*/; do
        [ "$(basename "$d")" = global ] || basename "$d"
    done
}

skills_de_grupo() {
    local d
    for d in "$SKILLS/$1"/*/; do
        [ -f "$d/SKILL.md" ] && printf '%s\n' "${d%/}"
    done
    return 0
}

# Enlaza el skill $1 dentro de la carpeta $2. Devuelve 1 si no lo pudo enlazar.
enlazar() {
    local origen="$1" dest="$2/$(basename "$1")" actual
    if [ -L "$dest" ]; then
        actual="$(readlink "$dest")"
        [ "$actual" = "$origen" ] && return 0
        case "$actual" in
            "$KIT"/*) ln -sfn "$origen" "$dest"; info "  ~ $(basename "$origen") (ahora desde ${origen#"$SKILLS"/})" ;;
            *) aviso "$dest es un enlace a $actual: no lo toco"; return 1 ;;
        esac
    elif [ -e "$dest" ]; then
        aviso "$dest es una carpeta real (¿una copia antigua?): no la toco. Bórrala a mano si quieres usar la del kit"
        return 1
    else
        ln -s "$origen" "$dest"
        info "  + $(basename "$origen")"
    fi
}

# Quita de la carpeta $1 los enlaces al kit que no estén en la lista $2.
limpiar() {
    local dir="$1" queridos="$2" l destino
    [ -d "$dir" ] || return 0
    for l in "$dir"/*; do
        [ -L "$l" ] || continue
        destino="$(readlink "$l")"
        case "$destino" in "$SKILLS"/*) ;; *) continue ;; esac
        if ! grep -Fxq -- "$destino" <<<"$queridos"; then
            rm "$l"
            info "  - $(basename "$l")"
        fi
    done
}

interactivo() { [ -t 0 ] && [ -t 1 ]; }

preguntar_si() { # $1 pregunta, $2 valor por defecto (si|no)
    local r
    if command -v whiptail >/dev/null; then
        if [ "$2" = si ]; then whiptail --title agent-kit --yesno "$1" 10 70
        else whiptail --title agent-kit --defaultno --yesno "$1" 10 70; fi
        return
    fi
    read -r -p "$1 [$([ "$2" = si ] && echo S/n || echo s/N)] " r
    r="${r:-$2}"
    [[ "$r" =~ ^[sSyY] ]]
}

# ---------- opciones ----------

GRUPOS_SET=0; GRUPOS_ARG=""; WIKI_ARG=""; SOLO_GLOBAL=0
while [ $# -gt 0 ]; do
    case "$1" in
        --grupos) [ $# -ge 2 ] || { uso >&2; exit 1; }; GRUPOS_SET=1; GRUPOS_ARG="$2"; shift 2 ;;
        --grupos=*) GRUPOS_SET=1; GRUPOS_ARG="${1#*=}"; shift ;;
        --wiki) WIKI_ARG=si; shift ;;
        --no-wiki) WIKI_ARG=no; shift ;;
        --solo-global) SOLO_GLOBAL=1; shift ;;
        -h|--help) uso; exit 0 ;;
        *) aviso "Opción desconocida: $1"; uso >&2; exit 1 ;;
    esac
done

# ---------- 1. globales ----------

info "Skills globales en $GLOBAL_DEST"
mkdir -p "$GLOBAL_DEST"
queridos=""
while IFS= read -r s; do
    [ -n "$s" ] || continue
    enlazar "$s" "$GLOBAL_DEST" && queridos+="$s"$'\n'
done < <(skills_de_grupo global)
limpiar "$GLOBAL_DEST" "$queridos"

# Tras cada git pull del kit se vuelven a sincronizar los globales.
hook="$KIT/.git/hooks/post-merge"
if [ -d "$KIT/.git/hooks" ] && [ ! -e "$hook" ]; then
    printf '#!/bin/sh\nexec "%s/bin/agent-kit-install.sh" --solo-global\n' "$KIT" > "$hook"
    chmod +x "$hook"
    info "  (instalado el hook post-merge del kit: git pull resincroniza los globales)"
fi

# ---------- 2. proyecto ----------

PROJ="$(pwd -P)"
if [ "$SOLO_GLOBAL" = 1 ]; then exit 0; fi
if [ "$PROJ" = "$(cd "$HOME" && pwd -P)" ]; then info "Estás en \$HOME: solo se actualizan los globales."; exit 0; fi
case "$PROJ/" in "$KIT"/*) info "Estás dentro del kit: solo se actualizan los globales."; exit 0 ;; esac

DEST="$PROJ/.claude/skills"
mapfile -t DISPONIBLES < <(grupos_disponibles)

# Grupos que ya tiene instalados el proyecto
instalados=""
if [ -d "$DEST" ]; then
    for l in "$DEST"/*; do
        [ -L "$l" ] || continue
        d="$(readlink "$l")"
        case "$d" in "$SKILLS"/*/*) g="${d#"$SKILLS"/}"; instalados+="${g%%/*}"$'\n' ;; esac
    done
fi
instalados="$(sort -u <<<"$instalados")"
esta_instalado() { grep -Fxq -- "$1" <<<"$instalados"; }

echo
info "Proyecto: $PROJ"
if [ "$GRUPOS_SET" = 1 ]; then
    elegidos="$(tr ', ' '\n\n' <<<"$GRUPOS_ARG" | sed '/^$/d')"
    while IFS= read -r g; do
        [ -n "$g" ] || continue
        if [ "$g" = global ] || [ ! -d "$SKILLS/$g" ]; then aviso "El grupo '$g' no existe"; exit 1; fi
    done <<<"$elegidos"
elif interactivo; then
    if command -v whiptail >/dev/null; then
        args=()
        for g in "${DISPONIBLES[@]}"; do
            n="$(skills_de_grupo "$g" | wc -l)"
            args+=("$g" "$n skills" "$(esta_instalado "$g" && echo ON || echo OFF)")
        done
        elegidos="$(whiptail --title agent-kit --checklist "Grupos de skills para este proyecto\n(espacio marca, intro acepta)" 18 60 ${#DISPONIBLES[@]} "${args[@]}" 3>&1 1>&2 2>&3)" || { info "Cancelado."; exit 1; }
        elegidos="$(tr -d '"' <<<"$elegidos" | tr ' ' '\n' | sed '/^$/d')"
    else
        elegidos=""
        for g in "${DISPONIBLES[@]}"; do
            if preguntar_si "¿Instalar el grupo $g ($(skills_de_grupo "$g" | wc -l) skills)?" "$(esta_instalado "$g" && echo si || echo no)"; then
                elegidos+="$g"$'\n'
            fi
        done
    fi
else
    elegidos="$instalados"
    info "Sin terminal y sin --grupos: se mantienen los grupos instalados ($(tr '\n' ' ' <<<"$elegidos"))"
fi

info "Skills del proyecto en $DEST"
queridos=""; nombres=""
while IFS= read -r g; do
    [ -n "$g" ] || continue
    while IFS= read -r s; do
        [ -n "$s" ] || continue
        n="$(basename "$s")"
        if grep -Fxq -- "$n" <<<"$nombres"; then aviso "'$n' está en dos grupos: se queda el primero"; continue; fi
        [ -e "$SKILLS/global/$n" ] && aviso "'$n' es también global: sobra uno de los dos"
        mkdir -p "$DEST"
        enlazar "$s" "$DEST" && { queridos+="$s"$'\n'; nombres+="$n"$'\n'; }
    done < <(skills_de_grupo "$g")
done <<<"$elegidos"
limpiar "$DEST" "$queridos"

# Los enlaces apuntan a rutas de esta máquina: fuera del git del proyecto
# (en .git/info/exclude, que no se commitea).
if git -C "$PROJ" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    top="$(git -C "$PROJ" rev-parse --show-toplevel)"
    exclude="$(cd "$PROJ" && realpath -m "$(git rev-parse --git-path info/exclude)")"
    mkdir -p "$(dirname "$exclude")"; touch "$exclude"
    entradas=""
    if [ -d "$DEST" ]; then
        for l in "$DEST"/*; do
            [ -L "$l" ] || continue
            case "$(readlink "$l")" in "$SKILLS"/*) ;; *) continue ;; esac
            rel="$(realpath -s --relative-to="$top" "$l")"
            entradas+="/$rel"$'\n'
            git -C "$top" ls-files --error-unmatch -- "$rel" >/dev/null 2>&1 && aviso "$rel ya está commiteado en el proyecto: quítalo con git rm --cached $rel"
        done
    fi
    tmp="$(mktemp)"
    awk -v ini="$MARCA_INI" -v fin="$MARCA_FIN" '$0==ini{f=1;next} $0==fin{f=0;next} !f' "$exclude" > "$tmp"
    [ -n "$entradas" ] && printf '%s\n%s%s\n' "$MARCA_INI" "$entradas" "$MARCA_FIN" >> "$tmp"
    cat "$tmp" > "$exclude"; rm "$tmp"
fi

# ---------- 3. wiki ----------

if [ -e "$PROJ/agents_docs" ]; then
    info "agents_docs/ ya existe: no se toca."
else
    crear="$WIKI_ARG"
    if [ -z "$crear" ]; then
        if interactivo && preguntar_si "¿Crear agents_docs/ (wiki del proyecto) y AGENTS.md desde la plantilla?" no; then crear=si; else crear=no; fi
    fi
    if [ "$crear" = si ]; then
        cp -r "$KIT/templates/agents_docs" "$PROJ/agents_docs"
        info "  + agents_docs/ (cambia PROYECTO y RESUMEN en agents_docs/index.md y agents_docs/wiki/index.md)"
        if [ -e "$PROJ/AGENTS.md" ]; then
            info "  AGENTS.md ya existe: no se toca. Copia de la plantilla la sección «Documentación del proyecto» si no la tiene."
        else
            cp "$KIT/templates/AGENTS.md" "$PROJ/AGENTS.md"
            info "  + AGENTS.md (rellena RESUMEN, Órdenes y Convenciones)"
        fi
    fi
fi
