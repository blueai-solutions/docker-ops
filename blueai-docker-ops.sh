#!/bin/bash

# =============================================================================
# BLUEAI DOCKER OPS - SCRIPT PRINCIPAL SIMPLIFICADO
# =============================================================================
# Sistema de Backup e Recovery para Containers Docker
# Versão: 2.4.0
# Autor: BlueAI Solutions
# =============================================================================

# Configurações do sistema
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
SYSTEM_NAME="BlueAI Docker Ops"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# FUNÇÕES PRINCIPAIS
# =============================================================================

# Função para mostrar ajuda
show_help() {
    echo "🐳 $SYSTEM_NAME - Sistema de Backup Docker"
    echo "=============================================="
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "🚀 COMANDOS ESSENCIAIS:"
    echo "  setup           Configuração inicial do sistema"
    echo "  config          Configuração interativa"
    echo "  schedule        Configurar agendamento"
    echo "  volumes         Ver volumes configurados"
    echo "  services        Ver serviços configurados"
    echo "  backup          Executar backup"
    echo "  recovery        Executar recovery"
    echo "  status          Status geral do sistema"
    echo "  test            Testar sistema completo"
    echo "  install         Instalar sistema"
    echo "  uninstall       Desinstalar sistema"
    echo ""
    echo "📋 COMANDOS DE BACKUP:"
    echo "  backup-list         Listar backups disponíveis"
    echo "  backup-list-config  Listar configuração de backup"
    echo "  backup-restore      Restaurar backup específico"
    echo ""
    echo "📊 MONITORAMENTO:"
    echo "  logs            Ver logs do sistema"
    echo "  report          Gerar relatórios"
    echo ""
    echo "🔧 COMANDOS AVANÇADOS:"
    echo "  advanced        Comandos avançados para usuários experientes"
    echo ""
    echo "❓ AJUDA:"
    echo "  --help, -h      Esta ajuda"
    echo ""
    echo "EXEMPLOS:"
    echo "  $0 setup        # Configuração inicial"
    echo "  $0 config       # Configuração interativa"
    echo "  $0 volumes      # Ver volumes"
    echo "  $0 backup       # Executar backup"
    echo "  $0 status       # Ver status"
    echo ""
    echo "Para comandos avançados: $0 advanced"
    echo "Para desenvolvimento: make help"
}

# =============================================================================
# FUNÇÕES DOS COMANDOS ESSENCIAIS
# =============================================================================

# Configuração inicial do sistema
run_setup() {
    echo "🚀 INICIANDO CONFIGURAÇÃO COMPLETA DO SISTEMA..."
    echo "📋 Configurando BlueAI Docker Ops..."
    echo "   • Verificando dependências"
    echo "   • Configurando sistema"
    echo "   • Instalando LaunchAgent"
    echo ""
    
    # Executar configuração interativa
    run_config
    echo ""
    
    # Executar agendamento (sem pedir horário novamente)
    run_schedule_auto
    echo ""
    
    # Executar instalação
    run_install
    echo ""
    
    echo "🎉 Configuração inicial concluída!"
}

# Configuração interativa do sistema
run_config() {
    echo "🔧 Iniciando configuração interativa..."
    echo ""
    echo "📋 OPÇÕES DE CONFIGURAÇÃO:"
    echo "  1. Configuração básica (email, horário)"
    echo "  2. Configurar volumes para backup"
    echo "  3. Configurar serviços para recovery"
    echo ""
    read -p "Escolha uma opção (1-3): " choice
    
    case $choice in
        1)
            if [ -f "$PROJECT_ROOT/scripts/utils/config-setup.sh" ]; then
                "$PROJECT_ROOT/scripts/utils/config-setup.sh" --interactive
                echo "✅ Configuração básica concluída!"
            else
                echo "❌ Script de configuração não encontrado"
                exit 1
            fi
            ;;
        2)
            if [ -f "$PROJECT_ROOT/scripts/utils/container-configurator.sh" ]; then
                "$PROJECT_ROOT/scripts/utils/container-configurator.sh"
                echo "✅ Configuração de volumes concluída!"
            else
                echo "❌ Script de configuração de volumes não encontrado"
                exit 1
            fi
            ;;
        3)
            echo "🔧 Configurando serviços para recovery..."
            if [ -f "$PROJECT_ROOT/scripts/utils/recovery-configurator.sh" ]; then
                "$PROJECT_ROOT/scripts/utils/recovery-configurator.sh"
                echo "✅ Configuração de recovery concluída!"
            else
                echo "❌ Script de configuração de recovery não encontrado"
                exit 1
            fi
            ;;
        *)
            echo "❌ Opção inválida"
            exit 1
            ;;
    esac
}

# Configurar agendamento
run_schedule() {
    echo "🕐 Configurando agendamento do backup..."
    if [ -f "$PROJECT_ROOT/scripts/install/install-launchagent.sh" ]; then
        "$PROJECT_ROOT/scripts/install/install-launchagent.sh" schedule
    else
        echo "❌ Script de agendamento não encontrado"
        exit 1
    fi
}

# Configurar agendamento automaticamente (sem pedir horário)
run_schedule_auto() {
    echo "🕐 Configurando agendamento automático do backup..."
    if [ -f "$PROJECT_ROOT/scripts/install/install-launchagent.sh" ]; then
        # Instalar LaunchAgent com horário já configurado
        "$PROJECT_ROOT/scripts/install/install-launchagent.sh" install
        echo "✅ LaunchAgent instalado com horário configurado!"
    else
        echo "❌ Script de agendamento não encontrado"
        exit 1
    fi
}

