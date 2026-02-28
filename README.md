# 🎮 Game Library Tracker

Aplicação full-stack para catalogar e acompanhar sua biblioteca de jogos.

| Camada     | Tecnologia              |
| ---------- | ----------------------- |
| Frontend   | Angular 19 · TypeScript |
| Backend    | Java 21 · Spring Boot 4 |
| Banco      | PostgreSQL 17           |
| Migrations | Flyway                  |
| Infra Dev  | Dev Containers · Docker |

---

## Pré-requisitos

| Ferramenta                                                                                                        | Versão mínima |
| ----------------------------------------------------------------------------------------------------------------- | ------------- |
| [Docker Desktop](https://www.docker.com/products/docker-desktop)                                                  | 4.x           |
| [VS Code](https://code.visualstudio.com/)                                                                         | 1.85+         |
| Extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) | —             |

> **Nota:** Nenhuma instalação de Java, Node, Maven ou PostgreSQL é necessária na sua máquina.
> Todo o ambiente roda isolado dentro do Dev Container.

---

## 🚀 Setup Inicial

```bash
# 1. Clone o repositório
git clone git@github.com:seu-usuario/game-library.git
cd game-library

# 2. Copie as variáveis de ambiente (feito automaticamente ao abrir o container)
cp .devcontainer/.env.example .devcontainer/.env

# 3. Abra no VS Code
code .
```

4. Abra a paleta de comandos (`Cmd+Shift+P` no macOS / `Ctrl+Shift+P` no Linux/Windows)
5. Selecione **Dev Containers: Reopen in Container**
6. Aguarde o build do container (primeira vez leva ~2–3 min)

Ao abrir, o ambiente automaticamente:

- Instala Java 21, Maven, Node LTS e PostgreSQL client
- Instala as dependências do frontend (`npm install`)
- Configura o Husky para hooks de pre-commit
- Gera o `.vscode/settings.json` com conexão ao banco
- Verifica a saúde do PostgreSQL

---

## 🛠️ Comandos Disponíveis

```bash
make help               # Lista todos os comandos
```

### Desenvolvimento

```bash
make run-api            # Sobe o Spring Boot (profile dev)
make run-frontend       # Sobe o Angular dev server (com proxy para API)
make run                # Sobe API + frontend em paralelo
```

### Testes

```bash
make test-api           # Testes do backend (JUnit + JaCoCo)
make test-frontend      # Testes do frontend (Karma + Jasmine)
make test               # Todos os testes
make verify             # Build completo com testes (CI-like)
```

### Lint & Format

```bash
make lint               # ESLint no frontend
```

> O **Prettier** formata automaticamente ao salvar (`editor.formatOnSave: true`).
> O **Husky** + **lint-staged** rodam lint e format antes de cada commit.

### Banco de Dados

```bash
make migrate            # Roda migrações Flyway
make db-reset           # Limpa e recria o banco (clean + migrate)
```

### Build para Deploy

```bash
make build-frontend     # Build de produção
make build-frontend-stg # Build de staging
```

---

## 🌐 URLs e Portas

| Serviço            | URL                                   | Porta |
| ------------------ | ------------------------------------- | ----- |
| Spring Boot API    | http://localhost:8080                 | 8080  |
| Angular Dev Server | http://localhost:4200                 | 4200  |
| Actuator Health    | http://localhost:8080/actuator/health | —     |
| API Hello          | http://localhost:8080/api/hello       | —     |
| API Games          | http://localhost:8080/api/games       | —     |

> **Isolamento:** Apenas as portas 8080 e 4200 são expostas ao host.
> O PostgreSQL é acessível somente de dentro do container via hostname `postgres`.

---

## 🔀 Ambientes (dev / stg / prd)

### Backend (Spring Boot Profiles)

O profile ativo é controlado por:

1. Variável `SPRING_PROFILES_ACTIVE` no `.devcontainer/.env`
2. Parâmetro `PROFILE` no Makefile
3. Flag `-Dspring-boot.run.profiles=xxx` via Maven

```bash
# Rodar com profile staging
make run-api PROFILE=stg

# Rodar com profile produção
make run-api PROFILE=prd
```

| Profile | Banco                     | Flyway Seed | Logs  | Actuator      |
| ------- | ------------------------- | ----------- | ----- | ------------- |
| `dev`   | PostgreSQL local          | ✅ Sim      | DEBUG | Tudo exposto  |
| `stg`   | Via env vars (CI/Secrets) | ❌ Não      | INFO  | health + info |
| `prd`   | Via env vars (CI/Secrets) | ❌ Não      | WARN  | Apenas health |

### Frontend (Angular Configurations)

```bash
# Desenvolvimento (padrão)
make run-frontend

# Build staging
make build-frontend-stg

# Build produção
make build-frontend
```

Os arquivos de environment ficam em `frontend/src/environments/`:

- `environment.development.ts` — usado em `ng serve`
- `environment.staging.ts` — APIs de staging
- `environment.production.ts` — APIs de produção

---

## 📁 Estrutura do Projeto

```
.
├── .devcontainer/           # Dev Container config
│   ├── devcontainer.json    # Features, extensões, lifecycle hooks
│   ├── docker-compose.yml   # App + PostgreSQL services
│   ├── .env.example         # Template de variáveis
│   ├── on-create.sh         # Git safe directory
│   ├── post-create.sh       # Instala deps, valida env, gera settings
│   ├── post-start.sh        # Verifica saúde dos serviços
│   └── sql/                 # Scripts de init do PostgreSQL
├── backend/                 # Spring Boot API
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/gamelibrary/
│       │   │   ├── config/          # CORS, etc.
│       │   │   ├── controller/      # REST controllers
│       │   │   ├── dto/             # Data Transfer Objects
│       │   │   ├── model/           # JPA entities
│       │   │   └── repository/      # Spring Data repos
│       │   └── resources/
│       │       ├── application.properties       # Config base
│       │       ├── application-dev.properties   # Dev profile
│       │       ├── application-stg.properties   # Staging profile
│       │       ├── application-prd.properties   # Production profile
│       │       └── db/
│       │           ├── migration/   # Flyway migrations (V1, V2...)
│       │           └── seed/        # Dev seed data (apenas dev)
│       └── test/
├── frontend/                # Angular SPA
│   ├── angular.json
│   ├── proxy.conf.json      # Proxy /api → backend:8080
│   ├── package.json
│   └── src/
│       ├── app/
│       │   ├── pages/       # Page components
│       │   ├── services/    # HTTP services
│       │   ├── app.config.ts
│       │   └── app.routes.ts
│       └── environments/    # Environment configs
├── .github/
│   ├── workflows/ci.yml     # CI pipeline
│   └── dependabot.yml       # Dependency updates
├── Makefile                 # Task runner
└── README.md
```

---

## 🗄️ Banco de Dados & Migrações

### Flyway Migrations

As migrações ficam em `backend/src/main/resources/db/migration/` seguindo o padrão:

```
V1__init.sql          # Schema inicial (users, games)
V2__add_xxx.sql       # Próxima migração
```

### Seed de Desenvolvimento

Dados de seed ficam em `backend/src/main/resources/db/seed/`:

```
R__dev_seed.sql       # Repeatable migration — recarregado quando alterado
```

> O seed é carregado **apenas** no profile `dev` via `application-dev.properties`.

### Executando Manualmente

```bash
make migrate      # Aplica migrações pendentes
make db-reset     # Limpa tudo e recria (⚠️ destrutivo)
```

---

## 📋 Logs do Ambiente

```bash
cat /tmp/on-create.log      # Criação do container
cat /tmp/post-create.log    # Instalação e configuração
cat /tmp/post-start.log     # Verificação a cada início
```

---

## 🧪 Testes & Cobertura

### Backend

- **Framework:** JUnit 5 + Spring Boot Test
- **Cobertura:** JaCoCo (relatório em `backend/target/site/jacoco/`)
- **Profile de teste:** `application-test.properties` → banco `gamelibrary_test`

### Frontend

- **Framework:** Karma + Jasmine
- **Cobertura:** karma-coverage (relatório em `frontend/coverage/`)
- **Browsers:** ChromeHeadless (CI-compatible)

---

## 🔒 Segurança

- Credenciais **nunca** versionadas (`.env` no `.gitignore`)
- Profiles `stg` e `prd` leem credenciais de **variáveis de ambiente**
- CORS configurado por profile
- Actuator restrito em staging/produção
- `spring.jpa.hibernate.ddl-auto=validate` — Flyway controla o schema

---

## 📦 CI/CD

O pipeline roda em GitHub Actions (`.github/workflows/ci.yml`):

1. **Backend:** Build + Test com PostgreSQL service container
2. **Frontend:** Lint + Test com ChromeHeadless
3. Artefatos de cobertura salvos como artifacts

O **Dependabot** monitora atualizações semanais de:

- Maven (backend)
- npm (frontend)
- GitHub Actions

---

## 📝 Licença

Veja o arquivo [LICENSE](LICENSE).
