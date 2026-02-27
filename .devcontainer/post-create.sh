#!/bin/bash
set -e

LOG_FILE="/tmp/post-create.log"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
log_error() { echo "[$(date '+%H:%M:%S')] ❌ ERRO: $1" | tee -a "$LOG_FILE" >&2; }

log "🚀 Iniciando post-create..."

# ── Maven ─────────────────────────────────────────────────────
log "Verificando Maven..."
if ! mvn --version >> "$LOG_FILE" 2>&1; then
    log_error "Maven não encontrado ou falhou."
    exit 1
fi
log "✅ Maven OK"

# ── Node ──────────────────────────────────────────────────────
log "Verificando Node..."
if ! node --version >> "$LOG_FILE" 2>&1; then
    log_error "Node não encontrado ou falhou."
    exit 1
fi
log "✅ Node OK"

# ── Angular CLI ───────────────────────────────────────────────
log "Verificando Angular CLI local..."
FRONTEND_DIR="/workspaces/${LOCAL_WORKSPACE_FOLDER_BASENAME}/frontend"
if [ -f "$FRONTEND_DIR/node_modules/.bin/ng" ]; then
    log "✅ Angular CLI local OK"
else
    log "⚠️  Angular CLI local não encontrado — será instalado com npm ci"
fi
if [ -f "$FRONTEND_DIR/package.json" ]; then
    log "Instalando dependências do frontend..."
    if ! npm ci --prefix "$FRONTEND_DIR" >> "$LOG_FILE" 2>&1; then
        log_error "Falha ao instalar dependências do frontend."
        exit 1
    fi
    log "✅ Dependências do frontend OK"

    log "Configurando Husky..."
    REPO_ROOT="/workspaces/${LOCAL_WORKSPACE_FOLDER_BASENAME}"
    if ! (cd "$REPO_ROOT" && npx --prefix "$FRONTEND_DIR" husky install frontend/.husky) >> "$LOG_FILE" 2>&1; then
        log "⚠️  Husky não configurado (frontend ainda não inicializado?)"
    else
        log "✅ Husky OK"
    fi
else
    log "⚠️  frontend/package.json não encontrado — pulando npm ci e Husky"
fi

# ── Validação das variáveis de ambiente ───────────────────────
log "Validando variáveis de ambiente..."
MISSING=()
[ -z "$POSTGRES_DB" ]       && MISSING+=("POSTGRES_DB")
[ -z "$POSTGRES_USER" ]     && MISSING+=("POSTGRES_USER")
[ -z "$POSTGRES_PASSWORD" ] && MISSING+=("POSTGRES_PASSWORD")

if [ ${#MISSING[@]} -gt 0 ]; then
    log_error "Variáveis ausentes no .env: ${MISSING[*]}"
    log_error "Copie .devcontainer/.env.example para .devcontainer/.env e preencha os valores."
    exit 1
fi
log "✅ Variáveis de ambiente OK"

# ── Geração do .vscode/settings.json ─────────────────────────
log "Gerando .vscode/settings.json..."
mkdir -p /workspaces/${LOCAL_WORKSPACE_FOLDER_BASENAME}/.vscode

cat > /workspaces/${LOCAL_WORKSPACE_FOLDER_BASENAME}/.vscode/settings.json << EOF
{
    "sqltools.connections": [
        {
            "name": "Game Library (dev)",
            "driver": "PostgreSQL",
            "host": "localhost",
            "port": 5432,
            "database": "${POSTGRES_DB}",
            "username": "${POSTGRES_USER}",
            "password": "${POSTGRES_PASSWORD}"
        }
    ]
}
EOF

if [ $? -ne 0 ]; then
    log_error "Falha ao gerar .vscode/settings.json"
    exit 1
fi
log "✅ .vscode/settings.json gerado"

log ""
log "🎉 Ambiente pronto! Log completo em: $LOG_FILE"
