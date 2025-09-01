#!/bin/bash

# Script Principal do Sistema de Backup Docker
# ===========================================
# Autor: Assistente IA
# Data: $(date)

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Função para mostrar ajuda
show_help() {
    echo "🐳 Sistema de Backup Docker - Script Principal"
    echo "=============================================="
    echo ""
    echo "Uso: $0 [COMANDO] [OPÇÕES]"
    echo ""
    echo "COMANDOS PRINCIPAIS:"
    echo "  backup          Executar backup dinâmico"
    echo "  recover         Recuperar containers"
    echo "  status          Verificar status dos containers"
    echo "  logs            Analisar logs do sistema"
    echo "  report          Gerar relatórios"
    echo "  notify-test     Testar notificações"
    echo "  monitor         Monitorar logs em tempo real"
    echo "  cleanup         Limpar logs e backups antigos"
    echo ""
    echo "COMANDOS DE BACKUP:"
    echo "  backup run      Executar backup completo"
    echo "  backup list     Listar backups disponíveis"
    echo "  backup restore  Restaurar backup específico"
    echo ""
    echo "COMANDOS DE LOGS:"
    echo "  logs --last-24h     Logs das últimas 24 horas"
    echo "  logs --errors       Apenas erros"
    echo "  logs --performance  Análise de performance"
    echo "  logs --stats        Estatísticas gerais"
    echo "  logs --search TEXT  Buscar nos logs"
    echo ""
    echo "COMANDOS DE RELATÓRIOS:"
    echo "  report html     Gerar relatório HTML"
    echo "  report text     Gerar relatório de texto"
    echo "  report export   Exportar dados"
    echo ""
    echo "COMANDOS DE CONFIGURAÇÃO:"
    echo "  config edit       Editar configurações"
    echo "  config containers Configurar containers para backup (interativo)"
    echo "  config preview    Preview da configuração de containers"
    echo "  config validate   Validar configuração de containers"
    echo "  config reset      Resetar configuração de containers"
    echo "  config test       Testar configurações"
    echo "  config backups    Gerenciar backups de configuração"
    echo ""
    echo "COMANDOS DE VERSÃO:"
    echo "  version               Mostrar informações da versão"
    echo "  changelog [versão]    Mostrar changelog"
    echo "  changelog-manager     Gerenciar changelogs (criar, listar, validar)"
    echo "  compatibility         Verificar compatibilidade"
    echo "  update-check          Verificar atualizações"
    echo "  stats                 Mostrar estatísticas do sistema"
    echo "  validate              Validar configurações"
    echo ""
    echo "COMANDOS DE BACKUP DINÂMICO (RECOMENDADO):"
    echo "  dynamic backup        Executar backup dinâmico"
    echo "  dynamic list          Listar containers configurados"
    echo "  dynamic validate      Validar configuração dinâmica"
    echo "  dynamic test          Testar backup dinâmico"
    echo ""
    echo "COMANDOS DE RECUPERAÇÃO:"
    echo "  recovery config       Configurar recuperação (interativo)"
    echo "  recovery preview      Preview da configuração de recuperação"
    echo "  recovery validate     Validar configuração de recuperação"
    echo "  recovery reset        Resetar configuração de recuperação"
    echo "  recovery start        Iniciar recuperação de containers"
    echo "  recovery stop         Parar recuperação de containers"
    echo "  recovery status       Status da recuperação"
    echo "  recovery logs         Logs da recuperação"
    echo "  recovery list         Listar containers configurados"
    echo ""
    echo "COMANDOS DE AUTOMAÇÃO (LaunchAgent):"
    echo "  automação install     Instalar LaunchAgent para backup automático"
    echo "  automação status      Verificar status do LaunchAgent"
    echo "  automação uninstall   Desinstalar LaunchAgent"
    echo "  automação test        Testar script de backup do LaunchAgent"
    echo ""
    echo "EXEMPLOS:"
    echo "  $0 backup"
    echo "  $0 logs --errors"
    echo "  $0 report html"
    echo "  $0 monitor"
    echo "  $0 recovery config"
    echo "  $0 recovery start"
    echo "  $0 automação install"
    echo "  $0 automação status"
    echo ""
    echo "Para mais detalhes sobre um comando específico:"
    echo "  $0 [COMANDO] --help"
}

# Função para executar backup (redireciona para dynamic backup)
run_backup() {
    echo "🚀 Executando backup dinâmico..."
    run_dynamic_backup backup
}

# Função para recuperar containers
run_recover() {
    echo "🔄 Recuperando containers..."
    "$SCRIPT_DIR/scripts/core/recover.sh" recover
}

