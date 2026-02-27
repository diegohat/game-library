#!/bin/bash
set -e

LOG_FILE="/tmp/on-create.log"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

log "🚀 Iniciando on-create..."

# ── Git safe directory ─────────────────────────────────────────
git config --global --add safe.directory "/workspaces/${LOCAL_WORKSPACE_FOLDER_BASENAME}"
log "✅ Git safe directory configurado"

log "🎉 on-create concluído! Log: $LOG_FILE"
