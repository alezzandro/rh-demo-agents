#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/.cursor/skills"
RULES_SRC="$SCRIPT_DIR/.cursor/rules"
SKILLS_DST="$HOME/.cursor/skills"
RULES_DST="$HOME/.cursor/rules"

USE_SYMLINKS=false
INSTALL_RULES=false
FORCE=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install Red Hat demo agent skills into your Cursor environment.

Options:
  --link        Create symlinks instead of copies (auto-updates with git pull)
  --rules       Also install Cursor rules to ~/.cursor/rules/
  --force       Overwrite existing skills/rules without prompting
  --uninstall   Remove all rh-* skills and rules from Cursor directories
  -h, --help    Show this help message

Examples:
  $(basename "$0")              # Copy skills to ~/.cursor/skills/
  $(basename "$0") --link       # Symlink skills (recommended for contributors)
  $(basename "$0") --link --rules  # Symlink skills and rules
  $(basename "$0") --uninstall  # Remove installed skills and rules
EOF
}

log() { echo "  $1"; }
ok()  { echo "  [OK] $1"; }
err() { echo "  [ERROR] $1" >&2; }

uninstall() {
    echo "Uninstalling Red Hat demo skills and rules..."
    local count=0

    for dir in "$SKILLS_DST"/rh-*; do
        if [ -e "$dir" ] || [ -L "$dir" ]; then
            rm -rf "$dir"
            log "Removed $(basename "$dir")"
            ((count++))
        fi
    done

    for file in "$RULES_DST"/rh-*.mdc; do
        if [ -e "$file" ] || [ -L "$file" ]; then
            rm -f "$file"
            log "Removed $(basename "$file")"
            ((count++))
        fi
    done

    if [ "$count" -eq 0 ]; then
        log "Nothing to uninstall."
    else
        ok "Removed $count items."
    fi
}

install_item() {
    local src="$1" dst="$2" name="$3"

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ "$FORCE" = true ]; then
            rm -rf "$dst"
        else
            log "Skipping $name (already exists, use --force to overwrite)"
            return
        fi
    fi

    if [ "$USE_SYMLINKS" = true ]; then
        ln -s "$src" "$dst"
        ok "$name (symlinked)"
    else
        cp -r "$src" "$dst"
        ok "$name (copied)"
    fi
}

install() {
    echo "Installing Red Hat demo skills..."
    echo ""

    mkdir -p "$SKILLS_DST"

    if [ ! -d "$SKILLS_SRC" ]; then
        err "Skills source not found at $SKILLS_SRC"
        err "Make sure you're running this from the rh-demo-agents repo root."
        exit 1
    fi

    echo "Skills -> $SKILLS_DST"
    for skill_dir in "$SKILLS_SRC"/rh-*; do
        if [ -d "$skill_dir" ]; then
            local name
            name="$(basename "$skill_dir")"
            install_item "$skill_dir" "$SKILLS_DST/$name" "$name"
        fi
    done

    if [ "$INSTALL_RULES" = true ]; then
        echo ""
        echo "Rules -> $RULES_DST"
        mkdir -p "$RULES_DST"

        for rule_file in "$RULES_SRC"/rh-*.mdc; do
            if [ -f "$rule_file" ]; then
                local name
                name="$(basename "$rule_file")"
                install_item "$rule_file" "$RULES_DST/$name" "$name"
            fi
        done
    fi

    echo ""
    echo "Installation complete."
    echo ""
    echo "Skills are now available globally in Cursor."
    if [ "$USE_SYMLINKS" = true ]; then
        echo "Using symlinks -- run 'git pull' in this repo to update."
    else
        echo "Using copies -- re-run this script to pick up updates."
    fi
    if [ "$INSTALL_RULES" = false ]; then
        echo ""
        echo "Tip: Run with --rules to also install the rh-demo-conventions rule."
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --link)       USE_SYMLINKS=true; shift ;;
        --rules)      INSTALL_RULES=true; shift ;;
        --force)      FORCE=true; shift ;;
        --uninstall)  uninstall; exit 0 ;;
        -h|--help)    usage; exit 0 ;;
        *)            err "Unknown option: $1"; usage; exit 1 ;;
    esac
done

install