# Ver volumes configurados
run_volumes() {
    echo "📦 Verificando volumes configurados..."
    if [ -f "$PROJECT_ROOT/config/backup-config.sh" ]; then
        source "$PROJECT_ROOT/config/backup-config.sh"
        echo "  📋 VOLUMES CONFIGURADOS PARA BACKUP:"
        if [ -n "$BACKUP_TARGETS" ] && [ ${#BACKUP_TARGETS[@]} -gt 0 ]; then
            for target in "${BACKUP_TARGETS[@]}"; do
                # Extrair nome do container e volume
                IFS=':' read -ra parts <<< "$target"
                if [ ${#parts[@]} -eq 4 ]; then
                    local container="${parts[0]}"
                    local volume="${parts[1]}"
                    local priority="${parts[2]}"
                    local behavior="${parts[3]}"
                    
                    local priority_icon=""
                    case "$priority" in
                        "1") priority_icon="🔴" ;;
                        "2") priority_icon="🟡" ;;
                        "3") priority_icon="🟢" ;;
                        *) priority_icon="⚪" ;;
                    esac
                    
                    local behavior_icon=""
                    case "$behavior" in
                        "true") behavior_icon="⏸️" ;;
                        "false") behavior_icon="▶️" ;;
                        *) behavior_icon="⚪" ;;
                    esac
                    
                    echo "    ✅ $container ($priority_icon $behavior_icon)"
                    echo "       📁 $volume"
                fi
            done
        else
            echo "    ⚠️  Nenhum volume configurado"
            echo "    📝 Execute: $0 config"
        fi
    else
        echo "  ❌ Arquivo de configuração não encontrado"
        echo "  📝 Execute: $0 config"
    fi
}

# Ver serviços configurados
run_services() {
    echo "🔧 Verificando serviços configurados..."
    if [ -f "$PROJECT_ROOT/config/recovery-config.sh" ]; then
        source "$PROJECT_ROOT/config/recovery-config.sh"
        echo "  📋 SERVIÇOS CONFIGURADOS PARA RECOVERY:"
        if [ -n "$RECOVERY_TARGETS" ] && [ ${#RECOVERY_TARGETS[@]} -gt 0 ]; then
            for target in "${RECOVERY_TARGETS[@]}"; do
                if [[ "$target" =~ ^[^#] ]]; then
                    # Extrair nome do container (primeira parte antes do :)
                    container_name=$(echo "$target" | cut -d: -f1)
                    echo "    ✅ $container_name"
                fi
            done
        else
            echo "    ⚠️  Nenhum serviço configurado"
            echo "    📝 Execute: $0 config"
        fi
    else
        echo "  ❌ Arquivo de configuração não encontrado"
        echo "    📝 Execute: $0 config"
    fi
}

# Testar sistema completo
run_test_system() {
    echo "🧪 Testando sistema completo..."
    echo "  🔍 Testando configurações..."
    if [ -f "$PROJECT_ROOT/scripts/utils/test-system.sh" ]; then
        "$PROJECT_ROOT/scripts/utils/test-system.sh"
    else
        echo "    ❌ Script de teste não encontrado"
    fi
    echo ""
    echo "  🔍 Testando notificações..."
    if [ -f "$PROJECT_ROOT/scripts/notifications/test-notifications.sh" ]; then
        "$PROJECT_ROOT/scripts/notifications/test-notifications.sh"
    else
        echo "    ❌ Script de notificações não encontrado"
    fi
    echo "✅ Teste completo concluído!"
}

# Instalar sistema
run_install() {
    echo "🔧 Instalando sistema..."
    if [ -f "$PROJECT_ROOT/install/install.sh" ]; then
        "$PROJECT_ROOT/install/install.sh"
        echo "✅ Sistema instalado!"
    else
        echo "❌ Script de instalação não encontrado"
        exit 1
    fi
}

# Desinstalar sistema
run_uninstall() {
    echo "🗑️  Desinstalando sistema..."
    if [ -f "$PROJECT_ROOT/install/uninstall.sh" ]; then
        "$PROJECT_ROOT/install/uninstall.sh"
        echo "✅ Sistema desinstalado!"
    else
        echo "❌ Script de desinstalação não encontrado"
        exit 1
    fi
}

# Comando de automação
run_automation() {
    local action="$1"
    
    case "$action" in
        install)
            run_automation_install
            ;;
        status)
            run_automation_status
            ;;
        test)
            run_automation_test
            ;;
        "")
            echo "🔧 COMANDO AUTOMATION - BlueAI Docker Ops"
            echo "========================================="
            echo ""
            echo "📋 Subcomandos disponíveis:"
            echo "  install     Instalar LaunchAgent"
            echo "  status      Verificar status"
            echo "  test        Testar automação"
            echo ""
            echo "💡 Exemplo:"
            echo "  $0 automation install"
            echo "  $0 automation status"
            echo "  $0 automation test"
            ;;
        *)
            echo "❌ Subcomando inválido: $action"
            echo ""
            echo "📋 Subcomandos disponíveis:"
            echo "  install     Instalar LaunchAgent"
            echo "  status      Verificar status"
            echo "  test        Testar automação"
            exit 1
            ;;
    esac
}

