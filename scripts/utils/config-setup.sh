#!/bin/bash

# =============================================================================
# Configurador Automático - BlueAI Docker Ops
# =============================================================================
# Autor: BlueAI Solutions
# Versão: 1.0.0
# Descrição: Script para configurar automaticamente o sistema usando templates
# =============================================================================

# Sourcing de configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATES_DIR="$PROJECT_ROOT/config/templates"
CONFIG_DIR="$PROJECT_ROOT/config"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de log
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Função para mostrar ajuda
show_help() {
    cat << EOF
Uso: $0 [OPÇÕES]

OPÇÕES:
  --help, -h           Mostrar esta ajuda
  --force, -f          Forçar configuração sem confirmação
  --interactive, -i    Configuração interativa
  --email EMAIL        Configurar email automaticamente
  --schedule HOUR      Configurar horário do backup (0-23)
  --schedule-min MIN   Configurar minuto do backup (0-59)

EXEMPLOS:
  $0                                    # Configuração padrão
  $0 --email seu@email.com              # Configurar email
  $0 --schedule 2 --schedule-min 30     # Backup às 2:30 da manhã
  $0 --interactive                      # Configuração interativa
  $0 --force                            # Configuração forçada

DESCRIÇÃO:
  Este script configura automaticamente o BlueAI Docker Ops usando
  templates limpos, garantindo que não haja informações específicas
  do ambiente local no pacote de distribuição.
EOF
}

# Função para verificar se arquivo existe
check_template() {
    local template="$1"
    if [ ! -f "$template" ]; then
        log_error "Template não encontrado: $template"
        return 1
    fi
    return 0
}

# Função para configurar arquivo de versão
setup_version_config() {
    local template="$TEMPLATES_DIR/version-config.template.sh"
    local target="$CONFIG_DIR/version-config.sh"
    
    log_info "Configurando arquivo de versão..."
    
    if ! check_template "$template"; then
        return 1
    fi
    
    # Copiar template
    cp "$template" "$target"
    
    # Configurar horário se especificado
    if [ -n "$SCHEDULE_HOUR" ]; then
        sed -i.bak "s/SCHEDULE_HOUR=2/SCHEDULE_HOUR=$SCHEDULE_HOUR/" "$target"
        log_info "Horário configurado para $SCHEDULE_HOUR:00"
    fi
    
    if [ -n "$SCHEDULE_MIN" ]; then
        sed -i.bak "s/SCHEDULE_MINUTE=0/SCHEDULE_MINUTE=$SCHEDULE_MIN/" "$target"
        log_info "Minuto configurado para :$SCHEDULE_MIN"
    fi
    
    # Atualizar descrição do horário
    if [ -n "$SCHEDULE_HOUR" ] && [ -n "$SCHEDULE_MIN" ]; then
        local description
        if [ "$SCHEDULE_HOUR" -eq 0 ]; then
            description="meia-noite"
        elif [ "$SCHEDULE_HOUR" -lt 12 ]; then
            description="${SCHEDULE_HOUR}:${SCHEDULE_MIN} da manhã"
        elif [ "$SCHEDULE_HOUR" -eq 12 ]; then
            description="meio-dia"
        else
            local hour_pm=$((SCHEDULE_HOUR - 12))
            description="${hour_pm}:${SCHEDULE_MIN} da tarde"
        fi
        
        sed -i.bak "s/SCHEDULE_DESCRIPTION=\"2:00 da manhã\"/SCHEDULE_DESCRIPTION=\"$description\"/" "$target"
        log_info "Descrição do horário: $description"
    fi
    
    # Remover arquivo de backup
    rm -f "${target}.bak"
    
    log_success "Arquivo de versão configurado: $target"
}

# Função para configurar arquivo de notificações
setup_notification_config() {
    local template="$TEMPLATES_DIR/notification-config.template.sh"
    local target="$CONFIG_DIR/notification-config.sh"
    
    log_info "Configurando arquivo de notificações..."
    
    if ! check_template "$template"; then
        return 1
    fi
    
    # Copiar template
    cp "$template" "$target"
    
    # Configurar email se especificado
    if [ -n "$EMAIL_ADDRESS" ]; then
        sed -i.bak "s/EMAIL_TO=\"seu-email@exemplo.com\"/EMAIL_TO=\"$EMAIL_ADDRESS\"/" "$target"
        log_info "Email configurado: $EMAIL_ADDRESS"
    fi
    
    # Remover arquivo de backup
    rm -f "${target}.bak"
    
    log_success "Arquivo de notificações configurado: $target"
}

