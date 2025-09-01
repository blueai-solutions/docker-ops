#!/bin/bash

# Analisador de Logs Avançado para Docker Backup
# =============================================
# Autor: Assistente IA
# Data: $(date)

# Carregar funções de logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging-functions.sh"

# Configurações
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
REPORTS_DIR="$PROJECT_ROOT/reports"

# Função para mostrar ajuda
show_help() {
    echo "🔍 Analisador de Logs - Docker Backup"
    echo "====================================="
    echo ""
    echo "Uso: $0 [OPÇÕES] [COMANDO]"
    echo ""
    echo "COMANDOS:"
    echo "  --last-24h     Analisar logs das últimas 24 horas"
    echo "  --last-7d      Analisar logs dos últimos 7 dias"
    echo "  --errors       Mostrar apenas erros"
    echo "  --warnings     Mostrar apenas avisos"
    echo "  --performance  Analisar performance dos backups"
    echo "  --stats        Estatísticas gerais"
    echo "  --search PATTERN  Buscar padrão específico"
    echo "  --export       Exportar relatório"
    echo "  --monitor      Monitorar logs em tempo real"
    echo "  --cleanup      Limpar logs antigos"
    echo ""
    echo "OPÇÕES:"
    echo "  --days N       Especificar número de dias (padrão: 7)"
    echo "  --output FILE  Arquivo de saída para exportação"
    echo "  --verbose      Modo verboso"
    echo "  --help         Mostrar esta ajuda"
    echo ""
    echo "EXEMPLOS:"
    echo "  $0 --last-24h"
    echo "  $0 --errors --days 3"
    echo "  $0 --search 'Docker não está rodando'"
    echo "  $0 --performance --export"
}

# Função para analisar logs das últimas N horas
analyze_recent_logs() {
    local hours=$1
    local days=$(echo "scale=2; $hours / 24" | bc -l 2>/dev/null || echo "1")
    
    echo "📊 Análise dos últimos $hours horas ($days dias)"
    echo "================================================"
    echo ""
    
    # Obter data de corte
    local cutoff_date=$(date -d "$hours hours ago" +%Y-%m-%d 2>/dev/null || date -v-${hours}H +%Y-%m-%d 2>/dev/null || echo "")
    
    # Analisar cada arquivo de log
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            local filename=$(basename "$log_file")
            echo "📁 $filename:"
            
            # Contar entradas
            local total_entries=$(grep -c "\[$cutoff_date" "$log_file" 2>/dev/null || echo "0")
            echo "  📈 Total de entradas: $total_entries"
            
            # Distribuição por nível
            if [ "$total_entries" -gt 0 ]; then
                echo "  📊 Distribuição por nível:"
                grep "\[$cutoff_date" "$log_file" 2>/dev/null | grep -o "\[[A-Z]*\]" | sort | uniq -c | while read count level; do
                    echo "    $level: $count"
                done
            fi
            
            echo ""
        fi
    done
}

# Função para analisar erros
analyze_errors() {
    local days=${1:-7}
    
    echo "❌ Análise de Erros - Últimos $days dias"
    echo "========================================"
    echo ""
    
    local cutoff_date=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d 2>/dev/null || echo "")
    
    # Buscar erros em todos os logs
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            local filename=$(basename "$log_file")
            local error_count=$(grep "\[$cutoff_date" "$log_file" 2>/dev/null | grep -c "\[ERROR\]\|\[CRITICAL\]" || echo "0")
            
            if [ "$error_count" -gt 0 ]; then
                echo "📁 $filename ($error_count erros):"
                grep "\[$cutoff_date" "$log_file" 2>/dev/null | grep "\[ERROR\]\|\[CRITICAL\]" | tail -5 | while read line; do
                    echo "  ❌ $line"
                done
                echo ""
            fi
        fi
    done
}

# Função para analisar avisos
analyze_warnings() {
    local days=${1:-7}
    
    echo "⚠️  Análise de Avisos - Últimos $days dias"
    echo "========================================="
    echo ""
    
    local cutoff_date=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d 2>/dev/null || echo "")
    
    # Buscar avisos em todos os logs
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            local filename=$(basename "$log_file")
            local warning_count=$(grep "\[$cutoff_date" "$log_file" 2>/dev/null | grep -c "\[WARNING\]" || echo "0")
            
            if [ "$warning_count" -gt 0 ]; then
                echo "📁 $filename ($warning_count avisos):"
                grep "\[$cutoff_date" "$log_file" 2>/dev/null | grep "\[WARNING\]" | tail -5 | while read line; do
                    echo "  ⚠️  $line"
                done
                echo ""
            fi
        fi
    done
}

# Função para analisar performance
analyze_performance() {
    local days=${1:-7}
    
    echo "⚡ Análise de Performance - Últimos $days dias"
    echo "============================================="
    echo ""
    
    local cutoff_date=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d 2>/dev/null || echo "")
    
    if [ -f "$PERFORMANCE_LOG" ]; then
        echo "📊 Métricas de Performance:"
        echo ""
        
        # Estatísticas gerais
        local total_operations=$(grep "\[$cutoff_date" "$PERFORMANCE_LOG" 2>/dev/null | wc -l)
        echo "📈 Total de operações: $total_operations"
        
        if [ "$total_operations" -gt 0 ]; then
            # Tempo médio por operação
            local avg_time=$(grep "\[$cutoff_date" "$PERFORMANCE_LOG" 2>/dev/null | grep -o "[0-9.]*s" | sed 's/s//' | awk '{sum+=$1} END {print sum/NR}')
            echo "⏱️  Tempo médio por operação: ${avg_time}s"
            
            # Operação mais lenta
            local slowest=$(grep "\[$cutoff_date" "$PERFORMANCE_LOG" 2>/dev/null | sort -k4 -n | tail -1)
            if [ -n "$slowest" ]; then
                echo "🐌 Operação mais lenta: $slowest"
            fi
            
            # Operação mais rápida
            local fastest=$(grep "\[$cutoff_date" "$PERFORMANCE_LOG" 2>/dev/null | sort -k4 -n | head -1)
            if [ -n "$fastest" ]; then
                echo "🚀 Operação mais rápida: $fastest"
            fi
            
            echo ""
            echo "📋 Últimas 10 operações:"
            grep "\[$cutoff_date" "$PERFORMANCE_LOG" 2>/dev/null | tail -10 | while read line; do
                echo "  $line"
            done
        fi
    else
        echo "❌ Arquivo de performance não encontrado"
    fi
}