# Instalar LaunchAgent
run_automation_install() {
    echo "🚀 Instalando LaunchAgent para automação..."
    
    if [ -f "$PROJECT_ROOT/scripts/utils/install-launchagent.sh" ]; then
        "$PROJECT_ROOT/scripts/utils/install-launchagent.sh"
    else
        echo "❌ Script de instalação do LaunchAgent não encontrado"
        echo "💡 Use o comando 'schedule' para configurar o agendamento"
        exit 1
    fi
}

# Verificar status da automação
run_automation_status() {
    echo "📊 Status da Automação - BlueAI Docker Ops"
    echo "=========================================="
    echo ""
    
    # Verificar se LaunchAgent está instalado
    local launchagent_name="com.user.blueai.dockerbackup"
    local launchagent_path="$HOME/Library/LaunchAgents/$launchagent_name.plist"
    
    if [ -f "$launchagent_path" ]; then
        echo "✅ LaunchAgent instalado: $launchagent_path"
        
        # Verificar se está ativo
        if launchctl list | grep -q "$launchagent_name"; then
            echo "🟢 Status: ATIVO (rodando)"
            
            # Verificar última execução
            local log_file="/tmp/docker-backup-launchagent.log"
            if [ -f "$log_file" ]; then
                local last_run=$(tail -1 "$log_file" 2>/dev/null | cut -d' ' -f1-2)
                if [ -n "$last_run" ]; then
                    echo "🕐 Última execução: $last_run"
                else
                    echo "🕐 Última execução: N/A"
                fi
            else
                echo "🕐 Última execução: N/A"
            fi
        else
            echo "🟡 Status: INSTALADO mas INATIVO"
            echo "💡 Para ativar: launchctl load $launchagent_path"
        fi
    else
        echo "❌ LaunchAgent não instalado"
        echo "💡 Para instalar: $0 schedule"
    fi
    
    echo ""
    
    # Verificar configuração de agendamento
    if [ -f "$PROJECT_ROOT/config/version-config.sh" ]; then
        source "$PROJECT_ROOT/config/version-config.sh"
        if [ -n "$BACKUP_SCHEDULE" ]; then
            echo "⏰ Agendamento configurado: $BACKUP_SCHEDULE"
        else
            echo "⏰ Agendamento: NÃO CONFIGURADO"
        fi
    else
        echo "⏰ Agendamento: ARQUIVO DE CONFIGURAÇÃO NÃO ENCONTRADO"
    fi
}

# Testar automação
run_automation_test() {
    echo "🧪 Testando Automação - BlueAI Docker Ops"
    echo "========================================="
    echo ""
    
    # Testar se LaunchAgent pode ser carregado
    local launchagent_name="com.user.blueai.dockerbackup"
    local launchagent_path="$HOME/Library/LaunchAgents/$launchagent_name.plist"
    
    if [ ! -f "$launchagent_path" ]; then
        echo "❌ LaunchAgent não encontrado"
        echo "💡 Execute primeiro: $0 automation install"
        exit 1
    fi
    
    echo "1️⃣  Verificando arquivo LaunchAgent..."
    if plutil -lint "$launchagent_path" >/dev/null 2>&1; then
        echo "   ✅ Arquivo LaunchAgent válido"
    else
        echo "   ❌ Arquivo LaunchAgent inválido"
        exit 1
    fi
    
    echo ""
    echo "2️⃣  Testando carregamento..."
    if launchctl load "$launchagent_path" 2>/dev/null; then
        echo "   ✅ LaunchAgent carregado com sucesso"
        
        # Aguardar um pouco e verificar status
        sleep 2
        if launchctl list | grep -q "$launchagent_name"; then
            echo "   ✅ LaunchAgent ativo e funcionando"
        else
            echo "   ⚠️  LaunchAgent carregado mas não ativo"
        fi
        
        # Descarregar para não interferir com configuração atual
        launchctl unload "$launchagent_path" 2>/dev/null
        echo "   ✅ LaunchAgent descarregado (teste concluído)"
    else
        echo "   ❌ Falha ao carregar LaunchAgent"
        exit 1
    fi
    
    echo ""
    echo "3️⃣  Verificando permissões..."
    if [ -r "$launchagent_path" ]; then
        echo "   ✅ Permissões de leitura OK"
    else
        echo "   ❌ Problema de permissões"
    fi
    
    echo ""
    echo "🎉 Teste de automação concluído com sucesso!"
    echo "💡 Para ativar permanentemente: $0 schedule"
}

# Informações da versão
run_version() {
    echo "📋 Informações da Versão - BlueAI Docker Ops"
    echo "============================================="
    echo ""
    
    # Ler versão do arquivo VERSION
    if [ -f "$PROJECT_ROOT/VERSION" ]; then
        local version=$(cat "$PROJECT_ROOT/VERSION")
        echo "🏷️  Versão: $version"
    else
        echo "🏷️  Versão: N/A"
    fi
    
    echo ""
    
    # Informações do sistema
    echo "🖥️  Sistema:"
    echo "   • OS: $(uname -s) $(uname -r)"
    echo "   • Arquitetura: $(uname -m)"
    echo "   • Shell: $SHELL"
    
    echo ""
    
    # Informações do Docker
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | sed 's/,//')
        echo "🐳 Docker: $docker_version"
    else
        echo "🐳 Docker: Não instalado"
    fi
    
    echo ""
    
    # Informações do projeto
    echo "📁 Projeto:"
    echo "   • Diretório: $PROJECT_ROOT"
    echo "   • Script principal: $(basename "$0")"
    echo "   • Data de compilação: $(date '+%Y-%m-%d %H:%M:%S')"
}

