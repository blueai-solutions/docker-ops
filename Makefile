# =============================================================================
# BLUEAI DOCKER OPS - MAKEFILE DE DESENVOLVIMENTO
# =============================================================================
# Foco: Desenvolvimento, build, testes e deploy
# Sistema: Use ./blueai-docker-ops.sh para operações do sistema
# =============================================================================

# Sourcing da configuração centralizada
-include config/version-config.sh

# Variáveis com fallback para valores padrão
PROJECT_NAME ?= BlueAI Docker Ops
PROJECT_VERSION ?= $(shell cat VERSION 2>/dev/null || echo 'unknown')
GIT_BRANCH ?= $(shell git branch --show-current 2>/dev/null || echo 'unknown')
GIT_COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo 'unknown')

# Verificar se a configuração foi carregada
ifeq ($(SYSTEM_NAME),)
    $(warning ⚠️  Configuração não encontrada. Execute 'make config' primeiro.)
    SYSTEM_NAME := $(PROJECT_NAME)
    SYSTEM_DESCRIPTION := Sistema automatizado de backup para containers Docker
    SYSTEM_AUTHOR := BlueAI Solutions
    SYSTEM_LICENSE := MIT
else
    PROJECT_NAME := $(SYSTEM_NAME)
    PROJECT_VERSION := $(APP_VERSION)
endif

# Cores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Funções de logging
define log_info
	@echo -e "$(BLUE)ℹ️  $(1)$(NC)"
endef

define log_success
	@echo -e "$(GREEN)✅ $(1)$(NC)"
endef

define log_warning
	@echo -e "$(YELLOW)⚠️  $(1)$(NC)"
endef

define log_error
	@echo -e "$(RED)❌ $(1)$(NC)"
endef

# =============================================================================
# DESENVOLVIMENTO E BUILD
# =============================================================================

.PHONY: help
help: ## Mostrar ajuda de desenvolvimento
	@echo "$(PROJECT_NAME) - Makefile de Desenvolvimento"
	@echo "=========================================="
	@echo "Versão: $(PROJECT_VERSION)"
	@echo ""
	@echo "🛠️  DESENVOLVIMENTO:"
	@echo "  make dev-setup          - Configurar ambiente de desenvolvimento"
	@echo "  make test               - Executar testes"
	@echo "  make validate           - Validar sintaxe"
	@echo "  make check              - Verificação completa"
	@echo ""
	@echo "📦 BUILD E PACKAGING:"
	@echo "  make package            - Criar pacote de distribuição"
	@echo "  make clean              - Limpar arquivos temporários"
	@echo ""
	@echo "🏷️  RELEASES:"
	@echo "  make release            - Criar release"
	@echo "  make release-validate   - Validar release"
	@echo "  make release-notes      - Gerar release notes"
	@echo ""
	@echo "📤 DEPLOY:"
	@echo "  make deploy             - Deploy completo"
	@echo "  make deploy-prepare     - Preparar deploy"
	@echo "  make deploy-package     - Criar pacote"
	@echo "  make deploy-test        - Testar pacote"
	@echo ""
	@echo "🚀 COMANDOS DE SISTEMA (Alias):"
	@echo "  make setup              # Alias para: ./blueai-docker-ops.sh setup"
	@echo "  make config             # Alias para: ./blueai-docker-ops.sh config"
	@echo "  make schedule           # Alias para: ./blueai-docker-ops.sh schedule"
	@echo "  make status             # Alias para: ./blueai-docker-ops.sh status"
	@echo ""
	@echo "📋 SISTEMA PRINCIPAL:"
	@echo "  ./blueai-docker-ops.sh --help    # Ver todos os comandos do sistema"
	@echo "  ./blueai-docker-ops.sh setup     # Configuração inicial"
	@echo "  ./blueai-docker-ops.sh config    # Configuração interativa"
	@echo "  ./blueai-docker-ops.sh schedule  # Agendamento"
	@echo "  ./blueai-docker-ops.sh volumes   # Ver volumes"
	@echo "  ./blueai-docker-ops.sh backup    # Executar backup"
	@echo "  ./blueai-docker-ops.sh recovery  # Executar recovery"
	@echo "  ./blueai-docker-ops.sh status    # Status do sistema"

# =============================================================================
# DESENVOLVIMENTO
# =============================================================================

