#!/bin/bash

# Sistema de Logging Avançado para Docker Backup
# =============================================
# Autor: BlueAI Solutions
# Data: $(date)

# Configurações de logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Carregar configuração de backup se disponível
if [ -f "$PROJECT_ROOT/config/backup-config.sh" ]; then
    source "$PROJECT_ROOT/config/backup-config.sh"
    # Usar o mesmo diretório base dos backups para os logs
    # Se BACKUP_DIR contém "BlueAI-Docker-Backups", substituir por "BlueAI-Docker-Logs"
    if [[ "$BACKUP_DIR" == *"BlueAI-Docker-Backups"* ]]; then
        LOG_DIR="${BACKUP_DIR//BlueAI-Docker-Backups/BlueAI-Docker-Logs}"
    else
        LOG_DIR="$BACKUP_DIR/logs"
    fi
else
    # Fallback para desenvolvimento local
    LOG_DIR="$PROJECT_ROOT/logs"
fi

# Arquivos de log
BACKUP_LOG="$LOG_DIR/backup.log"
ERROR_LOG="$LOG_DIR/error.log"
SYSTEM_LOG="$LOG_DIR/system.log"
PERFORMANCE_LOG="$LOG_DIR/performance.log"

# Níveis de log
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARNING=2
LOG_LEVEL_ERROR=3
LOG_LEVEL_CRITICAL=4

# Nível atual (pode ser configurado)
# Converter LOG_LEVEL string para número se necessário
if [ -n "$LOG_LEVEL" ]; then
    case "$LOG_LEVEL" in
        "DEBUG") CURRENT_LOG_LEVEL=0 ;;
        "INFO") CURRENT_LOG_LEVEL=1 ;;
        "WARNING") CURRENT_LOG_LEVEL=2 ;;
        "ERROR") CURRENT_LOG_LEVEL=3 ;;
        "CRITICAL") CURRENT_LOG_LEVEL=4 ;;
        *) CURRENT_LOG_LEVEL=1 ;; # Padrão INFO se valor inválido
    esac
else
    CURRENT_LOG_LEVEL=1  # Padrão INFO
fi

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para obter timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Função para obter timestamp com milissegundos
get_timestamp_ms() {
    date '+%Y-%m-%d %H:%M:%S.%3N'
}

# Função para obter nível de log como string
get_log_level_string() {
    local level=$1
    case $level in
        $LOG_LEVEL_DEBUG) echo "DEBUG" ;;
        $LOG_LEVEL_INFO) echo "INFO" ;;
        $LOG_LEVEL_WARNING) echo "WARNING" ;;
        $LOG_LEVEL_ERROR) echo "ERROR" ;;
        $LOG_LEVEL_CRITICAL) echo "CRITICAL" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Função para obter cor do nível
get_log_level_color() {
    local level=$1
    case $level in
        $LOG_LEVEL_DEBUG) echo "$CYAN" ;;
        $LOG_LEVEL_INFO) echo "$GREEN" ;;
        $LOG_LEVEL_WARNING) echo "$YELLOW" ;;
        $LOG_LEVEL_ERROR) echo "$RED" ;;
        $LOG_LEVEL_CRITICAL) echo "$PURPLE" ;;
        *) echo "$NC" ;;
    esac
}

# Função principal de logging
log_message() {
    local level=$1
    local module=$2
    local message=$3
    local log_file=$4
    
    # Verificar se deve logar baseado no nível
    if [ $level -lt $CURRENT_LOG_LEVEL ]; then
        return 0
    fi
    
    local timestamp=$(get_timestamp)
    local level_str=$(get_log_level_string $level)
    local color=$(get_log_level_color $level)
    
    # Formato da mensagem
    local log_entry="[$timestamp] [$level_str] [$module] $message"
    local colored_entry="${color}[$timestamp] [$level_str] [$module]${NC} $message"
    
    # Escrever no arquivo de log
    if [ -n "$log_file" ]; then
        echo "$log_entry" >> "$log_file"
    fi
    
    # Output colorido para terminal
    echo -e "$colored_entry"
}

# Funções específicas por nível
log_debug() {
    log_message $LOG_LEVEL_DEBUG "$1" "$2" "$BACKUP_LOG"
}

log_info() {
    log_message $LOG_LEVEL_INFO "$1" "$2" "$BACKUP_LOG"
}

log_warning() {
    log_message $LOG_LEVEL_WARNING "$1" "$2" "$BACKUP_LOG"
}

log_error() {
    log_message $LOG_LEVEL_ERROR "$1" "$2" "$ERROR_LOG"
}

log_critical() {
    log_message $LOG_LEVEL_CRITICAL "$1" "$2" "$ERROR_LOG"
}

# Função para log de sistema
log_system() {
    local message="$1"
    local timestamp=$(get_timestamp)
    echo "[$timestamp] [SYSTEM] $message" >> "$SYSTEM_LOG"
    echo -e "${BLUE}[$timestamp] [SYSTEM]${NC} $message"
}