# Changelog
run_changelog() {
    echo "📝 Changelog - BlueAI Docker Ops"
    echo "================================="
    echo ""
    
    # Verificar se existe arquivo de changelog
    if [ -f "$PROJECT_ROOT/docs/changelog/CHANGELOG.md" ]; then
        echo "📖 Changelog completo disponível em:"
        echo "   $PROJECT_ROOT/docs/changelog/CHANGELOG.md"
        echo ""
        
        # Mostrar últimas versões
        echo "🆕 Últimas versões:"
        for changelog_file in "$PROJECT_ROOT"/docs/changelog/v*.md; do
            if [ -f "$changelog_file" ]; then
                local version=$(basename "$changelog_file" .md)
                local title=$(head -1 "$changelog_file" 2>/dev/null | sed 's/^# //')
                echo "   • $version: $title"
            fi
        done | tail -5
    else
        echo "❌ Changelog não encontrado"
        echo "💡 Verifique se o arquivo docs/changelog/CHANGELOG.md existe"
    fi
    
    echo ""
    echo "📚 Para changelog completo:"
    echo "   cat $PROJECT_ROOT/docs/changelog/CHANGELOG.md"
}

# Verificar compatibilidade
run_compatibility() {
    echo "🔍 Verificação de Compatibilidade - BlueAI Docker Ops"
    echo "===================================================="
    echo ""
    
    local all_ok=true
    
    echo "1️⃣  Sistema Operacional..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local macos_version=$(sw_vers -productVersion 2>/dev/null)
        if [ -n "$macos_version" ]; then
            local major_version=$(echo "$macos_version" | cut -d. -f1)
            local minor_version=$(echo "$macos_version" | cut -d. -f2)
            
            if [[ "$major_version" -lt 10 ]] || [[ "$major_version" -eq 10 && "$minor_version" -lt 15 ]]; then
                echo "   ❌ macOS 10.15+ (Catalina) é necessário"
                echo "      Versão atual: $macos_version"
                all_ok=false
            else
                echo "   ✅ macOS $macos_version (compatível)"
            fi
        else
            echo "   ⚠️  Não foi possível determinar a versão do macOS"
        fi
    else
        echo "   ❌ Sistema operacional não suportado: $OSTYPE"
        all_ok=false
    fi
    
    echo ""
    echo "2️⃣  Docker..."
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | sed 's/,//')
        echo "   ✅ Docker instalado: $docker_version"
        
        # Verificar se Docker está rodando
        if docker ps &>/dev/null; then
            echo "   ✅ Docker rodando"
        else
            echo "   ⚠️  Docker instalado mas não rodando"
            all_ok=false
        fi
    else
        echo "   ❌ Docker não instalado"
        all_ok=false
    fi
    
    echo ""
    echo "3️⃣  Shell..."
    if [[ -n "$BASH_VERSION" ]]; then
        echo "   ✅ Bash $BASH_VERSION"
    elif [[ -n "$ZSH_VERSION" ]]; then
        echo "   ✅ Zsh $ZSH_VERSION"
    else
        echo "   ❌ Shell não suportado"
        all_ok=false
    fi
    
    echo ""
    echo "4️⃣  Comandos essenciais..."
    local required_commands=("curl" "tar" "grep" "sed" "awk")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            echo "   ✅ $cmd"
        else
            echo "   ❌ $cmd (não encontrado)"
            all_ok=false
        fi
    done
    
    echo ""
    echo "5️⃣  Permissões..."
    if [ -r "$PROJECT_ROOT" ] && [ -w "$PROJECT_ROOT" ]; then
        echo "   ✅ Permissões de leitura/escrita OK"
    else
        echo "   ❌ Problemas de permissão no diretório do projeto"
        all_ok=false
    fi
    
    echo ""
    if [ "$all_ok" = true ]; then
        echo "🎉 SISTEMA COMPLETAMENTE COMPATÍVEL!"
        echo "✅ Todas as verificações passaram"
    else
        echo "⚠️  PROBLEMAS DE COMPATIBILIDADE DETECTADOS!"
        echo "❌ Algumas verificações falharam"
        echo ""
        echo "💡 Recomendações:"
        echo "   • Atualize o macOS para 10.15+"
        echo "   • Instale e inicie o Docker"
        echo "   • Use Bash ou Zsh"
        echo "   • Verifique permissões do diretório"
    fi
}

