#!/bin/bash

# Teste Completo do Sistema de Backup Docker
# =========================================
# Autor: Assistente IA
# Data: $(date)

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MAIN_SCRIPT="$PROJECT_ROOT/blueai-docker-ops.sh"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Contadores de teste
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para log de teste
test_log() {
    echo -e "${BLUE}[TESTE]${NC} $1"
}

# Função para sucesso
test_success() {
    echo -e "${GREEN}✅ SUCESSO:${NC} $1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# Função para falha
test_failure() {
    echo -e "${RED}❌ FALHA:${NC} $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# Função para aviso
test_warning() {
    echo -e "${YELLOW}⚠️  AVISO:${NC} $1"
}

# Função para verificar se arquivo existe
check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        test_success "$description: $file"
        return 0
    else
        test_failure "$description: $file não encontrado"
        return 1
    fi
}

# Função para verificar se comando existe
check_command() {
    local command="$1"
    local description="$2"
    
    if command -v "$command" >/dev/null 2>&1; then
        test_success "$description: $command disponível"
        return 0
    else
        test_failure "$description: $command não encontrado"
        return 1
    fi
}

# Função para verificar se diretório existe
check_directory() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        test_success "$description: $dir"
        return 0
    else
        test_failure "$description: $dir não encontrado"
        return 1
    fi
}

# Função para testar comando
test_command() {
    local command="$1"
    local description="$2"
    local expected_exit="$3"
    
    test_log "Executando: $command"
    
    if eval "$command" >/dev/null 2>&1; then
        local exit_code=$?
        if [ "$exit_code" -eq "${expected_exit:-0}" ]; then
            test_success "$description"
            return 0
        else
            test_failure "$description (código de saída: $exit_code, esperado: ${expected_exit:-0})"
            return 1
        fi
    else
        local exit_code=$?
        if [ "$exit_code" -eq "${expected_exit:-0}" ]; then
            test_success "$description"
            return 0
        else
            test_failure "$description (código de saída: $exit_code, esperado: ${expected_exit:-0})"
            return 1
        fi
    fi
}

# Função para mostrar cabeçalho de seção
show_section() {
    echo ""
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}"
    echo ""
}

# Função para mostrar resumo
show_summary() {
    echo ""
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}RESUMO DOS TESTES${NC}"
    echo -e "${PURPLE}========================================${NC}"
    echo ""
    echo -e "Total de testes: ${CYAN}$TOTAL_TESTS${NC}"
    echo -e "Testes aprovados: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Testes falharam: ${RED}$FAILED_TESTS${NC}"
    echo ""
    
    if [ "$FAILED_TESTS" -eq 0 ]; then
        echo -e "${GREEN}🎉 TODOS OS TESTES PASSARAM!${NC}"
        echo -e "${GREEN}O sistema está funcionando perfeitamente!${NC}"
    else
        echo -e "${YELLOW}⚠️  $FAILED_TESTS teste(s) falharam.${NC}"
        echo -e "${YELLOW}Verifique os detalhes acima.${NC}"
    fi
    echo ""
}

# Teste 1: Verificar estrutura do projeto
test_project_structure() {
    show_section "1. VERIFICANDO ESTRUTURA DO PROJETO"
    
    # Verificar diretórios principais
    check_directory "$PROJECT_ROOT/scripts" "Diretório scripts"
    check_directory "$PROJECT_ROOT/scripts/core" "Diretório scripts/core"
    check_directory "$PROJECT_ROOT/scripts/backup" "Diretório scripts/backup"
    check_directory "$PROJECT_ROOT/scripts/notifications" "Diretório scripts/notifications"
    check_directory "$PROJECT_ROOT/scripts/logging" "Diretório scripts/logging"
    check_directory "$PROJECT_ROOT/scripts/utils" "Diretório scripts/utils"
    check_directory "$PROJECT_ROOT/config" "Diretório config"
    check_directory "$PROJECT_ROOT/logs" "Diretório logs"
    check_directory "$PROJECT_ROOT/reports" "Diretório reports"
    check_directory "$PROJECT_ROOT/backups" "Diretório backups"
    
    # Verificar arquivos principais
    check_file "$MAIN_SCRIPT" "Script principal"
    check_file "$PROJECT_ROOT/scripts/core/recover.sh" "Script de recuperação"
    check_file "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh" "Script de backup dinâmico"
    check_file "$PROJECT_ROOT/config/notification-config.sh" "Configuração de notificações"
    check_file "$PROJECT_ROOT/scripts/notifications/test-notifications.sh" "Script de teste de notificações"
    check_file "$PROJECT_ROOT/scripts/logging/logging-functions.sh" "Funções de logging"
    check_file "$PROJECT_ROOT/scripts/logging/log-analyzer.sh" "Analisador de logs"
    check_file "$PROJECT_ROOT/scripts/logging/report-generator.sh" "Gerador de relatórios"
    check_file "$PROJECT_ROOT/README.md" "Documentação"
}