# Função para verificar status
run_status() {
    echo "📊 Verificando status dos containers..."
    "$SCRIPT_DIR/scripts/core/recover.sh" status
}

# Função para analisar logs
run_logs() {
    echo "📝 Analisando logs..."
    "$SCRIPT_DIR/scripts/logging/log-analyzer.sh" "$@"
}

# Função para gerar relatórios
run_report() {
    local report_type="$1"
    
    case "$report_type" in
        html)
            echo "📊 Gerando relatório HTML..."
            "$SCRIPT_DIR/scripts/logging/report-generator.sh"
            ;;
        text)
            echo "📄 Gerando relatório de texto..."
            "$SCRIPT_DIR/scripts/logging/log-analyzer.sh" --export
            ;;
        export)
            echo "📤 Exportando dados..."
            "$SCRIPT_DIR/scripts/logging/log-analyzer.sh" --export
            ;;
        *)
            echo "❌ Tipo de relatório inválido. Use: html, text, ou export"
            exit 1
            ;;
    esac
}

# Função para testar notificações
run_test() {
    echo "🧪 Testando notificações..."
    "$SCRIPT_DIR/scripts/notifications/test-notifications.sh"
}

# Função para monitorar logs
run_monitor() {
    echo "👀 Monitorando logs em tempo real..."
    "$SCRIPT_DIR/scripts/logging/log-analyzer.sh" --monitor
}

# Função para limpeza
run_cleanup() {
    echo "🧹 Limpando logs e backups antigos..."
    "$SCRIPT_DIR/scripts/logging/log-analyzer.sh" --cleanup
    "$SCRIPT_DIR/scripts/core/recover.sh" clean
}

# Função para comandos de backup
run_backup_commands() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        run)
            run_backup
            ;;
        list)
            echo "📦 Listando backups disponíveis..."
            "$SCRIPT_DIR/scripts/core/recover.sh" list
            ;;
        restore)
            local backup_file="$1"
            if [ -z "$backup_file" ]; then
                echo "❌ Erro: Especifique o arquivo de backup para restaurar"
                echo "Uso: $0 backup restore [arquivo.tar.gz]"
                exit 1
            fi
            echo "🔄 Restaurando backup: $backup_file"
            "$SCRIPT_DIR/scripts/core/recover.sh" restore "$backup_file"
            ;;
        *)
            echo "❌ Comando de backup inválido. Use: run, list, ou restore"
            exit 1
            ;;
    esac
}

# Função para comandos de configuração
run_config() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        edit)
            echo "⚙️  Editando configurações..."
            if command -v nano >/dev/null 2>&1; then
                nano "$SCRIPT_DIR/config/notification-config.sh"
            elif command -v vim >/dev/null 2>&1; then
                vim "$SCRIPT_DIR/config/notification-config.sh"
            else
                echo "❌ Nenhum editor encontrado. Edite manualmente:"
                echo "   $SCRIPT_DIR/config/notification-config.sh"
            fi
            ;;
        containers)
            echo "🐳 Configurador de Containers para Backup"
            echo "========================================="
            "$SCRIPT_DIR/scripts/utils/container-configurator.sh" "$@"
            ;;
        preview)
            echo "📋 Preview da Configuração de Containers"
            echo "======================================="
            "$SCRIPT_DIR/scripts/utils/container-configurator.sh" --preview
            ;;
        validate)
            echo "🔍 Validando Configuração de Containers"
            echo "======================================"
            "$SCRIPT_DIR/scripts/utils/container-configurator.sh" --validate
            ;;
        reset)
            echo "🔄 Resetando Configuração de Containers"
            echo "======================================"
            "$SCRIPT_DIR/scripts/utils/container-configurator.sh" --reset
            ;;
        test)
            run_test
            ;;
        backups)
            echo "📁 Gerenciador de Backups de Configuração"
            echo "========================================="
            "$SCRIPT_DIR/scripts/utils/config-backup-manager.sh" "$@"
            ;;
        *)
            echo "❌ Comando de configuração inválido. Use: edit, containers, preview, validate, reset, test ou backups"
            exit 1
            ;;
    esac
}

# Função para comandos de versão
run_version() {
    local version_utils="$SCRIPT_DIR/scripts/utils/version-utils.sh"
    if [ -f "$version_utils" ]; then
        source "$version_utils"
        show_version
    else
        echo "❌ Utilitários de versão não encontrados"
        exit 1
    fi
}