# Função para gerar estatísticas gerais
generate_stats() {
    local days=${1:-7}
    
    echo "📊 Estatísticas Gerais - Últimos $days dias"
    echo "=========================================="
    echo ""
    
    local cutoff_date=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d 2>/dev/null || echo "")
    
    # Estatísticas por arquivo
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            local filename=$(basename "$log_file")
            local total_entries=$(grep -c "\[$cutoff_date" "$log_file" 2>/dev/null || echo "0")
            
            if [ "$total_entries" -gt 0 ]; then
                echo "📁 $filename:"
                echo "  📈 Total: $total_entries entradas"
                
                # Distribuição por nível
                echo "  📊 Distribuição:"
                grep "\[$cutoff_date" "$log_file" 2>/dev/null | grep -o "\[[A-Z]*\]" | sort | uniq -c | while read count level; do
                    local percentage=$(echo "scale=1; $count * 100 / $total_entries" | bc -l 2>/dev/null || echo "0")
                    echo "    $level: $count ($percentage%)"
                done
                echo ""
            fi
        fi
    done
    
    # Resumo geral
    echo "📋 Resumo Geral:"
    local total_logs=$(find "$LOG_DIR" -name "*.log" -type f | wc -l)
    echo "  📁 Arquivos de log: $total_logs"
    
    local total_entries_all=$(find "$LOG_DIR" -name "*.log" -exec grep -c "\[$cutoff_date" {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
    echo "  📈 Total de entradas: $total_entries_all"
    
    local error_count_all=$(find "$LOG_DIR" -name "*.log" -exec grep "\[$cutoff_date" {} \; 2>/dev/null | grep -c "\[ERROR\]\|\[CRITICAL\]" || echo "0")
    echo "  ❌ Total de erros: $error_count_all"
    
    local warning_count_all=$(find "$LOG_DIR" -name "*.log" -exec grep "\[$cutoff_date" {} \; 2>/dev/null | grep -c "\[WARNING\]" || echo "0")
    echo "  ⚠️  Total de avisos: $warning_count_all"
}

# Função para exportar relatório
export_report() {
    local output_file="$1"
    local days=${2:-7}
    
    if [ -z "$output_file" ]; then
        output_file="$REPORTS_DIR/log_analysis_$(date +%Y%m%d_%H%M%S).txt"
    fi
    
    mkdir -p "$(dirname "$output_file")"
    
    # Redirecionar output para arquivo
    {
        echo "=== Relatório de Análise de Logs ==="
        echo "Data: $(date)"
        echo "Período: Últimos $days dias"
        echo ""
        
        # Gerar todas as análises
        analyze_recent_logs $((days * 24))
        echo ""
        analyze_errors $days
        echo ""
        analyze_warnings $days
        echo ""
        analyze_performance $days
        echo ""
        generate_stats $days
        
    } > "$output_file"
    
    echo "📁 Relatório exportado para: $output_file"
}

# Função principal
main() {
    local command=""
    local days=7
    local output_file=""
    local verbose=false
    
    # Processar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --last-24h)
                command="recent"
                days=1
                shift
                ;;
            --last-7d)
                command="recent"
                days=7
                shift
                ;;
            --errors)
                command="errors"
                shift
                ;;
            --warnings)
                command="warnings"
                shift
                ;;
            --performance)
                command="performance"
                shift
                ;;
            --stats)
                command="stats"
                shift
                ;;
            --search)
                command="search"
                shift
                if [[ $# -gt 0 ]]; then
                    search_pattern="$1"
                    shift
                else
                    echo "❌ Erro: Padrão de busca não especificado"
                    exit 1
                fi
                ;;
            --export)
                command="export"
                shift
                ;;
            --monitor)
                command="monitor"
                shift
                ;;
            --cleanup)
                command="cleanup"
                shift
                ;;
            --days)
                shift
                if [[ $# -gt 0 ]]; then
                    days="$1"
                    shift
                else
                    echo "❌ Erro: Número de dias não especificado"
                    exit 1
                fi
                ;;
            --output)
                shift
                if [[ $# -gt 0 ]]; then
                    output_file="$1"
                    shift
                else
                    echo "❌ Erro: Arquivo de saída não especificado"
                    exit 1
                fi
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "❌ Erro: Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Se nenhum comando foi especificado, mostrar ajuda
    if [ -z "$command" ]; then
        show_help
        exit 0
    fi
    
    # Executar comando
    case $command in
        recent)
            analyze_recent_logs $((days * 24))
            ;;
        errors)
            analyze_errors $days
            ;;
        warnings)
            analyze_warnings $days
            ;;
        performance)
            analyze_performance $days
            ;;
        stats)
            generate_stats $days
            ;;
        search)
            search_logs "$search_pattern"
            ;;
        export)
            export_report "$output_file" $days
            ;;
        monitor)
            monitor_logs
            ;;
        cleanup)
            cleanup_old_logs $days
            ;;
        *)
            echo "❌ Erro: Comando desconhecido: $command"
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
