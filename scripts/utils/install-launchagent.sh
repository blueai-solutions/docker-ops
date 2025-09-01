#!/bin/bash

# Script para instalar e gerenciar o LaunchAgent de backup Docker
# Autor: BlueAI Solutions
# Data: $(date)

set -e

LAUNCHAGENT_NAME="com.user.blueai.dockerbackup"
LAUNCHAGENT_FILE="com.user.blueai.dockerbackup.plist"
LAUNCHAGENT_PATH="$HOME/Library/LaunchAgents/$LAUNCHAGENT_FILE"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carregar configuração de versão
VERSION_CONFIG="$(cd "$SCRIPT_DIR/../.." && pwd)/config/version-config.sh"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
if [ -f "$VERSION_CONFIG" ]; then
    source "$VERSION_CONFIG"
else
    echo "❌ Arquivo de configuração de versão não encontrado"
    exit 1
fi

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Função para mostrar ajuda
show_help() {
    echo "🐳 Gerenciador de LaunchAgent para Backup Docker"
    echo "================================================"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  install    - Instalar o LaunchAgent"
    echo "  uninstall  - Remover o LaunchAgent"
    echo "  start      - Iniciar o LaunchAgent"
    echo "  stop       - Parar o LaunchAgent"
    echo "  status     - Verificar status do LaunchAgent"
    echo "  logs       - Mostrar logs do LaunchAgent"
    echo "  test       - Testar o script de backup"
    echo "  schedule   - Alterar horário do backup"
    echo "  test-launchagent - Testar LaunchAgent (execução em 60s)"
    echo "  help       - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 install    # Instalar LaunchAgent"
    echo "  $0 status     # Verificar status"
    echo "  $0 test       # Testar backup manualmente"
}

# Função para verificar se LaunchAgent está instalado
is_installed() {
    [ -f "$LAUNCHAGENT_PATH" ]
}

# Função para verificar se LaunchAgent está carregado
is_loaded() {
    launchctl list | grep -q "$LAUNCHAGENT_NAME"
}

# Função para gerar arquivo plist dinamicamente
generate_plist() {
    local plist_content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>$LAUNCHAGENT_NAME</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>$PROJECT_ROOT/scripts/backup/dynamic-backup.sh</string>
    </array>
    
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Hour</key>
            <integer>$SCHEDULE_HOUR</integer>
            <key>Minute</key>
            <integer>$SCHEDULE_MINUTE</integer>
        </dict>
    </array>
    
    <key>StandardOutPath</key>
    <string>/tmp/docker-backup-launchagent.log</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/docker-backup-launchagent-error.log</string>
    
    <key>WorkingDirectory</key>
    <string>$PROJECT_ROOT</string>
    
    <key>RunAtLoad</key>
    <false/>
    
    <key>KeepAlive</key>
    <false/>
    
    <key>ProcessType</key>
    <string>Background</string>
    
    <key>ThrottleInterval</key>
    <integer>3600</integer>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>"
    
    echo "$plist_content" > "$LAUNCHAGENT_PATH"
}

# Função para gerar arquivo plist de teste (execução imediata)
generate_test_plist() {
    local plist_content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>$LAUNCHAGENT_NAME</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>$PROJECT_ROOT/scripts/backup/dynamic-backup.sh</string>
    </array>
    
    <key>StartInterval</key>
    <integer>60</integer>
    
    <key>StandardOutPath</key>
    <string>/tmp/docker-backup-launchagent.log</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/docker-backup-launchagent-error.log</string>
    
    <key>WorkingDirectory</key>
    <string>$PROJECT_ROOT</string>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <false/>
    
    <key>ProcessType</key>
    <string>Background</string>
    
    <key>ThrottleInterval</key>
    <integer>3600</integer>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>"
    
    echo "$plist_content" > "$LAUNCHAGENT_PATH"
}

# Função para instalar LaunchAgent
install_launchagent() {
    log_info "Instalando LaunchAgent..."
    
    # Verificar se script de backup existe
    if [ ! -f "$SCRIPT_DIR/../backup/dynamic-backup.sh" ]; then
        log_error "Script dynamic-backup.sh não encontrado em $SCRIPT_DIR/../backup/"
        exit 1
    fi
    
    # Tornar script executável
    chmod +x "$SCRIPT_DIR/../backup/dynamic-backup.sh"
    
    # Criar diretório LaunchAgents se não existir
    mkdir -p "$HOME/Library/LaunchAgents"
    
    # Gerar arquivo plist dinamicamente
    generate_plist
    
    # Carregar LaunchAgent
    launchctl load "$LAUNCHAGENT_PATH"
    
    log_success "LaunchAgent instalado e carregado com sucesso!"
    log_info "Backup será executado diariamente às $SCHEDULE_DESCRIPTION"
    log_info "Logs disponíveis em:"
    log_info "  - /tmp/docker-backup-launchagent.log"
    log_info "  - /tmp/docker-backup-launchagent-error.log"
}