run_changelog() {
    local version_utils="$SCRIPT_DIR/scripts/utils/version-utils.sh"
    if [ -f "$version_utils" ]; then
        source "$version_utils"
        show_changelog "$1"
    else
        echo "❌ Utilitários de versão não encontrados"
        exit 1
    fi
}

run_compatibility() {
    local version_utils="$SCRIPT_DIR/scripts/utils/version-utils.sh"
    if [ -f "$version_utils" ]; then
        source "$version_utils"
        check_compatibility
    else
        echo "❌ Utilitários de versão não encontrados"
        exit 1
    fi
}

run_update_check() {
    local version_utils="$SCRIPT_DIR/scripts/utils/version-utils.sh"
    if [ -f "$version_utils" ]; then
        source "$version_utils"
        check_for_updates
    else
        echo "❌ Utilitários de versão não encontrados"
        exit 1
    fi
}

run_stats() {
    local version_utils="$SCRIPT_DIR/scripts/utils/version-utils.sh"
    if [ -f "$version_utils" ]; then
        source "$version_utils"
        show_system_stats
    else
        echo "❌ Utilitários de versão não encontrados"
        exit 1
    fi
}

run_validate() {
    local version_utils="$SCRIPT_DIR/scripts/utils/version-utils.sh"
    if [ -f "$version_utils" ]; then
        source "$version_utils"
        validate_config
    else
        echo "❌ Utilitários de versão não encontrados"
        exit 1
    fi
}

# Função para backup dinâmico
run_dynamic_backup() {
    local dynamic_backup="$SCRIPT_DIR/scripts/backup/dynamic-backup.sh"
    if [ -f "$dynamic_backup" ]; then
        "$dynamic_backup" "$@"
    else
        echo "❌ Script de backup dinâmico não encontrado"
        exit 1
    fi
}

