#!/bin/bash
set -e

LOG_FILE="/tmp/on-create.log"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

# ── Carregar SDKMAN (instalado pela feature Java do devcontainer) ──
export SDKMAN_DIR="${SDKMAN_DIR:-/usr/local/sdkman}"
if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

log "🚀 Iniciando on-create..."

# ── Git safe directory ─────────────────────────────────────────
git config --global --add safe.directory "/workspaces/${LOCAL_WORKSPACE_FOLDER_BASENAME}"
log "✅ Git safe directory configurado"

log "🎉 on-create concluído! Log: $LOG_FILE"
