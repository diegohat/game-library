# 🎮 Game Library Tracker

Aplicação full stack para catalogar e acompanhar sua biblioteca de jogos.

**Stack:** Java 21 · Spring Boot · Angular · PostgreSQL · Flyway

## 🚀 Como rodar

1. Instale o [Docker Desktop](https://www.docker.com/products/docker-desktop) e o [VS Code](https://code.visualstudio.com/)
2. Instale a extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Copie o arquivo de variáveis:
   ```bash
   cp .devcontainer/.env.example .devcontainer/.env
   ```
4. Preencha `.devcontainer/.env` com suas credenciais
5. Abra a paleta (`Cmd+Shift+P`) → **Dev Containers: Reopen in Container**
6. Aguarde o ambiente montar — acompanhe os logs no terminal

## 🛠️ Comandos disponíveis

```bash
make help           # Lista todos os comandos
make run-api        # Sobe o Spring Boot
make run-frontend   # Sobe o Angular
make run            # Sobe tudo em paralelo
make test           # Roda todos os testes
make lint           # Lint do frontend
make migrate        # Roda migrações Flyway
```

## 🌐 Serviços

| Serviço             | URL                                      |
|---------------------|------------------------------------------|
| Spring Boot API     | http://localhost:8080                    |
| Angular Dev Server  | http://localhost:4200                    |
| PostgreSQL          | localhost:5432                           |
| Actuator Health     | http://localhost:8080/actuator/health    |

## 📋 Logs do ambiente

```bash
cat /tmp/on-create.log      # criação do container
cat /tmp/post-create.log    # instalação de ferramentas
cat /tmp/post-start.log     # verificação a cada início
```

## 🗄️ Migrações de banco

As migrações ficam em `backend/src/main/resources/db/migration/` seguindo o padrão Flyway:

```
V1__init.sql
V2__add_cover_url.sql
...
```

Dados de seed para desenvolvimento ficam em `backend/src/main/resources/db/seed/` e são carregados apenas no profile `dev` (via `application-dev.properties`).