# Função para comandos de recuperação
run_recovery() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        config)
            echo "🔄 Configurador de Recuperação de Containers"
            echo "============================================"
            "$SCRIPT_DIR/scripts/utils/recovery-configurator.sh" "$@"
            ;;
        preview)
            echo "📋 Preview da Configuração de Recuperação"
            echo "======================================="
            "$SCRIPT_DIR/scripts/utils/recovery-configurator.sh" --preview
            ;;
        validate)
            echo "🔍 Validando Configuração de Recuperação"
            echo "======================================"
            "$SCRIPT_DIR/scripts/utils/recovery-configurator.sh" --validate
            ;;
        reset)
            echo "🔄 Resetando Configuração de Recuperação"
            echo "======================================"
            "$SCRIPT_DIR/scripts/utils/recovery-configurator.sh" --reset
            ;;
        start)
            echo "🚀 Iniciando Recuperação de Containers"
            echo "====================================="
            "$SCRIPT_DIR/scripts/core/recover.sh" recover
            ;;
        stop)
            echo "🛑 Parando Recuperação de Containers"
            echo "==================================="
            "$SCRIPT_DIR/scripts/core/manage-containers.sh" stop
            ;;
        status)
            echo "📊 Status da Recuperação"
            echo "======================="
            "$SCRIPT_DIR/scripts/core/manage-containers.sh" status
            ;;
        logs)
            echo "📝 Logs da Recuperação"
            echo "====================="
            "$SCRIPT_DIR/scripts/core/manage-containers.sh" logs
            ;;
        list)
            echo "📋 Listando Containers Configurados para Recuperação"
            echo "=================================================="
            if [ -f "$SCRIPT_DIR/config/recovery-config.sh" ]; then
                source "$SCRIPT_DIR/config/recovery-config.sh"
                if [ ${#RECOVERY_TARGETS[@]} -gt 0 ]; then
                    echo ""
                    echo "🔴 Alta Prioridade:"
                    for target in "${RECOVERY_TARGETS[@]}"; do
                        local parts=($(echo "$target" | tr ':' '\n'))
                        if [ ${#parts[@]} -ge 5 ] && [ "${parts[2]}" = "1" ]; then
                            local service_type="${parts[5]:-unknown}"
                            echo "  - ${parts[0]} (${parts[3]}s, health: ${parts[4]}, type: $service_type)"
                        fi
                    done
                    echo ""
                    echo "🟡 Média Prioridade:"
                    for target in "${RECOVERY_TARGETS[@]}"; do
                        local parts=($(echo "$target" | tr ':' '\n'))
                        if [ ${#parts[@]} -ge 5 ] && [ "${parts[2]}" = "2" ]; then
                            local service_type="${parts[5]:-unknown}"
                            echo "  - ${parts[0]} (${parts[3]}s, health: ${parts[4]}, type: $service_type)"
                        fi
                    done
                    echo ""
                    echo "🟢 Baixa Prioridade:"
                    for target in "${RECOVERY_TARGETS[@]}"; do
                        local parts=($(echo "$target" | tr ':' '\n'))
                        if [ ${#parts[@]} -ge 5 ] && [ "${parts[2]}" = "3" ]; then
                            local service_type="${parts[5]:-unknown}"
                            echo "  - ${parts[0]} (${parts[3]}s, health: ${parts[4]}, type: $service_type)"
                        fi
                    done
                else
                    echo "Nenhum container configurado para recuperação"
                fi
            else
                echo "Arquivo de configuração não encontrado"
            fi
            ;;
        *)
            echo "❌ Subcomando inválido. Use: config, preview, validate, reset, start, stop, status, logs, list"
            exit 1
            ;;
    esac
}

# Função para gerenciar changelogs
run_changelog_manager() {
    local changelog_manager="$SCRIPT_DIR/scripts/utils/changelog-manager.sh"
    if [ -f "$changelog_manager" ]; then
        "$changelog_manager" "$@"
    else
        echo "❌ Gerenciador de changelog não encontrado"
        exit 1
    fi
}

# Função para gerenciar automação (LaunchAgent)
run_automation() {
    local subcommand="$1"
    local launchagent_script="$SCRIPT_DIR/scripts/utils/install-launchagent.sh"
    
    # Verificar se o script existe
    if [ ! -f "$launchagent_script" ]; then
        echo "❌ Script de LaunchAgent não encontrado: $launchagent_script"
        exit 1
    fi
    
    # Verificar se estamos no macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "⚠️  LaunchAgent é específico do macOS"
        echo "💡 Use cron jobs em outros sistemas operacionais"
        exit 1
    fi
    
    case "$subcommand" in
        install)
            echo "🔧 Instalando LaunchAgent para backup automático..."
            "$launchagent_script" install
            ;;
        status)
            echo "📊 Verificando status do LaunchAgent..."
            "$launchagent_script" status
            ;;
        uninstall)
            echo "🗑️  Desinstalando LaunchAgent..."
            "$launchagent_script" uninstall
            ;;
        test)
            echo "🧪 Testando script de backup do LaunchAgent..."
            "$launchagent_script" test
            ;;
        --help|-h|help)
            echo "🔧 Comandos de Automação (LaunchAgent)"
            echo "====================================="
            echo ""
            echo "Uso: $0 automação [COMANDO]"
            echo ""
            echo "COMANDOS:"
            echo "  install     Instalar LaunchAgent para backup automático"
            echo "  status      Verificar status do LaunchAgent"
            echo "  uninstall   Desinstalar LaunchAgent"
            echo "  test        Testar script de backup do LaunchAgent"
            echo ""
            echo "EXEMPLOS:"
            echo "  $0 automação install"
            echo "  $0 automação status"
            echo "  $0 automação uninstall"
            echo "  $0 automação test"
            echo ""
            echo "NOTA: LaunchAgent é específico do macOS"
            ;;
        *)
            echo "❌ Comando de automação desconhecido: $subcommand"
            echo ""
            echo "💡 Use: $0 automação --help"
            exit 1
            ;;
    esac
}

# Função principal
main() {
    local command="$1"
    shift
    
    # Se nenhum comando foi especificado, mostrar ajuda
    if [ -z "$command" ]; then
        show_help
        exit 0
    fi
    
    # Processar comando
    case "$command" in
        backup)
            if [ "$1" = "run" ] || [ "$1" = "list" ] || [ "$1" = "restore" ]; then
                run_backup_commands "$@"
            else
                run_backup
            fi
            ;;
        recover)
            run_recover
            ;;
        status)
            run_status
            ;;
        logs)
            run_logs "$@"
            ;;
        report)
            run_report "$@"
            ;;
        notify-test)
            run_test
            ;;
        monitor)
            run_monitor
            ;;
        cleanup)
            run_cleanup
            ;;
        config)
            run_config "$@"
            ;;
        version)
            run_version
            ;;
        changelog)
            run_changelog "$@"
            ;;
        changelog-manager)
            run_changelog_manager "$@"
            ;;
        compatibility)
            run_compatibility
            ;;
        update-check)
            run_update_check
            ;;
        stats)
            run_stats
            ;;
        validate)
            run_validate
            ;;
        dynamic)
            run_dynamic_backup "$@"
            ;;
        recovery)
            run_recovery "$@"
            ;;
        automação|automacao|automation)
            run_automation "$@"
            ;;
        --help|-h|help)
            show_help
            ;;
        *)
            echo "❌ Comando desconhecido: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