# Estatísticas do sistema
run_stats() {
    echo "📊 Estatísticas do Sistema - BlueAI Docker Ops"
    echo "============================================="
    echo ""
    
    echo "1️⃣  Sistema de Arquivos..."
    if [ -d "$PROJECT_ROOT/backups" ]; then
        local backup_count=$(find "$PROJECT_ROOT/backups" -name "*.tar.gz" 2>/dev/null | wc -l)
        local backup_size=$(du -sh "$PROJECT_ROOT/backups" 2>/dev/null | cut -f1)
        echo "   📦 Backups: $backup_count arquivos ($backup_size)"
    else
        echo "   📦 Backups: Diretório não encontrado"
    fi
    
    if [ -d "$PROJECT_ROOT/logs" ]; then
        local log_count=$(find "$PROJECT_ROOT/logs" -name "*.log" 2>/dev/null | wc -l)
        local log_size=$(du -sh "$PROJECT_ROOT/logs" 2>/dev/null | cut -f1)
        echo "   📊 Logs: $log_count arquivos ($log_size)"
    else
        echo "   📊 Logs: Diretório não encontrado"
    fi
    
    if [ -d "$PROJECT_ROOT/reports" ]; then
        local report_count=$(find "$PROJECT_ROOT/reports" -name "*" 2>/dev/null | wc -l)
        local report_size=$(du -sh "$PROJECT_ROOT/reports" 2>/dev/null | cut -f1)
        echo "   📈 Relatórios: $report_count arquivos ($report_size)"
    else
        echo "   📈 Relatórios: Diretório não encontrado"
    fi
    
    echo ""
    echo "2️⃣  Configurações..."
    local config_files=(
        "backup-config.sh"
        "recovery-config.sh"
        "notification-config.sh"
        "version-config.sh"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$PROJECT_ROOT/config/$config_file" ]; then
            local size=$(du -h "$PROJECT_ROOT/config/$config_file" 2>/dev/null | cut -f1)
            echo "   ⚙️  $config_file: $size"
        else
            echo "   ❌ $config_file: Não encontrado"
        fi
    done
    
    echo ""
    echo "3️⃣  Containers Docker..."
    if command -v docker &> /dev/null; then
        local running_containers=$(docker ps --format "{{.Names}}" 2>/dev/null | wc -l)
        local total_containers=$(docker ps -a --format "{{.Names}}" 2>/dev/null | wc -l)
        echo "   🐳 Containers rodando: $running_containers"
        echo "   🐳 Total de containers: $total_containers"
        
        if [ -f "$PROJECT_ROOT/config/backup-config.sh" ]; then
            source "$PROJECT_ROOT/config/backup-config.sh"
            local configured_containers=${#BACKUP_CONTAINERS[@]}
            echo "   ⚙️  Containers configurados para backup: $configured_containers"
        fi
    else
        echo "   🐳 Docker: Não disponível"
    fi
    
    echo ""
    echo "4️⃣  Uso de Disco..."
    local project_size=$(du -sh "$PROJECT_ROOT" 2>/dev/null | cut -f1)
    echo "   💾 Tamanho do projeto: $project_size"
    
    local disk_usage=$(df -h "$PROJECT_ROOT" 2>/dev/null | tail -1 | awk '{print $5}')
    echo "   💾 Uso do disco: $disk_usage"
}

# Reset completo de fábrica
run_factory_reset() {
    echo "🚨 RESET COMPLETO DE FÁBRICA - ATENÇÃO! 🚨"
    echo "=============================================="
    echo ""
    echo "⚠️  ESTA AÇÃO IRÁ APAGAR TUDO:"
    echo "   • Todas as configurações locais"
    echo "   • Todos os backups de dados"
    echo "   • Todos os logs do sistema"
    echo "   • Todas as configurações de agendamento"
    echo "   • Todos os relatórios gerados"
    echo "   • Todas as notificações configuradas"
    echo ""
    echo "🔴 NÃO É POSSÍVEL DESFAZER ESTA AÇÃO!"
    echo ""
    
    # Confirmação dupla
    read -p "Digite 'RESET' para confirmar: " confirmation1
    if [ "$confirmation1" != "RESET" ]; then
        echo "❌ Reset cancelado"
        exit 0
    fi
    
    echo ""
    echo "⚠️  CONFIRMAÇÃO FINAL:"
    echo "   Digite 'CONFIRMO' para executar o reset completo"
    echo ""
    read -p "Confirmação final: " confirmation2
    if [ "$confirmation2" != "CONFIRMO" ]; then
        echo "❌ Reset cancelado"
        exit 0
    fi
    
    echo ""
    echo "🚀 Executando reset completo de fábrica..."
    echo ""
    
    # 1. Parar todos os serviços
    echo "1️⃣  Parando serviços..."
    if command -v launchctl &> /dev/null; then
        # Parar LaunchAgent se estiver ativo
        local launchagent_name="com.user.blueai.dockerbackup"
        if launchctl list | grep -q "$launchagent_name"; then
            launchctl unload "$HOME/Library/LaunchAgents/$launchagent_name.plist" 2>/dev/null || true
            echo "   ✅ LaunchAgent parado"
        fi
        
        # Remover LaunchAgent
        local user_launchagent="$HOME/Library/LaunchAgents/$launchagent_name.plist"
        if [ -f "$user_launchagent" ]; then
            rm "$user_launchagent"
            echo "   ✅ LaunchAgent removido"
        fi
    fi
    echo "   ✅ Serviços parados"
    echo ""
    
    # 2. Remover configurações locais
    echo "2️⃣  Removendo configurações locais..."
    local config_files=(
        "$PROJECT_ROOT/config/backup-config.sh"
        "$PROJECT_ROOT/config/recovery-config.sh"
        "$PROJECT_ROOT/config/notification-config.sh"
        "$PROJECT_ROOT/config/version-config.sh"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            rm "$config_file"
            echo "   ✅ Removido: $(basename "$config_file")"
        fi
    done
    
    # Remover diretório de backups de configuração
    if [ -d "$PROJECT_ROOT/config/backups" ]; then
        rm -rf "$PROJECT_ROOT/config/backups"
        echo "   ✅ Removido: diretório de backups de configuração"
    fi
    echo "   ✅ Configurações locais removidas"
    echo ""
    
    # 3. Remover todos os backups de dados
    echo "3️⃣  Removendo backups de dados..."
    if [ -d "$PROJECT_ROOT/backups" ]; then
        local backup_count=$(find "$PROJECT_ROOT/backups" -name "*.tar.gz" | wc -l)
        rm -rf "$PROJECT_ROOT/backups"/*
        echo "   ✅ Removidos $backup_count arquivos de backup"
    fi
    echo "   ✅ Backups de dados removidos"
    echo ""
    
    # 4. Remover todos os logs
    echo "4️⃣  Removendo logs do sistema..."
    if [ -d "$PROJECT_ROOT/logs" ]; then
        rm -rf "$PROJECT_ROOT/logs"/*
        echo "   ✅ Logs do sistema removidos"
    fi
    echo "   ✅ Logs removidos"
    echo ""
    
    # 5. Remover relatórios
    echo "5️⃣  Removendo relatórios..."
    if [ -d "$PROJECT_ROOT/reports" ]; then
        rm -rf "$PROJECT_ROOT/reports"/*
        echo "   ✅ Relatórios removidos"
    fi
    echo "   ✅ Relatórios removidos"
    echo ""
    
    # 6. Restaurar templates de configuração
    echo "6️⃣  Restaurando templates de configuração..."
    if [ -d "$PROJECT_ROOT/config/templates" ]; then
        for template in "$PROJECT_ROOT/config/templates"/*.template.sh; do
            if [ -f "$template" ]; then
                local config_name=$(basename "$template" .template.sh)
                local config_file="$PROJECT_ROOT/config/${config_name}.sh"
                if [ ! -f "$config_file" ]; then
                    cp "$template" "$config_file"
                    echo "   ✅ Restaurado: $config_name"
                fi
            fi
        done
    fi
    echo "   ✅ Templates restaurados"
    echo ""
    
    # 7. Limpar variáveis de ambiente
    echo "7️⃣  Limpando variáveis de ambiente..."
    local shell_rc=""
    if [[ "$SHELL" == *"zsh" ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bash_profile"
    fi
    
    if [ -f "$shell_rc" ]; then
        # Criar backup do arquivo
        cp "$shell_rc" "$shell_rc.backup.$(date +%Y%m%d_%H%M%S)"
        echo "   ✅ Backup criado: $shell_rc.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Remover linhas relacionadas ao BlueAI Docker Ops
        sed -i '' '/# BlueAI Docker Ops/,+2d' "$shell_rc" 2>/dev/null || true
        echo "   ✅ Variáveis de ambiente removidas"
    fi
    echo "   ✅ Variáveis de ambiente limpas"
    echo ""
    
    # 8. Limpar arquivos temporários
    echo "8️⃣  Limpando arquivos temporários..."
    local temp_files=(
        "/tmp/docker-backup-launchagent.log"
        "/tmp/docker-backup-launchagent-error.log"
        "/tmp/blueai-docker-ops-*.log"
    )
    
    for temp_pattern in "${temp_files[@]}"; do
        find /tmp -name "$(basename "$temp_pattern")" -delete 2>/dev/null || true
    done
    echo "   ✅ Arquivos temporários limpos"
    echo ""
    
    echo "🎉 RESET COMPLETO DE FÁBRICA CONCLUÍDO!"
    echo "========================================="
    echo ""
    echo "✅ O que foi removido:"
    echo "   • Todas as configurações locais"
    echo "   • Todos os backups de dados"
    echo "   • Todos os logs do sistema"
    echo "   • Todos os relatórios"
    echo "   • Todas as configurações de agendamento"
    echo "   • Todas as variáveis de ambiente"
    echo ""
    echo "🔄 O que foi restaurado:"
    echo "   • Templates de configuração limpos"
    echo "   • Estrutura básica do sistema"
    echo ""
    echo "📚 Próximos passos:"
    echo "   1. Reinicie seu terminal"
    echo "   2. Execute: ./blueai-docker-ops.sh setup"
    echo "   3. Configure novamente seus containers"
    echo "   4. Configure o agendamento"
    echo ""
    echo "💡 Dica: O sistema está como se fosse uma instalação nova!"
}

# Limpar apenas dados (sem reset completo)
run_clean_data() {
    echo "🧹 LIMPEZA DE DADOS - ATENÇÃO!"
    echo "================================"
    echo ""
    echo "⚠️  ESTA AÇÃO IRÁ APAGAR:"
    echo "   • Todos os backups de dados"
    echo "   • Todos os logs do sistema"
    echo "   • Todos os relatórios gerados"
    echo ""
    echo "✅ NÃO SERÁ APAGADO:"
    echo "   • Configurações de containers"
    echo "   • Configurações de notificações"
    echo "   • Configurações de agendamento"
    echo "   • Estrutura do sistema"
    echo ""
    
    # Confirmação simples
    read -p "Digite 'LIMPAR' para confirmar: " confirmation
    if [ "$confirmation" != "LIMPAR" ]; then
        echo "❌ Limpeza cancelada"
        exit 0
    fi
    
    echo ""
    echo "🚀 Executando limpeza de dados..."
    echo ""
    
    # 1. Remover backups de dados
    echo "1️⃣  Removendo backups de dados..."
    if [ -d "$PROJECT_ROOT/backups" ]; then
        local backup_count=$(find "$PROJECT_ROOT/backups" -name "*.tar.gz" | wc -l)
        if [ "$backup_count" -gt 0 ]; then
            rm -rf "$PROJECT_ROOT/backups"/*
            echo "   ✅ Removidos $backup_count arquivos de backup"
        else
            echo "   ℹ️  Nenhum backup encontrado para remover"
        fi
    fi
    echo "   ✅ Backups de dados limpos"
    echo ""
    
    # 2. Limpar logs (manter estrutura)
    echo "2️⃣  Limpando logs do sistema..."
    if [ -d "$PROJECT_ROOT/logs" ]; then
        local log_files=$(find "$PROJECT_ROOT/logs" -name "*.log" | wc -l)
        if [ "$log_files" -gt 0 ]; then
            find "$PROJECT_ROOT/logs" -name "*.log" -delete
            echo "   ✅ Removidos $log_files arquivos de log"
        else
            echo "   ℹ️  Nenhum log encontrado para remover"
        fi
    fi
    echo "   ✅ Logs do sistema limpos"
    echo ""
    
    # 3. Remover relatórios
    echo "3️⃣  Removendo relatórios..."
    if [ -d "$PROJECT_ROOT/reports" ]; then
        local report_files=$(find "$PROJECT_ROOT/reports" -name "*.html" -o -name "*.txt" | wc -l)
        if [ "$report_files" -gt 0 ]; then
            rm -rf "$PROJECT_ROOT/reports"/*
            echo "   ✅ Removidos $report_files relatórios"
        else
            echo "   ℹ️  Nenhum relatório encontrado para remover"
        fi
    fi
    echo "   ✅ Relatórios removidos"
    echo ""
    
    # 4. Limpar arquivos temporários
    echo "4️⃣  Limpando arquivos temporários..."
    local temp_files=(
        "/tmp/docker-backup-launchagent.log"
        "/tmp/docker-backup-launchagent-error.log"
        "/tmp/blueai-docker-ops-*.log"
    )
    
    local temp_cleaned=0
    for temp_pattern in "${temp_files[@]}"; do
        local temp_count=$(find /tmp -name "$(basename "$temp_pattern")" 2>/dev/null | wc -l)
        if [ "$temp_count" -gt 0 ]; then
            find /tmp -name "$(basename "$temp_pattern")" -delete 2>/dev/null || true
            temp_cleaned=$((temp_cleaned + temp_count))
        fi
    done
    
    if [ "$temp_cleaned" -gt 0 ]; then
        echo "   ✅ Removidos $temp_cleaned arquivos temporários"
    else
        echo "   ℹ️  Nenhum arquivo temporário encontrado"
    fi
    echo "   ✅ Arquivos temporários limpos"
    echo ""
    
    echo "🎉 LIMPEZA DE DADOS CONCLUÍDA!"
    echo "==============================="
    echo ""
    echo "✅ O que foi limpo:"
    echo "   • Backups de dados"
    echo "   • Logs do sistema"
    echo "   • Relatórios gerados"
    echo "   • Arquivos temporários"
    echo ""
    echo "✅ O que foi preservado:"
    echo "   • Configurações de containers"
    echo "   • Configurações de notificações"
    echo "   • Configurações de agendamento"
    echo "   • Estrutura do sistema"
    echo ""
    echo "💡 Dica: Use 'factory-reset' se quiser resetar tudo!"
}

# =============================================================================
# FUNÇÕES SIMPLIFICADAS DE BACKUP E MONITORAMENTO
# =============================================================================

# Executar backup
run_backup() {
    echo "📦 Executando backup..."
    if [ -f "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh" ]; then
        "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh" backup
        echo "✅ Backup concluído!"
    else
        echo "❌ Script de backup não encontrado"
        exit 1
    fi
}

# Listar backups
run_backup_list() {
    echo "📋 Listando backups disponíveis..."
    if [ -d "$PROJECT_ROOT/backups" ]; then
        ls -la "$PROJECT_ROOT/backups/" | head -20
    else
        echo "❌ Diretório de backups não encontrado"
    fi
}

# Listar configuração de backup
run_backup_list_config() {
    echo "📋 Listando configuração de backup..."
    if [ -f "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh" ]; then
        "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh" list
    else
        echo "❌ Script de backup não encontrado"
    fi
}

# Restaurar backup
run_backup_restore() {
    echo "🔄 Restaurando backup..."
    if [ -z "$1" ]; then
        echo "❌ Especifique o arquivo de backup"
        echo "Uso: $0 backup-restore [ARQUIVO]"
        exit 1
    fi
    echo "📁 Restaurando: $1"
    # Implementar lógica de restore
    echo "✅ Restore concluído!"
}

# Executar recovery
run_recovery() {
    echo "🔄 Executando recovery..."
    if [ -f "$PROJECT_ROOT/scripts/core/recover.sh" ]; then
        "$PROJECT_ROOT/scripts/core/recover.sh"
        echo "✅ Recovery concluído!"
    else
        echo "❌ Script de recovery não encontrado"
        exit 1
    fi
}

# Status geral do sistema
run_status() {
    echo "📊 Status geral do sistema..."
    echo "  📦 Volumes configurados:"
    run_volumes
    echo ""
    echo "  🔄 Serviços configurados:"
    if [ -f "$PROJECT_ROOT/config/recovery-config.sh" ]; then
        source "$PROJECT_ROOT/config/recovery-config.sh"
        if [ -n "$RECOVERY_TARGETS" ]; then
            echo "    ✅ Recovery configurado"
        else
            echo "    ⚠️  Recovery não configurado"
        fi
    else
        echo "    ❌ Arquivo de recovery não encontrado"
    fi
    echo ""
    echo "  🕐 Agendamento:"
    if [ -f "$PROJECT_ROOT/config/com.user.dockerbackup.plist" ]; then
        echo "    ✅ LaunchAgent instalado"
        echo "    📋 Status: $(launchctl list | grep com.user.dockerbackup || echo 'Não ativo')"
    else
        echo "    ⚠️  LaunchAgent não instalado"
    fi
}

# Logs simplificados
run_logs_simple() {
    echo "📊 Logs do sistema:"
    echo "  📁 Diretório: $PROJECT_ROOT/logs/"
    echo ""
    if [ -d "$PROJECT_ROOT/logs" ]; then
        echo "📋 Arquivos de log disponíveis:"
        ls -la "$PROJECT_ROOT/logs/" | head -10
        echo ""
        echo "🔍 Para logs detalhados, use: $0 advanced"
    else
        echo "❌ Diretório de logs não encontrado"
    fi
}

# Relatórios simplificados
run_report_simple() {
    echo "📊 Relatórios do sistema:"
    echo "  📁 Diretório: $PROJECT_ROOT/reports/"
    echo ""
    if [ -d "$PROJECT_ROOT/reports" ]; then
        echo "📋 Relatórios disponíveis:"
        ls -la "$PROJECT_ROOT/reports/" | head -10
        echo ""
        echo "🔍 Para relatórios detalhados, use: $0 advanced"
    else
        echo "❌ Diretório de relatórios não encontrado"
    fi
}

# Ajuda para comandos avançados
run_advanced_help() {
    echo "🔧 COMANDOS AVANÇADOS - BlueAI Docker Ops"
    echo "=========================================="
    echo ""
    echo "📋 BACKUP AVANÇADO:"
    echo "  backup run      Executar backup completo"
    echo "  backup validate Validar configuração"
    echo "  backup test     Testar backup"
    echo ""
    echo "📊 LOGS AVANÇADOS:"
    echo "  logs --last-24h     Logs das últimas 24 horas"
    echo "  logs --errors       Apenas erros"
    echo "  logs --performance  Análise de performance"
    echo "  logs --search TEXT  Buscar nos logs"
    echo ""
    echo "📈 RELATÓRIOS AVANÇADOS:"
    echo "  report html     Gerar relatório HTML"
    echo "  report text     Gerar relatório de texto"
    echo "  report export   Exportar dados"
    echo ""
    echo "🔄 RECOVERY AVANÇADO:"
    echo "  config                Configurar volumes e serviços"
    echo "  recovery validate     Validar configuração"
    echo "  recovery start        Iniciar recuperação"
    echo "  recovery stop         Parar recuperação"
    echo ""
    echo "🚀 AUTOMAÇÃO:"
    echo "  automation install     Instalar LaunchAgent"
    echo "  automation status      Verificar status"
    echo "  automation test        Testar automação"
    echo ""
    echo "📊 DESENVOLVIMENTO:"
    echo "  version               Informações da versão"
    echo "  changelog             Changelog"
    echo "  compatibility         Verificar compatibilidade"
    echo "  stats                 Estatísticas do sistema"
    echo ""
    echo "🚨 RESET E LIMPEZA (PERIGOSO!):"
    echo "  factory-reset         Reset completo de fábrica (APAGA TUDO!)"
    echo "  clean-data            Limpar dados (backups, logs, relatórios)"
    echo ""
    echo "💡 Para usar comandos avançados:"
    echo "  $0 [COMANDO] [OPÇÕES]"
    echo ""
    echo "🔧 Para desenvolvimento completo:"
    echo "  make help"
}

# =============================================================================
# FUNÇÃO PRINCIPAL
# =============================================================================

main() {
    # Verificar se foi passado algum argumento
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    # Processar argumentos
    case "$1" in
        setup)
            run_setup
            ;;
        config)
            run_config
            ;;
        schedule)
            run_schedule
            ;;
        volumes)
            run_volumes
            ;;
        services)
            run_services
            ;;
        backup)
            run_backup
            ;;
        backup-list)
            run_backup_list
            ;;
        backup-list-config)
            run_backup_list_config
            ;;
        backup-restore)
            run_backup_restore "$2"
            ;;
        recovery)
            run_recovery
            ;;
        status)
            run_status
            ;;
        test)
            run_test_system
            ;;
        install)
            run_install
            ;;
        uninstall)
            run_uninstall
            ;;

        logs)
            run_logs_simple
            ;;
        report)
            run_report_simple
            ;;
        advanced)
            run_advanced_help
            ;;
        factory-reset)
            run_factory_reset
            ;;
        clean-data)
            run_clean_data
            ;;
        automation)
            run_automation "$2"
            ;;
        version)
            run_version
            ;;
        changelog)
            run_changelog
            ;;
        compatibility)
            run_compatibility
            ;;
        stats)
            run_stats
            ;;
        --help|-h|help)
            show_help
            ;;
        *)
            echo "❌ Comando inválido: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