# Função para desinstalar LaunchAgent
uninstall_launchagent() {
    log_info "Desinstalando LaunchAgent..."
    
    if is_loaded; then
        launchctl unload "$LAUNCHAGENT_PATH"
        log_success "LaunchAgent descarregado"
    fi
    
    if is_installed; then
        rm -f "$LAUNCHAGENT_PATH"
        log_success "Arquivo LaunchAgent removido"
    fi
    
    log_success "LaunchAgent desinstalado com sucesso!"
}

# Função para iniciar LaunchAgent
start_launchagent() {
    log_info "Iniciando LaunchAgent..."
    
    if ! is_installed; then
        log_error "LaunchAgent não está instalado. Execute: $0 install"
        exit 1
    fi
    
    if is_loaded; then
        log_warning "LaunchAgent já está carregado"
    else
        launchctl load "$LAUNCHAGENT_PATH"
        log_success "LaunchAgent iniciado"
    fi
}

# Função para parar LaunchAgent
stop_launchagent() {
    log_info "Parando LaunchAgent..."
    
    if is_loaded; then
        launchctl unload "$LAUNCHAGENT_PATH"
        log_success "LaunchAgent parado"
    else
        log_warning "LaunchAgent não está carregado"
    fi
}

# Função para verificar status
check_status() {
    echo "🐳 Status do LaunchAgent de Backup Docker"
    echo "=========================================="
    echo ""
    
    echo "📁 Arquivo:"
    if is_installed; then
        echo -e "  ${GREEN}✅ Instalado: $LAUNCHAGENT_PATH${NC}"
    else
        echo -e "  ${RED}❌ Não instalado${NC}"
    fi
    
    echo ""
    echo "🔄 Status:"
    if is_loaded; then
        echo -e "  ${GREEN}✅ Carregado e ativo${NC}"
    else
        echo -e "  ${RED}❌ Não carregado${NC}"
    fi
    
    echo ""
    echo "⏰ Agendamento:"
    echo "  Diariamente às $SCHEDULE_DESCRIPTION"
    
    echo ""
    echo "📝 Logs:"
    if [ -f "/tmp/docker-backup-launchagent.log" ]; then
        echo -e "  ${GREEN}✅ Log principal: /tmp/docker-backup-launchagent.log${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Log principal: Nenhum log ainda${NC}"
    fi
    
    if [ -f "/tmp/docker-backup-launchagent-error.log" ]; then
        echo -e "  ${GREEN}✅ Log de erro: /tmp/docker-backup-launchagent-error.log${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Log de erro: Nenhum erro ainda${NC}"
    fi
    
    echo ""
    echo "🔧 Scripts:"
            if [ -f "$SCRIPT_DIR/../backup/dynamic-backup.sh" ]; then
            echo -e "  ${GREEN}✅ dynamic-backup.sh: Disponível${NC}"
        else
            echo -e "  ${RED}❌ dynamic-backup.sh: Não encontrado${NC}"
        fi
    
    if [ -f "$SCRIPT_DIR/../core/recover.sh" ]; then
        echo -e "  ${GREEN}✅ scripts/core/recover.sh: Disponível${NC}"
    else
        echo -e "  ${RED}❌ scripts/core/recover.sh: Não encontrado${NC}"
    fi
}

# Função para mostrar logs
show_logs() {
    echo "📝 Logs do LaunchAgent"
    echo "======================"
    echo ""
    
    echo "📋 Log Principal:"
    if [ -f "/tmp/docker-backup-launchagent.log" ]; then
        echo "--- Últimas 20 linhas ---"
        tail -20 "/tmp/docker-backup-launchagent.log"
    else
        echo "Nenhum log encontrado"
    fi
    
    echo ""
    echo "❌ Log de Erro:"
    if [ -f "/tmp/docker-backup-launchagent-error.log" ]; then
        echo "--- Últimas 20 linhas ---"
        tail -20 "/tmp/docker-backup-launchagent-error.log"
    else
        echo "Nenhum erro encontrado"
    fi
}

# Função para testar backup
test_backup() {
    log_info "Testando script de backup..."
    
    if [ ! -f "$SCRIPT_DIR/../backup/dynamic-backup.sh" ]; then
        log_error "Script dynamic-backup.sh não encontrado"
        exit 1
    fi
    
    cd "$SCRIPT_DIR/../backup"
    ./dynamic-backup.sh backup
    
    log_success "Teste concluído! Verifique os logs para detalhes."
}

