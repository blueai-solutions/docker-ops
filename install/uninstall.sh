#!/bin/bash

# =============================================================================
# BLUEAI DOCKER OPS - DESINSTALADOR
# =============================================================================
# Versão: 2.4.2
# Autor: BlueAI Solutions
# Data: 2025-09-05

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
INSTALL_DIR="/usr/local/blueai-docker-ops"
BIN_DIR="/usr/local/bin"
CURRENT_USER=$(whoami)

# Função para log colorido
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

log_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

# Função para mostrar cabeçalho
show_header() {
    echo ""
    echo -e "${CYAN}🐳 BLUEAI DOCKER OPS - DESINSTALADOR${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}Data: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
}

# Função para verificar se é root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Este script não deve ser executado como root"
        log_info "Execute como usuário normal (sudo será solicitado quando necessário)"
        exit 1
    fi
}

# Função para verificar se o sistema está instalado
check_installation() {
    log_step "Verificando instalação..."
    
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_warning "BlueAI Docker Ops não está instalado em $INSTALL_DIR"
        log_info "Nada a desinstalar"
        exit 0
    fi
    
    log_success "Sistema encontrado em: $INSTALL_DIR"
}

# Função para parar serviços
stop_services() {
    log_step "Parando serviços..."
    
    # Parar LaunchAgent se estiver ativo
    if [[ -f "$INSTALL_DIR/scripts/utils/install-launchagent.sh" ]]; then
        if command -v launchctl &> /dev/null; then
            local launchagent_name="com.user.blueai.dockerbackup"
            if launchctl list | grep -q "$launchagent_name"; then
                log_info "Parando LaunchAgent: $launchagent_name"
                launchctl unload "$HOME/Library/LaunchAgents/$launchagent_name.plist" 2>/dev/null || true
                log_success "LaunchAgent parado"
            fi
        fi
    fi
    
    log_success "Serviços parados"
}

# Função para remover links simbólicos
remove_symlinks() {
    log_step "Removendo links simbólicos..."
    
    # Remover link principal
    if [[ -L "$BIN_DIR/blueai-docker-ops" ]]; then
        sudo rm "$BIN_DIR/blueai-docker-ops"
        log_info "Removido: $BIN_DIR/blueai-docker-ops"
    fi
    
    # Remover alias alternativo
    if [[ -L "$BIN_DIR/docker-ops" ]]; then
        sudo rm "$BIN_DIR/docker-ops"
        log_info "Removido: $BIN_DIR/docker-ops"
    fi
    
    log_success "Links simbólicos removidos"
}