.PHONY: dev-setup
dev-setup: ## Configurar ambiente de desenvolvimento
	$(call log_info,"🛠️  Configurando ambiente de desenvolvimento...")
	@chmod +x blueai-docker-ops.sh
	@chmod +x scripts/**/*.sh
	@chmod +x install/*.sh
	$(call log_success,"✅ Ambiente de desenvolvimento configurado!")

.PHONY: test
test: ## Executar testes do sistema
	$(call log_info,"🧪 Executando testes do sistema...")
	@./scripts/utils/test-system.sh
	$(call log_success,"✅ Testes concluídos!")

.PHONY: validate
validate: ## Validar sintaxe dos scripts
	$(call log_info,"🔍 Validando sintaxe dos scripts...")
	@find scripts/ -name "*.sh" -exec bash -n {} \;
	@bash -n blueai-docker-ops.sh
	@bash -n install/*.sh
	$(call log_success,"✅ Validação de sintaxe concluída!")

.PHONY: check
check: validate test ## Validar sintaxe e executar testes
	$(call log_success,"✅ Verificação completa concluída!")

# =============================================================================
# BUILD E PACKAGING
# =============================================================================

.PHONY: package
package: ## Criar pacote de distribuição
	$(call log_info,"📦 Criando pacote de distribuição...")
	@mkdir -p dist
	@tar -czf "blueai-docker-ops-$(PROJECT_VERSION).tar.gz" \
		--exclude='.git' \
		--exclude='config/*.sh' \
		--exclude='scripts/dev' \
		--exclude='.github' \
		--exclude='*.tmp' \
		--exclude='*.log' \
		.
	$(call log_success,"✅ Pacote criado: blueai-docker-ops-$(PROJECT_VERSION).tar.gz")

.PHONY: clean
clean: ## Limpar arquivos temporários e logs
	$(call log_info,"🧹 Limpando arquivos temporários...")
	@find . -name "*.tmp" -delete
	@find . -name "*.bak" -delete
	@find . -name "*.log" -delete
	@rm -rf dist/
	$(call log_success,"✅ Limpeza concluída!")

# =============================================================================
# RELEASES
# =============================================================================

.PHONY: release
release: ## Criar release (use VERSION=2.4.0)
	$(call log_info,"🏷️  Criando release...")
	@if [ -z "$(VERSION)" ]; then \
		echo "Use: make release VERSION=2.4.0"; \
		exit 1; \
	fi
	@./scripts/dev/release-manager.sh create-release "$(VERSION)"
	$(call log_success,"✅ Release $(VERSION) criada!")

.PHONY: release-validate
release-validate: ## Validar release antes de publicar
	$(call log_info,"🔍 Validando release...")
	@echo "✅ Verificando sintaxe dos scripts..."
	@make validate
	@echo "✅ Verificando testes..."
	@make test
	$(call log_success,"✅ Release validado com sucesso!")

.PHONY: release-notes
release-notes: ## Gerar release notes do changelog
	$(call log_info,"📋 Gerando release notes do changelog...")
	@if [ -f "docs/changelog/v$(PROJECT_VERSION).md" ]; then \
		echo "✅ Usando changelog: docs/changelog/v$(PROJECT_VERSION).md"; \
		{ \
			echo "# Release Notes - $(SYSTEM_NAME) v$(PROJECT_VERSION)"; \
			echo ""; \
			echo "**$(SYSTEM_NAME)** - $(SYSTEM_DESCRIPTION)"; \
			echo "**Autor:** $(SYSTEM_AUTHOR)"; \
			echo "**Licença:** $(SYSTEM_LICENSE)"; \
			echo ""; \
			echo "---"; \
			echo ""; \
			tail -n +2 "docs/changelog/v$(PROJECT_VERSION).md"; \
		} > RELEASE_NOTES.md; \
		echo "✅ Release notes criados: RELEASE_NOTES.md"; \
	else \
		echo "❌ Changelog não encontrado para v$(PROJECT_VERSION)"; \
		exit 1; \
	fi

# =============================================================================
# DEPLOY
# =============================================================================

.PHONY: deploy
deploy: package ## Deploy completo
	$(call log_info,"🚀 Executando deploy...")
	@echo "📦 Pacote criado: blueai-docker-ops-$(PROJECT_VERSION).tar.gz"
	@echo "📤 Pronto para upload para GitHub releases"
	$(call log_success,"✅ Deploy concluído!")

.PHONY: deploy-prepare
deploy-prepare: ## Preparar pacote de distribuição
	$(call log_info,"📦 Preparando pacote de distribuição...")
	@echo "🧹 Limpando diretório dist..."
	@rm -rf dist
	@mkdir -p dist
	@echo "📁 Copiando arquivos essenciais..."
	@cp -r scripts/core/ dist/scripts/
	@cp -r scripts/backup/ dist/scripts/
	@cp -r scripts/notifications/ dist/scripts/
	@cp -r scripts/logging/ dist/scripts/
	@mkdir -p dist/scripts/utils
	@cp scripts/utils/container-configurator.sh dist/scripts/utils/
	@cp scripts/utils/recovery-configurator.sh dist/scripts/utils/
	@cp scripts/utils/test-system.sh dist/scripts/utils/
	@cp scripts/utils/config-setup.sh dist/scripts/utils/
	@cp -r scripts/install/ dist/
	@mkdir -p dist/config
	@cp -r config/templates/ dist/config/
	@cp docs/README.md dist/docs/
	@cp docs/guia-inicio-rapido.md dist/docs/
	@cp docs/comandos.md dist/docs/
	@cp docs/arquitetura.md dist/docs/
	@cp docs/solucao-problemas.md dist/docs/
	@cp docs/launchagent.md dist/docs/
	@cp docs/configuracao.md dist/docs/
	@mkdir -p dist/docs/changelog
	@cp docs/changelog/CHANGELOG.md dist/docs/changelog/ 2>/dev/null || true
	@cp docs/changelog/v*.md dist/docs/changelog/ 2>/dev/null || true
	@cp blueai-docker-ops.sh dist/
	@cp VERSION dist/
	@cp README.md dist/
	@echo "✅ Pacote preparado em: dist/"

.PHONY: deploy-package
deploy-package: ## Criar arquivo compactado para distribuição
	$(call log_info,"📦 Criando arquivo compactado...")
	@if [ ! -d "dist" ]; then \
		echo "❌ Diretório dist não encontrado!"; \
		echo "📋 Execute: make deploy-prepare"; \
		exit 1; \
	fi
	@cd dist && tar -czf "../blueai-docker-ops-$(PROJECT_VERSION).tar.gz" .
	@echo "✅ Pacote criado: blueai-docker-ops-$(PROJECT_VERSION).tar.gz"
	@echo "📊 Tamanho: $(shell du -h "blueai-docker-ops-$(PROJECT_VERSION).tar.gz" | cut -f1)"

.PHONY: deploy-test
deploy-test: ## Testar pacote de distribuição localmente
	$(call log_info,"🧪 Testando pacote de distribuição...")
	@if [ ! -f "blueai-docker-ops-$(PROJECT_VERSION).tar.gz" ]; then \
		echo "❌ Pacote não encontrado!"; \
		echo "📋 Execute: make deploy-package"; \
		exit 1; \
	fi
	@echo "📁 Criando diretório de teste..."
	@mkdir -p test-deploy
	@cd test-deploy && tar -xzf "../blueai-docker-ops-$(PROJECT_VERSION).tar.gz"
	@echo "✅ Pacote extraído em: test-deploy/"
	@echo "📋 Estrutura do pacote:"
	@find test-deploy/ -type f | head -20
	@echo "🧪 Testando scripts principais..."
	@cd test-deploy && ./blueai-docker-ops.sh --help > /dev/null && echo "✅ Script principal OK" || echo "❌ Script principal com problemas"
	@echo "🧹 Limpando teste..."
	@rm -rf test-deploy
	$(call log_success,"✅ Teste do pacote concluído!")

# =============================================================================
# COMANDOS DE SISTEMA (ALIAS PARA O SCRIPT PRINCIPAL)
# =============================================================================

.PHONY: setup
setup: ## Alias para configuração inicial do sistema
	$(call log_info,"🚀 Executando configuração inicial via script principal...")
	@./blueai-docker-ops.sh setup

.PHONY: config
config: ## Alias para configuração do sistema
	$(call log_info,"🔧 Executando configuração via script principal...")
	@./blueai-docker-ops.sh config

.PHONY: schedule
schedule: ## Alias para agendamento do sistema
	$(call log_info,"🕐 Executando agendamento via script principal...")
	@./blueai-docker-ops.sh schedule

.PHONY: status
status: ## Alias para status do sistema
	$(call log_info,"📊 Executando status via script principal...")
	@./blueai-docker-ops.sh status

# =============================================================================
# TARGETS ESPECIAIS
# =============================================================================

.PHONY: all
all: dev-setup check package ## Configuração completa de desenvolvimento
	$(call log_success,"🎉 Configuração de desenvolvimento concluída!")

.PHONY: quick-dev
quick-dev: dev-setup test ## Início rápido para desenvolvimento
	$(call log_success,"🚀 Início rápido para desenvolvimento concluído!")

# =============================================================================
# INFORMAÇÕES DO PROJETO
# =============================================================================

.PHONY: info
info: ## Informações do projeto
	@echo "$(PROJECT_NAME)"
	@echo "=================="
	@echo "Versão: $(PROJECT_VERSION)"
	@echo "Branch: $(GIT_BRANCH)"
	@echo "Commit: $(GIT_COMMIT)"
	@echo "Data: $(shell date)"
	@echo ""
	@echo "Documentação: docs/"
	@echo "Scripts: scripts/"
	@echo "Configurações: config/"
	@echo ""
	@echo "Para desenvolvimento: make help"
	@echo "Para sistema: ./blueai-docker-ops.sh --help"

# =============================================================================
# FIM DO MAKEFILE
# =============================================================================
