# =============================================================================
# Makefile - BlueAI Docker Ops
# =============================================================================
# Autor: BlueAI Solutions
# Versão: 1.0.0
# Descrição: Automação de desenvolvimento, teste e deploy
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
    $(warning ⚠️  Configuração não encontrada. Execute 'make config-clean' primeiro.)
    SYSTEM_NAME := $(PROJECT_NAME)
    SYSTEM_DESCRIPTION := Sistema automatizado de backup para containers Docker
    SYSTEM_AUTHOR := BlueAI Solutions
    SYSTEM_LICENSE := MIT
else
    PROJECT_NAME := $(SYSTEM_NAME)
    PROJECT_VERSION := $(APP_VERSION)
endif

# Cores para output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Funções de log
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

# Target padrão
.PHONY: help
help: ## Mostrar esta ajuda
	@echo "$(PROJECT_NAME) - Makefile de Automação"
	@echo "======================================"
	@echo "Versão: $(PROJECT_VERSION)"
	@echo "Branch: $(GIT_BRANCH)"
	@echo "Commit: $(GIT_COMMIT)"
	@echo ""
	@echo "Targets disponíveis:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# =============================================================================
# DESENVOLVIMENTO
# =============================================================================

.PHONY: dev-setup
dev-setup: ## Configurar ambiente de desenvolvimento
	$(call log_info,"Configurando ambiente de desenvolvimento...")
	@chmod +x blueai-docker-ops.sh
	@chmod +x scripts/**/*.sh
	@chmod +x install/*.sh
	$(call log_success,"Ambiente de desenvolvimento configurado!")

.PHONY: test
test: ## Executar testes do sistema
	$(call log_info,"Executando testes do sistema...")
	@./scripts/utils/test-system.sh
	$(call log_success,"Testes concluídos!")

.PHONY: test-notifications
test-notifications: ## Testar sistema de notificações
	$(call log_info,"Testando notificações...")
	@./scripts/notifications/test-notifications.sh
	$(call log_success,"Teste de notificações concluído!")

.PHONY: validate
validate: ## Validar sintaxe dos scripts
	$(call log_info,"Validando sintaxe dos scripts...")
	@find scripts/ -name "*.sh" -exec bash -n {} \;
	@bash -n blueai-docker-ops.sh
	@bash -n install/*.sh
	$(call log_success,"Validação de sintaxe concluída!")

# =============================================================================
# CONFIGURAÇÃO
# =============================================================================

.PHONY: config-clean
config-clean: ## Limpar configurações locais usando templates
	$(call log_info,"Limpando configurações locais...")
	@./scripts/utils/config-setup.sh --force
	$(call log_success,"Configurações limpas criadas!")

.PHONY: config-interactive
config-interactive: ## Configuração interativa do sistema
	$(call log_info,"Iniciando configuração interativa...")
	@./scripts/utils/config-setup.sh --interactive
	$(call log_success,"Configuração interativa concluída!")

.PHONY: config-email
config-email: ## Configurar email (use EMAIL=seu@email.com)
	$(call log_info,"Configurando email...")
	@if [ -z "$(EMAIL)" ]; then \
		echo "Use: make config-email EMAIL=seu@email.com"; \
		exit 1; \
	fi
	@./scripts/utils/config-setup.sh --email "$(EMAIL)"
	$(call log_success,"Email configurado: $(EMAIL)")

.PHONY: config-schedule
config-schedule: ## Configurar horário (use HOUR=2 MIN=30)
	$(call log_info,"Configurando horário...")
	@if [ -z "$(HOUR)" ] || [ -z "$(MIN)" ]; then \
		echo "Use: make config-schedule HOUR=2 MIN=30"; \
		exit 1; \
	fi
	@./scripts/utils/config-setup.sh --schedule "$(HOUR)" --schedule-min "$(MIN)"
	$(call log_success,"Horário configurado: $(HOUR):$(MIN)")

# =============================================================================
# LAUNCHAGENT
# =============================================================================

.PHONY: launchagent-install
launchagent-install: ## Instalar LaunchAgent
	$(call log_info,"Instalando LaunchAgent...")
	@./scripts/install/install-launchagent.sh install
	$(call log_success,"LaunchAgent instalado!")

.PHONY: launchagent-status
launchagent-status: ## Verificar status do LaunchAgent
	$(call log_info,"Verificando status do LaunchAgent...")
	@./scripts/install/install-launchagent.sh status

.PHONY: launchagent-schedule
launchagent-schedule: ## Configurar horário do LaunchAgent
	$(call log_info,"Configurando horário do LaunchAgent...")
	@./scripts/install/install-launchagent.sh schedule

.PHONY: launchagent-test
launchagent-test: ## Testar LaunchAgent
	$(call log_info,"Testando LaunchAgent...")
	@./scripts/install/install-launchagent.sh test-launchagent

.PHONY: launchagent-uninstall
launchagent-uninstall: ## Desinstalar LaunchAgent
	$(call log_info,"Desinstalando LaunchAgent...")
	@./scripts/install/install-launchagent.sh uninstall
	$(call log_success,"LaunchAgent desinstalado!")

# =============================================================================
# DESENVOLVIMENTO E RELEASE
# =============================================================================

.PHONY: dev-tools
dev-tools: ## Mostrar ferramentas de desenvolvimento disponíveis
	$(call log_info,"Ferramentas de desenvolvimento:")
	@echo "  📝 Changelog: make changelog-create"
	@echo "  🏷️  Release: make release-create VERSION=2.4.0"
	@echo "  🔢 Version: make version-bump TYPE=minor"
	@echo "  📊 Status: make release-status"

.PHONY: changelog-create
changelog-create: ## Criar nova entrada de changelog
	$(call log_info,"Criando entrada de changelog...")
	@./scripts/dev/changelog-manager.sh create
	$(call log_success,"Entrada de changelog criada!")

.PHONY: release-create
release-create: ## Criar nova release (use VERSION=2.4.0)
	$(call log_info,"Criando release...")
	@if [ -z "$(VERSION)" ]; then \
		echo "Use: make release-create VERSION=2.4.0"; \
		exit 1; \
	fi
	@./scripts/dev/release-manager.sh create-release "$(VERSION)"
	$(call log_success,"Release $(VERSION) criada!")

.PHONY: version-bump
version-bump: ## Incrementar versão (use TYPE=major|minor|patch)
	$(call log_info,"Incrementando versão...")
	@if [ -z "$(TYPE)" ]; then \
		echo "Use: make version-bump TYPE=minor"; \
		exit 1; \
	fi
	@./scripts/dev/release-manager.sh bump-version "$(TYPE)"
	$(call log_success,"Versão incrementada!")

.PHONY: release-status
release-status: ## Verificar status do repositório
	$(call log_info,"Verificando status do repositório...")
	@./scripts/dev/release-manager.sh check-status

# =============================================================================
# LIMPEZA E MANUTENÇÃO
# =============================================================================

.PHONY: clean
clean: ## Limpar arquivos temporários e logs
	$(call log_info,"Limpando arquivos temporários...")
	@find . -name "*.tmp" -delete
	@find . -name "*.bak" -delete
	@find . -name "*.log" -delete
	$(call log_success,"Limpeza concluída!")

.PHONY: clean-configs
clean-configs: ## Limpar configurações e usar templates
	$(call log_info,"Limpando configurações...")
	@./scripts/utils/config-setup.sh --force
	$(call log_success,"Configurações limpas!")

.PHONY: backup-configs
backup-configs: ## Fazer backup das configurações atuais
	$(call log_info,"Fazendo backup das configurações...")
	@mkdir -p config/backups
	@cp config/*.sh config/backups/ 2>/dev/null || true
	$(call log_success,"Backup das configurações criado!")

# =============================================================================
# INSTALAÇÃO E DISTRIBUIÇÃO
# =============================================================================

.PHONY: install-local
install-local: ## Instalar localmente para desenvolvimento
	$(call log_info,"Instalando localmente...")
	@./install/install.sh
	$(call log_success,"Instalação local concluída!")

.PHONY: uninstall-local
uninstall-local: ## Desinstalar instalação local
	$(call log_info,"Desinstalando localmente...")
	@./install/uninstall.sh
	$(call log_success,"Desinstalação local concluída!")

.PHONY: package
package: ## Criar pacote de distribuição local
	$(call log_info,"Criando pacote de distribuição...")
	@mkdir -p dist
	@tar -czf "blueai-docker-ops-$(PROJECT_VERSION).tar.gz" \
		--exclude='.git' \
		--exclude='config/*.sh' \
		--exclude='scripts/dev' \
		--exclude='.github' \
		--exclude='*.tmp' \
		--exclude='*.log' \
		.
	$(call log_success,"Pacote criado: blueai-docker-ops-$(PROJECT_VERSION).tar.gz")

# =============================================================================
# VERIFICAÇÃO E VALIDAÇÃO
# =============================================================================

.PHONY: check
check: validate test ## Validar sintaxe e executar testes
	$(call log_success,"Verificação completa concluída!")

.PHONY: check-all
check-all: check config-clean ## Verificação completa incluindo configurações
	$(call log_success,"Verificação completa com configurações limpas!")

.PHONY: status
status: ## Mostrar status completo do projeto
	$(call log_info,"Status do projeto:")
	@echo "  📋 Nome: $(PROJECT_NAME)"
	@echo "  🏷️  Versão: $(PROJECT_VERSION)"
	@echo "  🌿 Branch: $(GIT_BRANCH)"
	@echo "  🔢 Commit: $(GIT_COMMIT)"
	@echo "  📁 Diretório: $(PWD)"
	@echo ""
	@echo "  📊 Status Git:"
	@git status --short 2>/dev/null || echo "    Não é um repositório Git"
	@echo ""
	@echo "  �� Configurações:"
	@if [ -f "config/version-config.sh" ]; then \
		echo "    ✅ version-config.sh carregado"; \
		echo "      - Sistema: $(SYSTEM_NAME)"; \
		echo "      - Descrição: $(SYSTEM_DESCRIPTION)"; \
		echo "      - Autor: $(SYSTEM_AUTHOR)"; \
		echo "      - Licença: $(SYSTEM_LICENSE)"; \
		echo "      - Agendamento: $(SCHEDULE_DESCRIPTION)"; \
	else \
		echo "    ❌ version-config.sh não encontrado"; \
	fi
	@echo ""
	@echo "  📦 Templates:"
	@ls -la config/templates/*.template.sh 2>/dev/null || echo "    Nenhum template encontrado"
	@echo ""
	@echo "  🔍 Configuração atual:"
	@if [ -f "config/version-config.sh" ]; then \
		echo "    ✅ Configuração carregada do arquivo"; \
	else \
		echo "    ⚠️  Usando valores padrão (execute 'make config-clean')"; \
	fi

# =============================================================================
# AJUDA ESPECÍFICA
# =============================================================================

.PHONY: help-dev
help-dev: ## Ajuda para desenvolvimento
	@echo "🛠️  COMANDOS DE DESENVOLVIMENTO:"
	@echo "  make dev-setup          - Configurar ambiente"
	@echo "  make test               - Executar testes"
	@echo "  make validate           - Validar sintaxe"
	@echo "  make check              - Verificação completa"
	@echo "  make check-all          - Verificação com configurações limpas"

.PHONY: help-config
help-config: ## Ajuda para configuração
	@echo "🔧 COMANDOS DE CONFIGURAÇÃO:"
	@echo "  make config-clean       - Limpar configurações"
	@echo "  make config-interactive - Configuração interativa"
	@echo "  make config-email       - Configurar email"
	@echo "  make config-schedule    - Configurar horário"
	@echo "  make backup-configs     - Backup das configurações"

.PHONY: help-launchagent
help-launchagent: ## Ajuda para LaunchAgent
	@echo "🚀 COMANDOS DO LAUNCHAGENT:"
	@echo "  make launchagent-install   - Instalar"
	@echo "  make launchagent-status    - Ver status"
	@echo "  make launchagent-schedule  - Configurar horário"
	@echo "  make launchagent-test      - Testar"
	@echo "  make launchagent-uninstall - Desinstalar"

.PHONY: help-release
help-release: ## Ajuda para releases
	@echo "🏷️  COMANDOS DE RELEASE:"
	@echo "  make release-create     - Criar release"
	@echo "  make version-bump       - Incrementar versão"
	@echo "  make release-status     - Ver status"
	@echo "  make changelog-create   - Criar changelog"

# =============================================================================
# TARGETS ESPECIAIS
# =============================================================================

.PHONY: all
all: dev-setup check config-clean ## Configuração completa do projeto
	$(call log_success,"Configuração completa concluída!")

.PHONY: quick-start
quick-start: dev-setup config-interactive launchagent-install ## Início rápido
	$(call log_success,"Início rápido concluído!")

.PHONY: deploy-prep
deploy-prep: check-all package ## Preparar para deploy
	$(call log_success,"Projeto preparado para deploy!")

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
	@echo "Templates: config/templates/"
	@echo ""
	@echo "Para mais informações: make help"

# =============================================================================
# TARGETS DE EMERGÊNCIA
# =============================================================================

.PHONY: emergency-clean
emergency-clean: ## Limpeza de emergência (CUIDADO!)
	$(call log_warning,"LIMPEZA DE EMERGÊNCIA!")
	@read -p "Tem certeza? Digite 'EMERGENCY' para confirmar: " confirm; \
	if [ "$$confirm" = "EMERGENCY" ]; then \
		make clean; \
		make clean-configs; \
		rm -rf logs/* reports/* backups/*; \
		$(call log_success,"Limpeza de emergência concluída!"); \
	else \
		$(call log_info,"Limpeza de emergência cancelada"); \
	fi

# =============================================================================
# FIM DO MAKEFILE
# =============================================================================