# Função para log de performance
log_performance() {
    local operation="$1"
    local duration="$2"
    local details="$3"
    local timestamp=$(get_timestamp)
    echo "[$timestamp] [PERFORMANCE] $operation: ${duration}s - $details" >> "$PERFORMANCE_LOG"
}

# Função para iniciar timer de performance
start_performance_timer() {
    local operation="$1"
    echo "$(date +%s.%3N):$operation"
}

# Função para finalizar timer de performance
end_performance_timer() {
    local timer_start="$1"
    local start_time=$(echo "$timer_start" | cut -d: -f1)
    local operation=$(echo "$timer_start" | cut -d: -f2-)
    local end_time=$(date +%s.%3N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
    
    log_performance "$operation" "$duration" "Concluído"
    echo "$duration"
}

# Função para criar estrutura de logs
init_logging() {
    # Criar diretório de logs se não existir
    mkdir -p "$LOG_DIR"
    
    # Criar arquivos de log se não existirem
    touch "$BACKUP_LOG" "$ERROR_LOG" "$SYSTEM_LOG" "$PERFORMANCE_LOG"
    
    # Definir permissões
    chmod 644 "$BACKUP_LOG" "$ERROR_LOG" "$SYSTEM_LOG" "$PERFORMANCE_LOG"
    
    log_system "Sistema de logging inicializado"
    log_system "Diretório de logs: $LOG_DIR"
    log_system "Nível de log atual: $(get_log_level_string $CURRENT_LOG_LEVEL)"
}

# Função para limpar logs antigos
cleanup_old_logs() {
    local days_to_keep=${1:-30}
    local current_date=$(date +%s)
    local cutoff_date=$((current_date - (days_to_keep * 24 * 60 * 60)))
    
    log_system "Limpando logs mais antigos que $days_to_keep dias"
    
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            local file_date=$(stat -f %m "$log_file" 2>/dev/null || echo "0")
            if [ "$file_date" -lt "$cutoff_date" ]; then
                rm -f "$log_file"
                log_system "Removido log antigo: $(basename "$log_file")"
            fi
        fi
    done
}

# Função para obter estatísticas de log
get_log_stats() {
    local log_file="$1"
    local days=${2:-7}
    
    if [ ! -f "$log_file" ]; then
        echo "Arquivo de log não encontrado: $log_file"
        return 1
    fi
    
    local cutoff_date=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d 2>/dev/null || echo "")
    
    echo "=== Estatísticas de Log: $(basename "$log_file") ==="
    echo "Período: Últimos $days dias"
    echo ""
    
    # Contar por nível
    echo "📊 Distribuição por Nível:"
    grep "\[$cutoff_date" "$log_file" 2>/dev/null | grep -o "\[[A-Z]*\]" | sort | uniq -c | while read count level; do
        echo "  $level: $count"
    done
    
    echo ""
    echo "📈 Total de entradas: $(grep -c "\[$cutoff_date" "$log_file" 2>/dev/null || echo "0")"
}

# Função para buscar em logs
search_logs() {
    local pattern="$1"
    local log_file="$2"
    local lines=${3:-50}
    
    if [ -z "$log_file" ]; then
        log_file="$BACKUP_LOG"
    fi
    
    if [ ! -f "$log_file" ]; then
        echo "Arquivo de log não encontrado: $log_file"
        return 1
    fi
    
    echo "🔍 Buscando '$pattern' em $(basename "$log_file"):"
    echo "================================================"
    
    grep -i "$pattern" "$log_file" | tail -n "$lines" | while read line; do
        echo "$line"
    done
}

# Função para exportar logs
export_logs() {
    local output_file="$1"
    local days=${2:-7}
    
    if [ -z "$output_file" ]; then
        output_file="$LOG_DIR/logs_export_$(date +%Y%m%d_%H%M%S).txt"
    fi
    
    mkdir -p "$(dirname "$output_file")"
    
    echo "=== Exportação de Logs ===" > "$output_file"
    echo "Data: $(date)" >> "$output_file"
    echo "Período: Últimos $days dias" >> "$output_file"
    echo "" >> "$output_file"
    
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            echo "=== $(basename "$log_file") ===" >> "$output_file"
            local cutoff_date=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d 2>/dev/null || echo "")
            grep "\[$cutoff_date" "$log_file" 2>/dev/null >> "$output_file" || true
            echo "" >> "$output_file"
        fi
    done
    
    echo "📁 Logs exportados para: $output_file"
}

# Função para monitorar logs em tempo real
monitor_logs() {
    local log_file="$1"
    
    if [ -z "$log_file" ]; then
        log_file="$BACKUP_LOG"
    fi
    
    if [ ! -f "$log_file" ]; then
        echo "Arquivo de log não encontrado: $log_file"
        return 1
    fi
    
    echo "👀 Monitorando logs em tempo real: $(basename "$log_file")"
    echo "Pressione Ctrl+C para parar"
    echo "================================"
    
    tail -f "$log_file"
}

# Inicializar logging quando o script for carregado
init_logging