# Função para configurar arquivo de backup
setup_backup_config() {
    local template="$TEMPLATES_DIR/backup-config.template.sh"
    local target="$CONFIG_DIR/backup-config.sh"
    
    log_info "Configurando arquivo de backup..."
    
    if ! check_template "$template"; then
        return 1
    fi
    
    # Verificar se já existe configuração válida
    if [ -f "$target" ]; then
        # Tentar carregar a configuração existente
        if source "$target" 2>/dev/null; then
            # Verificar se é um template (contém comentários de exemplo) ou configuração real
            if grep -q "Exemplo:" "$target" || grep -q "⚠️  CONFIGURE" "$target"; then
                log_info "Arquivo de template encontrado, será substituído"
            elif [ -n "$BACKUP_TARGETS" ] && [ ${#BACKUP_TARGETS[@]} -gt 0 ]; then
                log_info "Configuração de backup existente encontrada com ${#BACKUP_TARGETS[@]} containers configurados"
                log_info "Preservando configuração existente"
                return 0
            else
                log_info "Configuração existente vazia, criando nova"
            fi
        fi
    fi
    
    # Copiar template apenas se necessário
    cp "$template" "$target"
    
    log_success "Arquivo de backup configurado: $target"
    return 0
}

# Função para configurar arquivo de recovery
setup_recovery_config() {
    local template="$TEMPLATES_DIR/recovery-config.template.sh"
    local target="$CONFIG_DIR/recovery-config.sh"
    
    log_info "Configurando arquivo de recovery..."
    
    if ! check_template "$template"; then
        return 1
    fi
    
    # Verificar se já existe configuração válida
    if [ -f "$target" ]; then
        # Tentar carregar a configuração existente
        if source "$target" 2>/dev/null; then
            # Verificar se é um template (contém comentários de exemplo) ou configuração real
            if grep -q "Exemplo:" "$target" || grep -q "⚠️  CONFIGURE" "$target"; then
                log_info "Arquivo de template encontrado, será substituído"
            elif [ -n "$RECOVERY_TARGETS" ] && [ ${#RECOVERY_TARGETS[@]} -gt 0 ]; then
                log_info "Configuração de recovery existente encontrada com ${#RECOVERY_TARGETS[@]} containers configurados"
                log_info "Preservando configuração existente"
                return 0
            else
                log_info "Configuração existente vazia, criando nova"
            fi
        fi
    fi
    
    # Copiar template apenas se necessário
    cp "$template" "$target"
    
    log_success "Arquivo de recovery configurado: $target"
    return 0
}

# Função para configuração interativa
interactive_setup() {
    log_info "Configuração interativa iniciada..."
    
    echo
    echo "🔧 CONFIGURAÇÃO INTERATIVA - BlueAI Docker Ops"
    echo "=============================================="
    
    # Email
    echo
    read -p "📧 Digite seu email para notificações: " email
    if [ -n "$email" ]; then
        EMAIL_ADDRESS="$email"
        log_info "Email configurado: $email"
    fi
    
    # Horário do backup
    echo
    echo "⏰ Configuração do horário do backup:"
    read -p "   Hora (0-23): " hour
    read -p "   Minuto (0-59): " minute
    
    if [ -n "$hour" ] && [ -n "$minute" ]; then
        if [ "$hour" -ge 0 ] && [ "$hour" -le 23 ] && [ "$minute" -ge 0 ] && [ "$minute" -le 59 ]; then
            SCHEDULE_HOUR="$hour"
            SCHEDULE_MIN="$minute"
            log_info "Horário configurado: $hour:$minute"
        else
            log_warning "Horário inválido, usando padrão (2:00 da manhã)"
        fi
    fi
    
    # Confirmação
    echo
    echo "📋 Resumo da configuração:"
    echo "   Email: ${EMAIL_ADDRESS:-não configurado}"
    echo "   Horário: ${SCHEDULE_HOUR:-2}:${SCHEDULE_MIN:-00}"
    echo
    
    read -p "✅ Confirmar configuração? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Configuração cancelada"
        exit 0
    fi
}

# Função para validar parâmetros
validate_params() {
    if [ -n "$SCHEDULE_HOUR" ]; then
        if ! [[ "$SCHEDULE_HOUR" =~ ^[0-9]+$ ]] || [ "$SCHEDULE_HOUR" -lt 0 ] || [ "$SCHEDULE_HOUR" -gt 23 ]; then
            log_error "Hora inválida: $SCHEDULE_HOUR (deve ser 0-23)"
            exit 1
        fi
    fi
    
    if [ -n "$SCHEDULE_MIN" ]; then
        if ! [[ "$SCHEDULE_MIN" =~ ^[0-9]+$ ]] || [ "$SCHEDULE_MIN" -lt 0 ] || [ "$SCHEDULE_MIN" -gt 59 ]; then
            log_error "Minuto inválido: $SCHEDULE_MIN (deve ser 0-59)"
            exit 1
        fi
    fi
    
    if [ -n "$EMAIL_ADDRESS" ]; then
        if ! [[ "$EMAIL_ADDRESS" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            log_error "Email inválido: $EMAIL_ADDRESS"
            exit 1
        fi
    fi
}

# Função para backup das configurações existentes
backup_existing_configs() {
    log_info "Fazendo backup das configurações existentes..."
    
    local backup_dir="$CONFIG_DIR/backups"
    mkdir -p "$backup_dir"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ -f "$CONFIG_DIR/version-config.sh" ]; then
        cp "$CONFIG_DIR/version-config.sh" "$backup_dir/version-config.sh.backup.$timestamp"
        log_info "Backup de version-config.sh criado"
    fi
    
    if [ -f "$CONFIG_DIR/notification-config.sh" ]; then
        cp "$CONFIG_DIR/notification-config.sh" "$backup_dir/notification-config.sh.backup.$timestamp"
        log_info "Backup de notification-config.sh criado"
    fi
}

# Função principal
main() {
    local force=false
    local interactive=false
    
    # Processar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --force|-f)
                force=true
                shift
                ;;
            --interactive|-i)
                interactive=true
                shift
                ;;
            --email)
                EMAIL_ADDRESS="$2"
                shift 2
                ;;
            --schedule)
                SCHEDULE_HOUR="$2"
                shift 2
                ;;
            --schedule-min)
                SCHEDULE_MIN="$2"
                shift 2
                ;;
            *)
                log_error "Argumento desconhecido: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Verificar se estamos no diretório correto
    if [ ! -d "$TEMPLATES_DIR" ]; then
        log_error "Diretório de templates não encontrado: $TEMPLATES_DIR"
        log_error "Execute este script do diretório raiz do projeto"
        exit 1
    fi
    
    # Validação de parâmetros
    validate_params
    
    # Configuração interativa
    if [ "$interactive" = true ]; then
        interactive_setup
    fi
    
    # Confirmação (se não for forçada)
    if [ "$force" != true ]; then
        echo
        echo "🔧 CONFIGURAÇÃO AUTOMÁTICA - BlueAI Docker Ops"
        echo "=============================================="
        echo "Este script irá:"
        echo "✅ Preservar configurações existentes válidas"
        echo "✅ Criar configurações apenas quando necessário"
        echo "✅ Fazer backup das configurações existentes"
        echo "✅ Configurar email e horário conforme especificado"
        echo "✅ Garantir que não haja informações locais"
        echo
        
        read -p "✅ Continuar? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Configuração cancelada"
            exit 0
        fi
    fi
    
    # Backup das configurações existentes
    backup_existing_configs
    
    # Configurar arquivos
    if ! setup_version_config; then
        log_error "Falha ao configurar arquivo de versão"
        exit 1
    fi
    
    if ! setup_notification_config; then
        log_error "Falha ao configurar arquivo de notificações"
        exit 1
    fi
    
    if ! setup_backup_config; then
        log_error "Falha ao configurar arquivo de backup"
        exit 1
    fi
    
    if ! setup_recovery_config; then
        log_error "Falha ao configurar arquivo de recuperação"
        exit 1
    fi
    
    # Relatório final
    echo
    log_success "CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!"
    echo
    echo "📋 ARQUIVOS CONFIGURADOS:"
    echo "   ✅ config/version-config.sh"
    echo "   ✅ config/notification-config.sh"
    echo "   ✅ config/backup-config.sh"
    echo "   ✅ config/recovery-config.sh"
    echo
    echo "📁 BACKUPS CRIADOS:"
    echo "   📂 config/backups/"
    echo
    echo "🔧 PRÓXIMOS PASSOS:"
    echo "   1. Verificar configurações: cat config/*.sh"
    echo "   2. Testar sistema: ./blueai-docker-ops.sh --help"
    echo "   3. Configurar volumes: ./blueai-docker-ops.sh config"
    echo "   4. Verificar volumes: ./blueai-docker-ops.sh volumes"
    echo "   5. Verificar serviços: ./blueai-docker-ops.sh services"
    echo
    echo "🎯 Configurações preservadas ou criadas conforme necessário!"
}

# Executar função principal
main "$@"
