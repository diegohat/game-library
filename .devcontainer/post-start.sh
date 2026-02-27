#!/bin/bash

LOG_FILE="/tmp/post-start.log"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

log "🔄 Verificando serviços..."

# ── PostgreSQL ─────────────────────────────────────────────────
if pg_isready -h localhost -p 5432 -U "${POSTGRES_USER:-dev}" >> "$LOG_FILE" 2>&1; then
    log "✅ PostgreSQL disponível"
else
    log "⚠️  PostgreSQL ainda não disponível"
fi

log "🎉 post-start concluído! Log: $LOG_FILE"