# Função para atualizar arquivo de configuração
update_config_file() {
    local hour="$1"
    local minute="$2"
    local config_file="$PROJECT_ROOT/config/version-config.sh"
    
    # Determinar descrição do horário
    local description
    if [ "$hour" -eq 0 ]; then
        description="meia-noite"
    elif [ "$hour" -lt 12 ]; then
        description="${hour}:$(printf "%02d" $minute) da manhã"
    elif [ "$hour" -eq 12 ]; then
        description="12:$(printf "%02d" $minute) do meio-dia"
    else
        description="$((hour - 12)):$(printf "%02d" $minute) da tarde"
    fi
    
    # Atualizar arquivo de configuração
    if [ -f "$config_file" ]; then
        # Fazer backup do arquivo original
        cp "$config_file" "$config_file.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Atualizar SCHEDULE_HOUR
        sed -i '' "s/^SCHEDULE_HOUR=.*/SCHEDULE_HOUR=$hour/" "$config_file"
        
        # Atualizar SCHEDULE_MINUTE
        sed -i '' "s/^SCHEDULE_MINUTE=.*/SCHEDULE_MINUTE=$minute/" "$config_file"
        
        # Atualizar SCHEDULE_DESCRIPTION
        sed -i '' "s/^SCHEDULE_DESCRIPTION=.*/SCHEDULE_DESCRIPTION=\"$description\"/" "$config_file"
        
        log_info "Arquivo de configuração atualizado: $config_file"
        log_info "Backup criado: $config_file.backup.$(date +%Y%m%d_%H%M%S)"
    else
        log_warning "Arquivo de configuração não encontrado: $config_file"
    fi
}

# Função para alterar horário
change_schedule() {
    log_info "Alterando horário do backup..."
    
    echo "Horário atual: $SCHEDULE_DESCRIPTION"
    echo ""
    echo "Escolha o novo horário:"
    echo "1) 01:00 da manhã"
    echo "2) 02:00 da manhã"
    echo "3) 03:00 da manhã"
    echo "4) 04:00 da manhã"
    echo "5) Personalizado"
    echo ""
    
    read -p "Digite sua escolha (1-5): " choice
    
    case $choice in
        1) hour=1; minute=0 ;;
        2) hour=2; minute=0 ;;
        3) hour=3; minute=0 ;;
        4) hour=4; minute=0 ;;
        5)
            read -p "Digite a hora (0-23): " hour
            read -p "Digite o minuto (0-59): " minute
            ;;
        *)
            log_error "Escolha inválida"
            exit 1
            ;;
    esac
    
    # Validar entrada
    if ! [[ "$hour" =~ ^[0-9]+$ ]] || [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
        log_error "Hora inválida: $hour"
        exit 1
    fi
    
    if ! [[ "$minute" =~ ^[0-9]+$ ]] || [ "$minute" -lt 0 ] || [ "$minute" -gt 59 ]; then
        log_error "Minuto inválido: $minute"
        exit 1
    fi
    
    # Parar LaunchAgent se estiver carregado
    if is_loaded; then
        launchctl unload "$LAUNCHAGENT_PATH"
    fi
    
    # Atualizar arquivo de configuração
    update_config_file "$hour" "$minute"
    
    # Recarregar configuração para usar novos valores
    source "$VERSION_CONFIG"
    
    # Reinstalar LaunchAgent com novo horário
    generate_plist
    
    # Recarregar LaunchAgent
    launchctl load "$LAUNCHAGENT_PATH"
    
    log_success "Horário alterado para $hour:$minute"
    log_info "Arquivo de configuração atualizado: config/version-config.sh"
}

# Função para testar LaunchAgent
test_launchagent() {
    log_info "Testando LaunchAgent..."
    
    # Parar LaunchAgent se estiver carregado
    if is_loaded; then
        launchctl unload "$LAUNCHAGENT_PATH"
        log_info "LaunchAgent descarregado para teste"
    fi
    
    # Gerar arquivo plist de teste
    generate_test_plist
    
    # Carregar LaunchAgent
    launchctl load "$LAUNCHAGENT_PATH"
    
    log_success "LaunchAgent de teste carregado!"
    log_info "O backup será executado em 60 segundos"
    log_info "Verifique os logs em: /tmp/docker-backup-launchagent.log"
    log_info "Para voltar ao horário normal, execute: $0 schedule"
}

# Função principal
main() {
    case "${1:-help}" in
        install)
            install_launchagent
            ;;
        uninstall)
            uninstall_launchagent
            ;;
        start)
            start_launchagent
            ;;
        stop)
            stop_launchagent
            ;;
        status)
            check_status
            ;;
        logs)
            show_logs
            ;;
        test)
            test_backup
            ;;
        schedule)
            change_schedule
            ;;
        test-launchagent)
            test_launchagent
            ;;
        help|*)
            show_help
            ;;
    esac
}

# Executar função principal
main "$@"
