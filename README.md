# agent-kit

Skills y herramientas para ser usados por los agentes de IA (Claude Code y OpenCode).

## Estructura

```
skills/
├── global/     → enlazados en ~/.claude/skills (todos los proyectos)
├── java/       → enlazados en ./.claude/skills del proyecto que los elija
├── angular/
├── gh/
└── glab/
templates/
├── agents_docs/   → se copia al proyecto (wiki OKF y planes)
└── AGENTS.md      → se copia al proyecto si no tiene
bin/
└── agent-kit-install.sh
```

Un grupo nuevo es una carpeta nueva en `skills/`. Un skill es una carpeta con su `SKILL.md`.

- **Skills**: se **enlazan** (enlace simbólico). Si editas un skill aquí, se ve en todos los proyectos al momento.
- **Plantillas**: se **copian** una vez y cada proyecto las rellena. No se sobrescriben nunca.

OpenCode lee `~/.claude/skills` y `.claude/skills`, así que no hay que configurar nada para él.

## Instalación (una vez por máquina)

```bash
git clone https://github.com/logongas/agent-kit.git ~/Documentos/desarrollo/agent-kit
ln -s ~/Documentos/desarrollo/agent-kit/bin/agent-kit-install.sh ~/bin/agent-kit-install.sh
agent-kit-install.sh --solo-global
```

## Uso

Desde la carpeta de un proyecto:

```bash
agent-kit-install.sh                          # pregunta grupos y wiki
agent-kit-install.sh --grupos java,gh --wiki  # sin preguntas
agent-kit-install.sh --grupos ""              # quita los grupos del proyecto
```

Cada vez que se lanza:

1. Sincroniza `~/.claude/skills` con `skills/global/`: añade los nuevos y quita los enlaces a skills que ya no existen.
2. En el proyecto:
   - Enlaza en `./.claude/skills` los grupos elegidos, proponiendo marcados los que ya tiene, y quita los enlaces de los grupos desmarcados.
   - Añade los enlaces a `.git/info/exclude`, para que no entren en el git del proyecto.
3. Si el proyecto no tiene `agents_docs/`, pregunta si crearlo, junto con `AGENTS.md`, desde la plantilla.

Solo toca enlaces que apuntan al kit. Una carpeta real o un enlace a otro sitio con el mismo nombre se deja como está y se avisa.

Al lanzarse por primera vez instala un hook `post-merge` en el kit: después de cada `git pull` se resincronizan los globales solos. En los proyectos, los skills editados ya se ven al momento por el enlace. Solo hay que volver a lanzar el script en un proyecto cuando se añade o se borra un skill de alguno de sus grupos.
