.PHONY: help run-api run-frontend run test-api test-frontend test lint install

help: ## Mostra os comandos disponíveis
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Instala dependências do frontend
	cd frontend && npm ci

run-api: ## Sobe o Spring Boot em modo dev
	cd backend && mvn spring-boot:run -Dspring-boot.run.profiles=dev

run-frontend: ## Sobe o Angular dev server
	cd frontend && ng serve --open

run: ## Sobe API e frontend em paralelo
	make run-api & make run-frontend

test-api: ## Roda testes do backend
	cd backend && mvn test

test-frontend: ## Roda testes do frontend
	cd frontend && npm test -- --watch=false --browsers=ChromeHeadless

test: ## Roda todos os testes
	make test-api && make test-frontend

lint: ## Roda ESLint no frontend
	cd frontend && npm run lint

migrate: ## Roda migrações Flyway manualmente
	cd backend && mvn flyway:migrate -Dspring-boot.run.profiles=dev