# Teste 2: Verificar dependências do sistema
test_system_dependencies() {
    show_section "2. VERIFICANDO DEPENDÊNCIAS DO SISTEMA"
    
    # Verificar comandos básicos
    check_command "docker" "Docker"
    check_command "osascript" "AppleScript (notificações macOS)"
    check_command "mail" "Cliente de email (mail)"
    check_command "sendmail" "Cliente de email (sendmail)"
    check_command "bc" "Calculadora (bc)"
    check_command "awk" "AWK"
    check_command "grep" "GREP"
    check_command "sed" "SED"
    check_command "tar" "TAR"
    check_command "date" "Comando date"
    
    # Verificar se Docker está rodando
    test_log "Verificando se Docker está rodando..."
    if docker info >/dev/null 2>&1; then
        test_success "Docker está rodando"
    else
        test_failure "Docker não está rodando"
        test_warning "Alguns testes podem falhar se o Docker não estiver disponível"
    fi
}

# Teste 3: Verificar permissões de execução
test_execution_permissions() {
    show_section "3. VERIFICANDO PERMISSÕES DE EXECUÇÃO"
    
    # Verificar se scripts são executáveis
    local scripts=(
        "$MAIN_SCRIPT"
        "$PROJECT_ROOT/scripts/core/recover.sh"
        "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh"
        "$PROJECT_ROOT/scripts/notifications/test-notifications.sh"
        "$PROJECT_ROOT/scripts/logging/log-analyzer.sh"
        "$PROJECT_ROOT/scripts/logging/report-generator.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -x "$script" ]; then
            test_success "Executável: $(basename "$script")"
        else
            test_failure "Não executável: $(basename "$script")"
        fi
    done
}

# Teste 4: Testar sistema de logging
test_logging_system() {
    show_section "4. TESTANDO SISTEMA DE LOGGING"
    
    # Verificar se arquivos de log foram criados
    check_file "$PROJECT_ROOT/logs/backup.log" "Arquivo de log de backup"
    check_file "$PROJECT_ROOT/logs/error.log" "Arquivo de log de erro"
    check_file "$PROJECT_ROOT/logs/system.log" "Arquivo de log do sistema"
    check_file "$PROJECT_ROOT/logs/performance.log" "Arquivo de log de performance"
    
    # Testar analisador de logs
    test_command "$PROJECT_ROOT/scripts/logging/log-analyzer.sh --help" "Analisador de logs (ajuda)"
    test_command "$PROJECT_ROOT/scripts/logging/log-analyzer.sh --stats" "Análise de estatísticas"
    
    # Verificar se logs têm conteúdo
    if [ -s "$PROJECT_ROOT/logs/system.log" ]; then
        test_success "Log do sistema tem conteúdo"
    else
        test_warning "Log do sistema está vazio"
    fi
}

# Teste 5: Testar sistema de notificações
test_notification_system() {
    show_section "5. TESTANDO SISTEMA DE NOTIFICAÇÕES"
    
    # Testar script de notificações
    test_command "$PROJECT_ROOT/scripts/notifications/test-notifications.sh" "Teste de notificações"
    
    # Verificar configuração de notificações
    if [ -f "$PROJECT_ROOT/config/notification-config.sh" ]; then
        source "$PROJECT_ROOT/config/notification-config.sh"
        
        if [ "$NOTIFICATIONS_ENABLED" = true ]; then
            test_success "Notificações habilitadas"
        else
            test_warning "Notificações desabilitadas"
        fi
        
        if [ "$EMAIL_ENABLED" = true ] && [ -n "$EMAIL_TO" ]; then
            test_success "Email configurado: $EMAIL_TO"
        else
            test_warning "Email não configurado ou desabilitado"
        fi
        
        if [ "$MACOS_NOTIFICATIONS_ENABLED" = true ]; then
            test_success "Notificações macOS habilitadas"
        else
            test_warning "Notificações macOS desabilitadas"
        fi
    else
        test_failure "Arquivo de configuração de notificações não encontrado"
    fi
}

# Teste 6: Testar comandos principais
test_main_commands() {
    show_section "6. TESTANDO COMANDOS PRINCIPAIS"
    
    # Testar ajuda
    test_command "$MAIN_SCRIPT --help" "Comando de ajuda"
    
    # Testar status
    test_command "$MAIN_SCRIPT status" "Comando de status"
    
    # Testar análise de logs
    test_command "$MAIN_SCRIPT logs --help" "Ajuda do comando logs"
    test_command "$MAIN_SCRIPT logs --stats" "Estatísticas de logs"
    
    # Testar relatórios
    test_command "$MAIN_SCRIPT report html" "Geração de relatório HTML"
    test_command "$MAIN_SCRIPT report text" "Geração de relatório de texto"
    
    # Testar configuração
    test_command "$MAIN_SCRIPT config test" "Teste de configuração"
}

# Teste 7: Testar backup dinâmico (simulado)
test_smart_backup() {
    show_section "7. TESTANDO BACKUP DINÂMICO"
    
    # Verificar se script existe
    if [ -f "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh" ]; then
        test_success "Script de backup dinâmico encontrado"
        
        # Testar se script carrega sem erros (sem executar backup real)
        if bash -n "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh" 2>/dev/null; then
            test_success "Script de backup dinâmico tem sintaxe válida"
        else
            test_failure "Script de backup dinâmico tem erros de sintaxe"
        fi
    else
        test_failure "Script de backup dinâmico não encontrado"
    fi
    
    # Verificar se diretório de backups existe
    check_directory "$PROJECT_ROOT/backups" "Diretório de backups"
}

# Teste 8: Testar geração de relatórios
test_report_generation() {
    show_section "8. TESTANDO GERAÇÃO DE RELATÓRIOS"
    
    # Verificar se relatórios foram gerados
    local report_files=$(find "$PROJECT_ROOT/reports" -name "*.html" -o -name "*.txt" 2>/dev/null | wc -l)
    
    if [ "$report_files" -gt 0 ]; then
        test_success "Relatórios encontrados: $report_files arquivo(s)"
        
        # Listar relatórios
        echo ""
        echo -e "${CYAN}Relatórios disponíveis:${NC}"
        find "$PROJECT_ROOT/reports" -name "*.html" -o -name "*.txt" 2>/dev/null | head -5 | while read file; do
            echo "  📄 $(basename "$file")"
        done
    else
        test_warning "Nenhum relatório encontrado"
    fi
}

# Teste 9: Testar limpeza
test_cleanup() {
    show_section "9. TESTANDO SISTEMA DE LIMPEZA"
    
    # Testar limpeza de logs (apenas verificar se comando funciona)
    test_command "$PROJECT_ROOT/scripts/logging/log-analyzer.sh --cleanup --days 1" "Limpeza de logs (teste)"
    
    # Verificar se diretórios de log ainda existem
    check_directory "$PROJECT_ROOT/logs" "Diretório de logs após limpeza"
}

# Teste 10: Verificar integridade geral
test_system_integrity() {
    show_section "10. VERIFICANDO INTEGRIDADE DO SISTEMA"
    
    # Verificar se todos os arquivos essenciais estão presentes
    local essential_files=(
        "$MAIN_SCRIPT"
        "$PROJECT_ROOT/scripts/core/recover.sh"
        "$PROJECT_ROOT/scripts/backup/dynamic-backup.sh"
        "$PROJECT_ROOT/scripts/logging/logging-functions.sh"
        "$PROJECT_ROOT/config/notification-config.sh"
        "$PROJECT_ROOT/README.md"
    )
    
    local missing_files=0
    for file in "${essential_files[@]}"; do
        if [ ! -f "$file" ]; then
            test_failure "Arquivo essencial ausente: $(basename "$file")"
            missing_files=$((missing_files + 1))
        fi
    done
    
    if [ "$missing_files" -eq 0 ]; then
        test_success "Todos os arquivos essenciais estão presentes"
    fi
    
    # Verificar tamanho dos logs
    if [ -f "$PROJECT_ROOT/logs/backup.log" ]; then
        local log_size=$(wc -l < "$PROJECT_ROOT/logs/backup.log")
        if [ "$log_size" -gt 0 ]; then
            test_success "Log de backup tem $log_size linhas"
        else
            test_warning "Log de backup está vazio"
        fi
    fi
}

# Função principal
main() {
    echo -e "${PURPLE}🐳 TESTE COMPLETO DO SISTEMA DE BACKUP DOCKER${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
    echo -e "Data: $(date)"
    echo -e "Diretório: $PROJECT_ROOT"
    echo ""
    
    # Executar todos os testes
    test_project_structure
    test_system_dependencies
    test_execution_permissions
    test_logging_system
    test_notification_system
    test_main_commands
    test_smart_backup
    test_report_generation
    test_cleanup
    test_system_integrity
    
    # Mostrar resumo
    show_summary
    
    # Retornar código de saída baseado no resultado
    if [ "$FAILED_TESTS" -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Executar função principal
main "$@"