# Função para remover arquivos de configuração do usuário
remove_user_configs() {
    log_step "Removendo configurações do usuário..."
    
    # Remover LaunchAgent do usuário
    local user_launchagent="$HOME/Library/LaunchAgents/com.user.blueai.dockerbackup.plist"
    if [[ -f "$user_launchagent" ]]; then
        rm "$user_launchagent"
        log_info "Removido: $user_launchagent"
    fi
    
    # Remover variáveis de ambiente do shell
    local shell_rc=""
    if [[ "$SHELL" == *"zsh" ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bash_profile"
    fi
    
    if [[ -f "$shell_rc" ]]; then
        # Criar backup do arquivo
        local backup_timestamp=$(date '+%Y%m%d_%H%M%S')
        cp "$shell_rc" "$shell_rc.backup.$backup_timestamp"
        log_info "Backup criado: $shell_rc.backup.$backup_timestamp"
        
        # Remover linhas relacionadas ao BlueAI Docker Ops
        sed -i '' '/# BlueAI Docker Ops/,+2d' "$shell_rc" 2>/dev/null || true
        log_info "Variáveis de ambiente removidas do $shell_rc"
    fi
    
    log_success "Configurações do usuário removidas"
}

# Função para remover diretório de instalação
remove_installation() {
    log_step "Removendo diretório de instalação..."
    
    if [[ -d "$INSTALL_DIR" ]]; then
        sudo rm -rf "$INSTALL_DIR"
        log_success "Diretório removido: $INSTALL_DIR"
    fi
}

# Função para limpar logs temporários
cleanup_temp_files() {
    log_step "Limpando arquivos temporários..."
    
    # Remover logs do LaunchAgent
    local temp_logs=(
        "/tmp/docker-backup-launchagent.log"
        "/tmp/docker-backup-launchagent-error.log"
    )
    
    for log_file in "${temp_logs[@]}"; do
        if [[ -f "$log_file" ]]; then
            rm "$log_file"
            log_info "Removido: $log_file"
        fi
    done
    
    log_success "Arquivos temporários limpos"
}

# Função para mostrar informações pós-desinstalação
show_post_uninstall_info() {
    echo ""
    echo -e "${GREEN}🎉 DESINSTALAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
    echo ""
    echo -e "${CYAN}📋 O que foi removido:${NC}"
    echo -e "   • Diretório de instalação: $INSTALL_DIR"
    echo -e "   • Links simbólicos: blueai-docker-ops, docker-ops"
    echo -e "   • LaunchAgent: com.user.blueai.dockerbackup"
    echo -e "   • Variáveis de ambiente do shell"
    echo -e "   • Logs temporários"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
    echo -e "   • Reinicie seu terminal para aplicar as mudanças"
    echo -e "   • Seus dados de backup não foram removidos"
    echo -e "   • Configurações personalizadas foram preservadas"
    echo ""
    echo -e "${CYAN}📚 Para reinstalar:${NC}"
    echo -e "   curl -sSL $REPO_URL/raw/main/install.sh | bash"
    echo ""
}

# Função para confirmar desinstalação
confirm_uninstall() {
    echo ""
    echo -e "${YELLOW}⚠️  ATENÇÃO: Desinstalação do BlueAI Docker Ops${NC}"
    echo ""
    echo -e "${CYAN}📋 O que será removido:${NC}"
    echo -e "   • Sistema completo: $INSTALL_DIR"
    echo -e "   • Comandos: blueai-docker-ops, docker-ops"
    echo -e "   • LaunchAgent e agendamentos"
    echo -e "   • Variáveis de ambiente"
    echo ""
    echo -e "${YELLOW}⚠️  O que NÃO será removido:${NC}"
    echo -e "   • Seus backups de dados Docker"
    echo -e "   • Configurações personalizadas"
    echo -e "   • Logs de operações anteriores"
    echo ""
    
    # Verificar se estamos em um terminal interativo
    if [[ -t 0 ]]; then
        read -p "Tem certeza que deseja continuar? (digite 'sim' para confirmar): " confirmation
        
        if [[ "$confirmation" != "sim" ]]; then
            echo ""
            log_info "Desinstalação cancelada pelo usuário"
            exit 0
        fi
    else
        # Se não estamos em um terminal interativo, usar argumento --force
        if [[ "$1" != "--force" ]]; then
            echo ""
            log_error "Script executado via pipe (curl | bash)"
            log_info "Para desinstalar, use uma das opções:"
            log_info "1. Download e execução local:"
            log_info "   curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/feature/instalacao-rapida/install/uninstall.sh -o uninstall.sh"
            log_info "   chmod +x uninstall.sh && ./uninstall.sh"
            log_info ""
            log_info "2. Forçar desinstalação (sem confirmação):"
            log_info "   curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/feature/instalacao-rapida/install/uninstall.sh | bash -s -- --force"
            exit 1
        else
            log_warning "Desinstalação forçada (sem confirmação)"
        fi
    fi
    
    echo ""
    log_info "Desinstalação confirmada. Prosseguindo..."
}

# Função principal
main() {
    show_header
    
    log_info "Iniciando desinstalação do BlueAI Docker Ops..."
    log_info "Usuário: $CURRENT_USER"
    echo ""
    
    # Verificações
    check_root
    check_installation
    
    # Confirmação
    confirm_uninstall "$@"
    
    echo ""
    log_info "Iniciando processo de desinstalação..."
    echo ""
    
    # Desinstalação
    stop_services
    remove_symlinks
    remove_user_configs
    remove_installation
    cleanup_temp_files
    
    echo ""
    log_info "Desinstalação concluída. Limpeza final..."
    echo ""
    
    # Informações finais
    show_post_uninstall_info
}

# Verificar argumentos
case "${1:-}" in
    --help|-h)
        echo "Uso: $0 [OPÇÕES]"
        echo ""
        echo "OPÇÕES:"
        echo "  --help, -h     Mostrar esta ajuda"
        echo "  --version, -v  Mostrar versão"
        echo "  --force, -f    Desinstalar sem confirmação"
        echo ""
        echo "EXEMPLO:"
        echo "  $0              # Desinstalação interativa"
        echo "  $0 --force      # Desinstalação forçada"
        exit 0
        ;;
    --version|-v)
        echo "BlueAI Docker Ops - Desinstalador v2.4.0"
        exit 0
        ;;
    --force|-f)
        # Desinstalação forçada (pular confirmação)
        show_header
        log_info "Desinstalação forçada iniciada..."
        check_root
        check_installation
        stop_services
        remove_symlinks
        remove_user_configs
        remove_installation
        cleanup_temp_files
        show_post_uninstall_info
        exit 0
        ;;
    "")
        # Desinstalação normal
        ;;
    *)
        log_error "Opção desconhecida: $1"
        log_info "Use --help para ver as opções disponíveis"
        exit 1
        ;;
esac

# Executar desinstalação
main "$@"
