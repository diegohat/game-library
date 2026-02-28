# Guia Completo do Ambiente — Game Library Tracker

> Este documento explica **tudo** sobre o ambiente de desenvolvimento deste projeto.
> Escrito para quem está começando e quer entender não apenas o _como_, mas o **porquê**
> de cada decisão.

---

## Índice

1. [Visão Geral do Projeto](#1-visão-geral-do-projeto)
2. [Stack Tecnológica](#2-stack-tecnológica)
3. [O que é um Dev Container e por que usamos](#3-o-que-é-um-dev-container-e-por-que-usamos)
4. [Anatomia do Dev Container](#4-anatomia-do-dev-container)
5. [Docker Compose — Os Serviços](#5-docker-compose--os-serviços)
6. [Shell Scripts do Ciclo de Vida](#6-shell-scripts-do-ciclo-de-vida)
7. [Banco de Dados — PostgreSQL](#7-banco-de-dados--postgresql)
8. [Flyway — Migrações de Banco](#8-flyway--migrações-de-banco)
9. [Backend — Spring Boot](#9-backend--spring-boot)
10. [Frontend — Angular](#10-frontend--angular)
11. [Proxy — Como o Frontend fala com o Backend](#11-proxy--como-o-frontend-fala-com-o-backend)
12. [Ambientes: dev, stg, prd](#12-ambientes-dev-stg-prd)
13. [Husky, Lint-Staged e Git Hooks](#13-husky-lint-staged-e-git-hooks)
14. [EditorConfig e Prettier](#14-editorconfig-e-prettier)
15. [ESLint — Qualidade de Código](#15-eslint--qualidade-de-código)
16. [.gitignore — O que NÃO vai pro repositório](#16-gitignore--o-que-não-vai-pro-repositório)
17. [Makefile — Atalhos de Comando](#17-makefile--atalhos-de-comando)
18. [CI/CD — GitHub Actions](#18-cicd--github-actions)
19. [Dependabot — Atualização Automática](#19-dependabot--atualização-automática)
20. [Extensões do VS Code](#20-extensões-do-vs-code)
21. [Segurança e Boas Práticas](#21-segurança-e-boas-práticas)
22. [Troubleshooting](#22-troubleshooting)

---

## 1. Visão Geral do Projeto

O **Game Library Tracker** é uma aplicação full-stack para catalogar e acompanhar
sua biblioteca de jogos. Você pode adicionar jogos, marcar como "Jogando", "Completo",
"Backlog" ou "Abandonado", e dar notas pessoais.

A arquitetura é simples e clássica:

```
┌─────────────┐     HTTP/JSON     ┌─────────────┐      SQL       ┌──────────┐
│   Angular   │ ◄──────────────► │ Spring Boot │ ◄────────────► │ Postgres │
│  (frontend) │      :4200        │  (backend)  │     :5432      │  (banco) │
└─────────────┘                   └─────────────┘                └──────────┘
     SPA                           REST API                      Relacional
```

- O **frontend** (Angular) é uma Single Page Application (SPA) que roda no browser
- O **backend** (Spring Boot) é uma API REST que processa as requisições
- O **banco** (PostgreSQL) persiste os dados

---

## 2. Stack Tecnológica

| Tecnologia     | Versão | Para que serve                                        |
| -------------- | ------ | ----------------------------------------------------- |
| Java           | 21 LTS | Linguagem do backend                                  |
| Spring Boot    | 4.0    | Framework web para a API REST                         |
| Maven          | 3.9+   | Gerenciador de dependências e build do Java           |
| Angular        | 19     | Framework frontend (SPA)                              |
| TypeScript     | 5.7    | Linguagem tipada que compila para JavaScript          |
| Node.js        | LTS    | Runtime para rodar o Angular CLI e ferramentas        |
| PostgreSQL     | 17     | Banco de dados relacional                             |
| Flyway         | 11     | Controle de versão do schema do banco                 |
| Docker         | —      | Containers para isolar o ambiente                     |
| Dev Containers | —      | Especificação para ambientes reproduzíveis no VS Code |

### Por que essas versões?

- **Java 21** é a versão LTS mais recente — suporte de longo prazo
- **Spring Boot 4** traz melhorias significativas (Jakarta EE 10, virtual threads)
- **Angular 19** é a versão estável atual com `@if`/`@for` syntax nativa
- **PostgreSQL 17** é a versão mais recente com melhorias de performance

---

## 3. O que é um Dev Container e por que usamos

### O Problema

Imagina que você entra num time e precisa configurar:

- Java 21 (mas você tem o 17 instalado)
- Node 22 (mas você tem o 18)
- PostgreSQL 17 (mas nunca instalou)
- Maven, Angular CLI, extensões do VS Code...

Cada desenvolvedor tem um OS diferente (macOS, Windows, Linux). Cada um instala
as coisas de um jeito. Resultado: **"Na minha máquina funciona"**.

### A Solução: Dev Containers

Um Dev Container é um **ambiente de desenvolvimento completo dentro de um container Docker**.

```
┌─────────── Seu macOS/Windows/Linux ───────────┐
│                                                │
│  ┌──────────── Docker ───────────────────┐     │
│  │                                       │     │
│  │  ┌─── Dev Container (Ubuntu) ──────┐  │     │
│  │  │                                 │  │     │
│  │  │  Java 21 ✓                      │  │     │
│  │  │  Maven 3.9 ✓                    │  │     │
│  │  │  Node LTS ✓                     │  │     │
│  │  │  psql client ✓                  │  │     │
│  │  │  Extensões VS Code ✓            │  │     │
│  │  │  Seu código (montado) ✓         │  │     │
│  │  └─────────────────────────────────┘  │     │
│  │                                       │     │
│  │  ┌─── PostgreSQL 17 ──────────────┐   │     │
│  │  │  Banco de dados isolado        │   │     │
│  │  └────────────────────────────────┘   │     │
│  └───────────────────────────────────────┘     │
│                                                │
│  VS Code conecta DENTRO do container           │
│  Apenas portas 8080 e 4200 expostas            │
└────────────────────────────────────────────────┘
```

**Benefícios:**

1. **Zero setup na máquina** — só precisa de Docker e VS Code
2. **Mesmo ambiente para todos** — funciona igual no macOS, Windows, Linux
3. **Isolamento total** — nada é instalado no seu sistema
4. **Reproduzível** — o ambiente é definido em código (versionado no Git)
5. **Descartável** — se algo der errado, recria o container do zero

### Como funciona na prática?

1. Você abre o projeto no VS Code
2. O VS Code detecta a pasta `.devcontainer/`
3. Pergunta se quer reabrir no container
4. Constrói o container (primeira vez) ou reutiliza (vezes seguintes)
5. O VS Code reconecta **dentro** do container
6. Pronto — tudo instalado e configurado

---

## 4. Anatomia do Dev Container

O arquivo principal é `.devcontainer/devcontainer.json`. Vamos analisar cada parte:

### Features (ferramentas instaladas)

```jsonc
"features": {
    "ghcr.io/devcontainers/features/java:1": {
        "version": "21",
        "jdkDistro": "ms",
        "installMaven": "true"
    },
    "ghcr.io/devcontainers/features/node:1": {
        "nodeGypDependencies": true,
        "version": "lts"
    },
    "ghcr.io/itsmechlark/features/postgresql:1": {
        "version": "16"
    }
}
```

**Features** são pacotes prontos que instalam ferramentas no container:

- **Java feature**: instala o OpenJDK 21 (distribuição Microsoft) + Maven + SDKMAN
- **Node feature**: instala Node.js LTS + npm
- **PostgreSQL feature**: instala o `psql` client (para acessar o banco via terminal)

> A distribuição "ms" do Java é a Microsoft Build of OpenJDK — otimizada para
> containers e ARM (Apple Silicon M4).

### Portas (forwardPorts)

```jsonc
"forwardPorts": [8080, 4200],
"portsAttributes": {
    "8080": { "label": "Spring Boot API", "onAutoForward": "notify" },
    "4200": { "label": "Angular Dev Server", "onAutoForward": "openBrowser" }
}
```

Essas são as **únicas portas expostas** do container para o seu sistema:

- **8080** — API do Spring Boot (notifica quando ficar disponível)
- **4200** — Angular dev server (abre o browser automaticamente)

O PostgreSQL (5432) **NÃO é exposto** — só é acessível de dentro do container.
Isso é intencional: isolamento total. Nenhum outro programa no seu macOS
consegue acessar o banco.

### Lifecycle Hooks (ciclo de vida)

```jsonc
"initializeCommand": "test -f .devcontainer/.env || cp .devcontainer/.env.example .devcontainer/.env",
"onCreateCommand": "bash .devcontainer/on-create.sh",
"postCreateCommand": "bash .devcontainer/post-create.sh",
"postStartCommand": "bash .devcontainer/post-start.sh"
```

Esses comandos rodam em momentos específicos:

```
 initializeCommand     → Antes de construir o container (roda no HOST)
       │
       ▼
 onCreateCommand       → Logo após criar o container (1ª vez)
       │
       ▼
 postCreateCommand     → Após o container ser criado (instala deps)
       │
       ▼
 postStartCommand      → Toda vez que o container inicia (health checks)
```

Veremos cada script em detalhes na seção 6.

### remoteEnv (variáveis de ambiente)

```jsonc
"remoteEnv": {
    "LOCAL_WORKSPACE_FOLDER_BASENAME": "${localWorkspaceFolderBasename}",
    "SPRING_PROFILES_ACTIVE": "${localEnv:SPRING_PROFILES_ACTIVE:dev}"
}
```

- `LOCAL_WORKSPACE_FOLDER_BASENAME` — nome da pasta do projeto (usado nos scripts)
- `SPRING_PROFILES_ACTIVE` — profile Spring Boot ativo (default: `dev`)

---

## 5. Docker Compose — Os Serviços

O arquivo `docker-compose.yml` define dois serviços:

### Serviço `app` (container de desenvolvimento)

```yaml
app:
    image: mcr.microsoft.com/devcontainers/base:ubuntu
    volumes:
        - ..:/workspaces/${LOCAL_WORKSPACE_FOLDER_BASENAME:-game-library}:cached
    command: sleep infinity
    env_file: .env
    depends_on:
        postgres:
            condition: service_healthy
```

- **image**: Ubuntu base da Microsoft para dev containers
- **volumes**: monta seu código dentro do container (`:cached` para performance no macOS)
- **command: sleep infinity**: mantém o container rodando (o VS Code conecta nele)
- **env_file**: carrega variáveis do `.env`
- **depends_on**: só inicia **depois** do PostgreSQL estar saudável

### Serviço `postgres` (banco de dados)

```yaml
postgres:
    image: postgres:17-alpine
    restart: unless-stopped
    volumes:
        - postgres-data:/var/lib/postgresql/data
        - ./sql:/docker-entrypoint-initdb.d:ro
    environment:
        POSTGRES_DB: ${POSTGRES_DB}
        POSTGRES_USER: ${POSTGRES_USER}
        POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    healthcheck:
        test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
        interval: 5s
        timeout: 5s
        retries: 10
```

Pontos importantes:

- **postgres:17-alpine** — Alpine é uma imagem mínima (~80MB vs ~400MB)
- **postgres-data** — volume Docker para persistir dados entre restarts
- **docker-entrypoint-initdb.d** — scripts SQL executados na 1ª vez que o banco inicia
- **healthcheck** — o Docker verifica se o banco está pronto a cada 5 segundos
- **Sem `ports:`** — o PostgreSQL NÃO é exposto para fora do Docker. Somente containers na mesma rede Docker podem acessá-lo

### Como os containers se comunicam?

O Docker Compose cria uma rede interna. Os containers podem se acessar
pelo **nome do serviço**:

```
app  →  postgres:5432    ✅ (rede interna Docker)
host →  postgres:5432    ❌ (porta não exposta)
host →  localhost:8080   ✅ (forwardPorts no devcontainer.json)
host →  localhost:4200   ✅ (forwardPorts no devcontainer.json)
```

É por isso que a connection string do Spring Boot usa `postgres` (nome
do serviço) e não `localhost`:

```
jdbc:postgresql://postgres:5432/gamelibrary
```

### O arquivo `.env`

```dotenv
POSTGRES_DB=gamelibrary
POSTGRES_USER=dev
POSTGRES_PASSWORD=devpassword
```

Esse arquivo tem as credenciais do banco. Ele:

- **NÃO é versionado** (está no `.gitignore`)
- É copiado automaticamente do `.env.example` no `initializeCommand`
- Em produção, as credenciais vêm de secrets managers, não de arquivos

---

## 6. Shell Scripts do Ciclo de Vida

### `on-create.sh` — Executado 1 vez ao criar o container

```bash
#!/bin/bash
set -e  # Para imediatamente se qualquer comando falhar

# Configura o Git para confiar no diretório do workspace
git config --global --add safe.directory "/workspaces/${LOCAL_WORKSPACE_FOLDER_BASENAME}"
```

**Por que `safe.directory`?** O Git, por segurança, recusa operar em pastas
que pertencem a outro usuário. Como o volume é montado do host, o dono pode
não casar. Esse comando diz ao Git: "confia nessa pasta".

### `post-create.sh` — Executado após o container ser criado

Este é o script principal. Ele:

1. **Verifica Maven** — confirma que está instalado (sistema ou wrapper)
2. **Verifica Node** — confirma que está no PATH
3. **Instala dependências do frontend** — `npm install`
4. **Configura Husky** — Git hooks para qualidade de código
5. **Valida variáveis de ambiente** — garante que `POSTGRES_DB`, `POSTGRES_USER`
   e `POSTGRES_PASSWORD` estão definidas
6. **Gera `.vscode/settings.json`** — configura a conexão SQLTools com o banco

O script usa funções `log()` e `log_error()` para registrar tudo em
`/tmp/post-create.log`. Se algo falhar, você pode ver o log.

### `post-start.sh` — Executado TODA vez que o container inicia

```bash
#!/bin/bash
# Verifica se o PostgreSQL está acessível
pg_isready -h postgres -p 5432 -U "${POSTGRES_USER:-dev}"
```

Esse script roda a cada restart. É um health check rápido para confirmar
que o banco está disponível.

### Dicas de Troubleshooting

```bash
# Ver logs de cada etapa:
cat /tmp/on-create.log
cat /tmp/post-create.log
cat /tmp/post-start.log
```

---

## 7. Banco de Dados — PostgreSQL

### O que é o PostgreSQL?

PostgreSQL (ou "Postgres") é o banco de dados relacional mais avançado e
popular do mundo open-source. Ele guarda os dados em **tabelas** com linhas
e colunas, usando **SQL** para consultas.

### Estrutura do banco neste projeto

```sql
-- Tabela de usuários
CREATE TABLE users (
    id          BIGSERIAL PRIMARY KEY,        -- ID autogerado
    username    VARCHAR(50) NOT NULL UNIQUE,   -- Nome único
    email       VARCHAR(100) NOT NULL UNIQUE,  -- Email único
    password    VARCHAR(255) NOT NULL,         -- Hash da senha
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tabela de jogos
CREATE TABLE games (
    id              BIGSERIAL PRIMARY KEY,
    title           VARCHAR(150) NOT NULL,
    platform        VARCHAR(50) NOT NULL,      -- PS5, PC, Switch...
    genre           VARCHAR(50),               -- RPG, Action...
    status          VARCHAR(20) NOT NULL DEFAULT 'BACKLOG',
    personal_rating NUMERIC(3,1),              -- Nota de 0.0 a 10.0
    cover_url       VARCHAR(255),              -- URL da capa
    user_id         BIGINT REFERENCES users(id) ON DELETE CASCADE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### Bancos criados

| Banco              | Para que serve        |
| ------------------ | --------------------- |
| `gamelibrary`      | Desenvolvimento (dev) |
| `gamelibrary_test` | Testes automatizados  |

O banco de test é criado pelo script `.devcontainer/sql/02-create-test-db.sql`
que roda na inicialização do PostgreSQL.

### Como acessar o banco?

**Via terminal** (dentro do container):

```bash
PGPASSWORD=devpassword psql -h postgres -p 5432 -U dev -d gamelibrary
```

**Via VS Code** — a extensão SQLTools é configurada automaticamente pelo
`post-create.sh`. Basta clicar no ícone de banco na barra lateral.

---

## 8. Flyway — Migrações de Banco

### O Problema

Sem controle de versão do banco, cada dev criaria tabelas manualmente.
Um dev adiciona uma coluna, outro não sabe. Deploy quebra em produção.

### A Solução: Flyway

O Flyway é um **controle de versão para o schema do banco**. Funciona assim:

1. Você cria arquivos SQL com nome padronizado: `V1__init.sql`, `V2__add_cover.sql`
2. O Flyway grava quais migrações já foram aplicadas na tabela `flyway_schema_history`
3. Na próxima execução, só aplica as migrações novas

```
Flyway verifica:          O que acontece:
────────────────          ──────────────────────────
V1__init.sql         ──►  Já aplicada ✓ (pula)
V2__add_cover.sql    ──►  Nova! Executa o SQL
V3__add_tags.sql     ──►  Nova! Executa o SQL
```

### Tipos de Migration

| Prefixo | Tipo       | Comportamento                                                 |
| ------- | ---------- | ------------------------------------------------------------- |
| `V`     | Versioned  | Aplicada UMA vez. Nunca mais. Exemplo: `V1__init.sql`         |
| `R`     | Repeatable | Reaplicada quando o conteúdo muda. Exemplo: `R__dev_seed.sql` |

### Onde ficam os arquivos?

```
backend/src/main/resources/
├── db/
│   ├── migration/          ← Migrations de schema (rodam em TODOS os ambientes)
│   │   └── V1__init.sql
│   └── seed/               ← Dados de teste (rodam APENAS no profile dev)
│       └── R__dev_seed.sql
```

### O Seed de Desenvolvimento

O arquivo `R__dev_seed.sql` insere dados fake para você testar:

- 1 usuário: `dev`
- 5 jogos: Hades, TLOU2, Hollow Knight, Cyberpunk 2077, Elden Ring

Ele é um **Repeatable migration** (`R__`), ou seja, se você editar o arquivo,
o Flyway detecta a mudança e reaplica. Útil para adicionar mais dados de teste.

> **Segurança**: O seed só roda no profile `dev` porque o `application-dev.properties`
> incluí `classpath:db/seed` nas locations do Flyway. Os profiles `stg` e `prd`
> usam apenas `classpath:db/migration`.

### Quando o Flyway executa?

O Flyway roda **automaticamente** quando o Spring Boot inicia. A configuração
`spring.flyway.enabled=true` no `application.properties` faz isso.

### Comandos manuais

```bash
make migrate     # Aplica migrações pendentes
make db-reset    # DELETA tudo e recria do zero (⚠️ destrutivo)
```

### Como criar uma nova migration?

1. Crie um arquivo na pasta `db/migration/`:
    ```
    V2__add_achievements_table.sql
    ```
2. Escreva o SQL:
    ```sql
    CREATE TABLE achievements (
        id BIGSERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        game_id BIGINT REFERENCES games(id)
    );
    ```
3. Reinicie o Spring Boot — o Flyway aplica automaticamente

**Regra de ouro**: NUNCA edite uma migration que já foi aplicada. Crie uma nova.

---

## 9. Backend — Spring Boot

### O que é Spring Boot?

Spring Boot é um framework Java que facilita criar APIs REST. Ele cuida de:

- Servidor web (Tomcat embutido)
- Injeção de dependências
- Conexão com banco de dados (JPA/Hibernate)
- Configuração por profiles
- Health checks (Actuator)

### Estrutura do código

```
backend/src/main/java/com/gamelibrary/
├── GameLibraryApplication.java    ← Ponto de entrada (main)
├── config/
│   └── CorsConfig.java           ← Configuração de CORS
├── controller/
│   ├── HelloController.java      ← Endpoint de teste
│   └── GameController.java       ← CRUD de jogos
├── dto/
│   └── GameResponse.java         ← Objeto de resposta (sem dados internos)
├── model/
│   ├── Game.java                 ← Entidade JPA (mapeia tabela games)
│   ├── GameStatus.java           ← Enum de status
│   └── User.java                 ← Entidade JPA (mapeia tabela users)
└── repository/
    ├── GameRepository.java       ← Interface de acesso ao banco
    └── UserRepository.java
```

### Camadas da Arquitetura

```
HTTP Request
    │
    ▼
┌──────────────┐
│  Controller  │  ← Recebe requisição, valida, retorna resposta
├──────────────┤
│  Service     │  ← Lógica de negócio (ainda não temos, mas vai aqui)
├──────────────┤
│  Repository  │  ← Acesso ao banco (Spring Data gera queries)
├──────────────┤
│  Model       │  ← Entidades JPA (mapeiam tabelas SQL)
└──────────────┘
    │
    ▼
  PostgreSQL
```

### Endpoints disponíveis

| Método | URL                | Descrição               |
| ------ | ------------------ | ----------------------- |
| GET    | `/api/hello`       | Hello world + timestamp |
| GET    | `/api/games`       | Lista todos os jogos    |
| GET    | `/api/games/{id}`  | Busca jogo por ID       |
| GET    | `/actuator/health` | Status da aplicação     |

### O que é o `pom.xml`?

O `pom.xml` é o arquivo de configuração do **Maven** — o gerenciador de
dependências do Java (equivalente ao `package.json` no Node.js).

Dependências principais:

| Dependência                      | Para que serve                          |
| -------------------------------- | --------------------------------------- |
| `spring-boot-starter-web`        | API REST + Tomcat embutido              |
| `spring-boot-starter-data-jpa`   | ORM (mapeia objetos Java ↔ tabelas SQL) |
| `spring-boot-starter-validation` | Validação de dados com anotações        |
| `spring-boot-starter-actuator`   | Health checks e métricas                |
| `flyway-core`                    | Migrações automáticas de banco          |
| `spring-boot-flyway`             | Autoconfiguration do Flyway no Boot 4   |
| `postgresql`                     | Driver JDBC do PostgreSQL               |
| `spring-boot-starter-test`       | JUnit 5 + Mockito para testes           |
| `jacoco-maven-plugin`            | Relatório de cobertura de testes        |

### O que é JPA/Hibernate?

**JPA** (Java Persistence API) é uma especificação que mapeia objetos Java
para tabelas do banco. **Hibernate** é a implementação.

Exemplo — a classe `Game.java`:

```java
@Entity                    // "Essa classe é uma tabela"
@Table(name = "games")     // "O nome da tabela é 'games'"
public class Game {

    @Id                    // "Essa é a primary key"
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // "Autoincremento"
    private Long id;

    @Column(nullable = false, length = 150)              // "NOT NULL, max 150 chars"
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)                   // "Muitos games → 1 user"
    @JoinColumn(name = "user_id")                        // "Coluna de FK"
    private User user;
}
```

> `spring.jpa.hibernate.ddl-auto=validate` — o Hibernate **valida** se as
> entidades Java batem com as tabelas SQL, mas **nunca altera** o banco.
> O Flyway é quem controla o schema.

### O que é o Maven Wrapper (`mvnw`)?

O `mvnw` é um script que baixa e usa uma versão específica do Maven, mesmo
que o Maven não esteja instalado. Isso garante que **todos** usam a mesma versão.

```bash
./mvnw compile          # Em vez de: mvn compile
./mvnw spring-boot:run  # Em vez de: mvn spring-boot:run
```

---

## 10. Frontend — Angular

### O que é Angular?

Angular é um framework frontend do Google para criar aplicações web do tipo
**SPA** (Single Page Application). Em vez de o servidor renderizar HTML para
cada página, o Angular carrega uma vez e navega sem reload.

### Estrutura do código

```
frontend/src/
├── main.ts                          ← Bootstrap da aplicação
├── index.html                       ← HTML único (SPA)
├── styles.scss                      ← Estilos globais
├── environments/                    ← Configs por ambiente
│   ├── environment.ts               ← Base (importado no código)
│   ├── environment.development.ts   ← Dev (substituído no ng serve)
│   ├── environment.staging.ts       ← Staging
│   └── environment.production.ts    ← Produção
└── app/
    ├── app.component.ts             ← Componente raiz
    ├── app.config.ts                ← Configuração (providers)
    ├── app.routes.ts                ← Rotas da aplicação
    ├── pages/
    │   └── home/
    │       └── home.component.ts    ← Página inicial (Hello World)
    └── services/
        └── api.service.ts           ← Serviço HTTP para chamar a API
```

### Conceitos chave

**Componentes Standalone** — No Angular 19, cada componente é independente
(não precisa de NgModule). O `HomeComponent` declara seus imports diretamente:

```typescript
@Component({
    selector: 'app-home',
    standalone: true,
    imports: [CommonModule],  // Importa pipes e diretivas
    template: `...`
})
```

**Serviços e Injeção de Dependência** — O `ApiService` é um serviço
injetável que encapsula as chamadas HTTP:

```typescript
@Injectable({ providedIn: "root" }) // Disponível em toda a app
export class ApiService {
    constructor(private http: HttpClient) {}

    getGames(): Observable<Game[]> {
        return this.http.get<Game[]>(`${environment.apiUrl}/games`);
    }
}
```

**app.config.ts** — Configura os providers globais:

```typescript
export const appConfig: ApplicationConfig = {
    providers: [
        provideZoneChangeDetection({ eventCoalescing: true }),
        provideRouter(routes), // Habilita rotas
        provideHttpClient(), // Habilita HttpClient
        provideAnimationsAsync(), // Habilita animações
    ],
};
```

### O que é o `angular.json`?

Equivalente a um "arquivo de projeto". Define:

- Como buildar (builder, output path, assets, styles)
- Configurations por ambiente (development, staging, production)
- Como servir (proxy, portas)
- Como testar (Karma)
- Como lintar (ESLint)

### O que é `package.json`?

A lista de dependências do frontend (equivalente ao `pom.xml` do Java):

```bash
npm install   # Instala tudo listado em dependencies + devDependencies
npm ci        # Instala usando o lock file (mais rápido, reproduzível)
```

---

## 11. Proxy — Como o Frontend fala com o Backend

### O Problema

O Angular roda em `localhost:4200` e a API em `localhost:8080`. Se o frontend
fizer `fetch('http://localhost:8080/api/games')`, o browser bloqueia
por causa do **CORS** (Cross-Origin Resource Sharing).

### A Solução: Proxy do Angular Dev Server

O arquivo `proxy.conf.json`:

```json
{
    "/api": {
        "target": "http://localhost:8080",
        "secure": false,
        "changeOrigin": true
    }
}
```

Isso diz ao Angular: "Quando alguém pedir `/api/*`, repasse para `localhost:8080`".

```
Browser → localhost:4200/api/games → Angular Dev Server → localhost:8080/api/games → Spring Boot
                                         (proxy)
```

No código Angular, basta usar caminhos relativos:

```typescript
this.http.get("/api/games"); // O proxy resolve o resto
```

> **Em produção**, o proxy não existe. O frontend é servido por um
> CDN/Nginx que faz o roteamento. Por isso temos `environment.production.ts`
> com a URL correta da API.

---

## 12. Ambientes: dev, stg, prd

### Por que ter ambientes separados?

| Ambiente | Propósito                            | Quem usa          |
| -------- | ------------------------------------ | ----------------- |
| `dev`    | Desenvolvimento local no container   | Desenvolvedores   |
| `stg`    | Validação antes de produção          | QA / Stakeholders |
| `prd`    | Aplicação real com dados de usuários | Usuários finais   |

### Backend — Spring Boot Profiles

O Spring Boot usa **profiles** para trocar configurações:

```bash
# Rodando com profile dev (padrão):
make run-api                  # ou: make run-api PROFILE=dev

# Rodando com profile staging:
make run-api PROFILE=stg

# Rodando com profile produção:
make run-api PROFILE=prd
```

Cada profile tem seu arquivo de configuração:

| Arquivo                      | O que configura                         |
| ---------------------------- | --------------------------------------- |
| `application.properties`     | Config base (compartilhada por todos)   |
| `application-dev.properties` | Banco local, logs DEBUG, seed, actuator |
| `application-stg.properties` | Banco via env var, logs INFO, sem seed  |
| `application-prd.properties` | Banco via env var, logs WARN, sem seed  |

Diferenças chave:

| Aspecto     | dev                   | stg               | prd              |
| ----------- | --------------------- | ----------------- | ---------------- |
| Banco       | `postgres:5432` local | Via `$ENV_VAR`    | Via `$ENV_VAR`   |
| Flyway Seed | ✅ Sim                | ❌ Não            | ❌ Não           |
| Logs        | DEBUG (verbose)       | INFO              | WARN (mínimo)    |
| Actuator    | Tudo exposto          | health + info     | Apenas health    |
| CORS        | `localhost:4200`      | `stg.example.com` | `example.com`    |
| Credenciais | Hardcoded (dev only)  | Env vars/secrets  | Env vars/secrets |

### Frontend — Angular Configurations

O Angular usa **file replacements** para trocar arquivos de environment:

```bash
# Desenvolvimento (usa environment.development.ts):
ng serve

# Staging (usa environment.staging.ts):
ng build --configuration staging

# Produção (usa environment.production.ts):
ng build --configuration production
```

O mecanismo funciona assim:

```
angular.json:
  "fileReplacements": [{
      "replace": "src/environments/environment.ts",        ← arquivo base importado no código
      "with": "src/environments/environment.production.ts"  ← substituído no build
  }]
```

No código, você sempre importa do mesmo lugar:

```typescript
import { environment } from "../../environments/environment";

// Em dev:  environment.apiUrl = '/api'
// Em stg:  environment.apiUrl = 'https://stg-api.example.com/api'
// Em prd:  environment.apiUrl = '/api'
```

---

## 13. Husky, Lint-Staged e Git Hooks

### O que são Git Hooks?

Git hooks são scripts que rodam automaticamente em eventos do Git:

- `pre-commit` — antes de cada commit
- `pre-push` — antes de cada push
- `commit-msg` — ao escrever a mensagem do commit

### O que é o Husky?

O **Husky** facilita configurar Git hooks via npm. Sem ele, você teria
que editar scripts em `.git/hooks/` manualmente (que não são versionados).

Com Husky, os hooks ficam na pasta `.husky/` e são versionados:

```
.husky/
└── _/
    └── husky.sh       ← Script base do Husky
```

O Husky é configurado pelo `post-create.sh`:

```bash
npx husky install frontend/.husky
```

### O que é o Lint-Staged?

O **lint-staged** roda ferramentas **apenas nos arquivos que estão no staging** (os
que você deu `git add`). Isso é MUITO mais rápido que rodar em tudo.

Configuração em `lint-staged.config.js`:

```javascript
module.exports = {
    "*.{ts,js}": ["eslint --fix", "prettier --write"], // TypeScript/JS → lint + format
    "*.html": ["prettier --write"], // HTML → format
    "*.{scss,css}": ["prettier --write"], // CSS → format
    "*.{json,yml,yaml,md}": ["prettier --write"], // Config/docs → format
};
```

### Fluxo completo de um commit

```
git add .
git commit -m "feat: add game list"
    │
    ▼
 Husky intercepta o pre-commit hook
    │
    ▼
 Lint-staged roda nos arquivos staged:
    ├── arquivo.ts  → eslint --fix → prettier --write
    ├── template.html → prettier --write
    └── styles.scss → prettier --write
    │
    ▼
 Se tudo OK → commit é criado ✅
 Se ESLint falhar → commit é BLOQUEADO ❌
```

### Por que isso é importante?

1. **Código consistente** — ninguém faz commit de código desformatado
2. **Bugs precoces** — ESLint pega problemas antes do code review
3. **Automático** — o dev não precisa lembrar de rodar lint manualmente
4. **Rápido** — só roda nos arquivos alterados, não em tudo

---

## 14. EditorConfig e Prettier

### EditorConfig

O `.editorconfig` define regras básicas de formatação que **qualquer editor** entende
(VS Code, IntelliJ, Vim, etc.):

```editorconfig
[*]
indent_style = space     # Espaços, não tabs
indent_size = 4          # 4 espaços de indentação
end_of_line = lf         # Line feed (Unix/macOS)
charset = utf-8          # Encoding
trim_trailing_whitespace = true
insert_final_newline = true

[Makefile]
indent_style = tab       # Makefiles EXIGEM tabs
```

### Prettier

O **Prettier** é um formatador opinionated — ele decide como formatar o código
e não aceita discussão. Isso elimina debates sobre estilo.

Configuração em `prettier.config.js`:

```javascript
module.exports = {
    singleQuote: true, // 'aspas simples'
    printWidth: 120, // Linha de no máximo 120 caracteres
    tabWidth: 4, // 4 espaços
    semi: true, // Ponto e vírgula no final
    trailingComma: "all", // Vírgula no último item
    endOfLine: "lf", // Unix line endings
};
```

O Prettier formata automaticamente ao salvar no VS Code (`editor.formatOnSave: true`).

---

## 15. ESLint — Qualidade de Código

O **ESLint** analisa o código TypeScript em busca de:

- Variáveis não usadas
- Imports desnecessários
- Padrões problemáticos
- Violações de boas práticas Angular

```bash
make lint           # Roda o ESLint no frontend
```

No VS Code, erros aparecem sublinhados em vermelho em tempo real.

O ESLint também roda automaticamente no `pre-commit` via Husky + lint-staged,
e no CI via GitHub Actions.

---

## 16. .gitignore — O que NÃO vai pro repositório

O `.gitignore` lista arquivos que o Git deve ignorar:

```gitignore
# Credenciais — NUNCA versionar senhas
*.env
!*.env.example            # Exceção: o template pode ir

# Build artifacts — são gerados, não versionados
backend/target/           # Output do Maven
frontend/node_modules/    # Dependências do npm
frontend/dist/            # Build do Angular
frontend/.angular/        # Cache do Angular CLI

# IDE — configurações pessoais de cada dev
.idea/                    # IntelliJ
.vscode/settings.json     # Gerado pelo post-create.sh

# Sistema — arquivos do OS
.DS_Store                 # macOS
Thumbs.db                 # Windows
```

**Regra geral**: se é _gerado_ (pode ser recriado por um comando),
não deveria ser versionado.

---

## 17. Makefile — Atalhos de Comando

O `Makefile` é um task runner simples. Em vez de lembrar comandos longos:

```bash
cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

Você faz:

```bash
make run-api
```

Comandos disponíveis:

| Comando              | O que faz                                 |
| -------------------- | ----------------------------------------- |
| `make help`          | Lista todos os comandos                   |
| `make install`       | Instala dependências do frontend          |
| `make run-api`       | Sobe o Spring Boot (default: profile dev) |
| `make run-frontend`  | Sobe o Angular dev server                 |
| `make run`           | Sobe API + frontend em paralelo           |
| `make test`          | Roda todos os testes                      |
| `make test-api`      | Testes do backend                         |
| `make test-frontend` | Testes do frontend                        |
| `make lint`          | ESLint no frontend                        |
| `make migrate`       | Roda migrações Flyway                     |
| `make db-reset`      | Limpa e recria o banco                    |
| `make verify`        | Build completo com testes (simula CI)     |

### Variável de profile

```bash
make run-api PROFILE=stg    # Roda com profile staging
make run-api PROFILE=prd    # Roda com profile produção
make run-api                # Default: dev
```

---

## 18. CI/CD — GitHub Actions

O arquivo `.github/workflows/ci.yml` define o pipeline de **integração contínua**
que roda a cada push ou PR:

### Job: Backend

1. Sobe um PostgreSQL como service container
2. Instala Java 21
3. Roda `mvn verify` (compile + test + JaCoCo)
4. Salva relatório de cobertura como artifact

### Job: Frontend

1. Instala Node LTS
2. `npm ci` (install determinístico)
3. `npm run lint` (ESLint)
4. `npm test -- --watch=false --browsers=ChromeHeadless`
5. Salva relatório de cobertura como artifact

### Por que CI é importante?

- **Feedback rápido** — sabe se quebrou antes de fazer merge
- **Qualidade** — lint e testes rodam automaticamente
- **Documentação viva** — o pipeline mostra como buildar o projeto
- **Confiança** — ninguém faz merge sem passar nos testes

---

## 19. Dependabot — Atualização Automática

O **Dependabot** (do GitHub) verifica dependências desatualizadas toda
segunda-feira e abre PRs automáticos:

```yaml
- package-ecosystem: maven # Atualiza dependências Java
  directory: /backend

- package-ecosystem: npm # Atualiza dependências Node
  directory: /frontend

- package-ecosystem: github-actions # Atualiza versões das actions
  directory: /
```

Quando uma nova versão sai (ex: Spring Boot 4.0.4), o Dependabot:

1. Cria um branch
2. Atualiza o `pom.xml` ou `package.json`
3. Abre uma PR com o diff
4. O CI roda — se passar, é seguro mergear

---

## 20. Extensões do VS Code

Extensões instaladas automaticamente no Dev Container:

| Extensão                               | Para que serve                  |
| -------------------------------------- | ------------------------------- |
| `vscjava.vscode-java-pack`             | Suporte completo a Java         |
| `vmware.vscode-spring-boot`            | Suporte ao Spring Boot          |
| `vscjava.vscode-spring-initializr`     | Criar projetos Spring rápido    |
| `vscjava.vscode-spring-boot-dashboard` | Dashboard de apps Spring        |
| `angular.ng-template`                  | Suporte a templates Angular     |
| `dbaeumer.vscode-eslint`               | ESLint inline no editor         |
| `esbenp.prettier-vscode`               | Formatação automática           |
| `mtxr.sqltools`                        | Interface gráfica para banco    |
| `mtxr.sqltools-driver-pg`              | Driver PostgreSQL para SQLTools |
| `EditorConfig.EditorConfig`            | Suporte a `.editorconfig`       |
| `eamodio.gitlens`                      | Git avançado (blame, history)   |
| `GitHub.copilot`                       | AI pair programming             |
| `humao.rest-client`                    | Testar APIs direto no VS Code   |

---

## 21. Segurança e Boas Práticas

### Credenciais

- ❌ NUNCA commite senhas, tokens, chaves privadas
- ✅ Use `.env` (não versionado) para dev
- ✅ Use variáveis de ambiente / secrets manager para stg/prd
- ✅ O `.gitignore` bloqueia `*.env`, `*.key`, `*.pem`, `*.jks`

### Schema do Banco

- ❌ NUNCA use `ddl-auto=create` ou `update` em produção
- ✅ Use `ddl-auto=validate` — Hibernate apenas valida, Flyway controla
- ✅ Flyway garante que todos os ambientes têm o mesmo schema

### CORS

- Dev: permite `localhost:4200`
- Staging: permite `stg.gamelibrary.example.com`
- Produção: permite `gamelibrary.example.com`

### Actuator

- Dev: expõe TUDO (para debug)
- Staging: apenas health + info
- Produção: apenas health (sem detalhes)

### Isolamento

- O PostgreSQL NÃO tem porta exposta para o host
- Apenas as portas 8080 (API) e 4200 (frontend) são acessíveis
- Todo o ambiente roda dentro do Docker — nada é instalado na máquina

---

## 22. Troubleshooting

### "Port 8080 already in use"

```bash
# Encontrar e matar o processo
lsof -i :8080
kill -9 <PID>
```

### "Flyway migration failed"

```bash
# Ver o status das migrations
PGPASSWORD=devpassword psql -h postgres -U dev -d gamelibrary -c "SELECT * FROM flyway_schema_history;"

# Resetar o banco completamente
make db-reset
```

### "npm install falhou"

```bash
# Limpar cache e reinstalar
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### "Java class not found / compilation error"

```bash
# Limpar build e recompilar
cd backend
./mvnw clean compile
```

### "Cannot connect to PostgreSQL"

```bash
# Verificar se o banco está rodando
pg_isready -h postgres -p 5432 -U dev

# Ver logs do container PostgreSQL
cat /tmp/post-start.log
```

### "O container não inicia"

```bash
# Ver logs detalhados
cat /tmp/on-create.log
cat /tmp/post-create.log
```

### Reconstruir o container do zero

No VS Code: `Cmd+Shift+P` → **Dev Containers: Rebuild Container**

---

> **Dica final**: quando tiver dúvida, leia o código. Os arquivos de configuração
> deste projeto são documentados com comentários explicando cada decisão.
> A melhor forma de aprender é experimentar — mude algo, veja o que acontece,
> e entenda por quê.
