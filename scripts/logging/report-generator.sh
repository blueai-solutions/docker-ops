#!/bin/bash

# Gerador de Relatórios HTML para BlueAI Docker Ops
# ============================================
# Autor: BlueAI Solutions
# Data: $(date)

# Carregar funções de logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging-functions.sh"

# Configurações
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Carregar configuração de versão
VERSION_CONFIG="$PROJECT_ROOT/config/version-config.sh"
if [ -f "$VERSION_CONFIG" ]; then
    source "$VERSION_CONFIG"
else
    echo "❌ Arquivo de configuração de versão não encontrado"
    exit 1
fi
LOG_DIR="$PROJECT_ROOT/logs"
REPORTS_DIR="$PROJECT_ROOT/reports"
BACKUP_DIR="$PROJECT_ROOT/backups"

# Função para gerar CSS
generate_css() {
    cat << 'EOF'
<style>
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 0;
    padding: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    background: white;
    border-radius: 15px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.1);
    overflow: hidden;
}

.header {
    background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
    color: white;
    padding: 30px;
    text-align: center;
}

.header h1 {
    margin: 0;
    font-size: 2.5em;
    font-weight: 300;
}

.header .subtitle {
    margin-top: 10px;
    opacity: 0.8;
    font-size: 1.1em;
}

.content {
    padding: 30px;
}

.section {
    margin-bottom: 40px;
    background: #f8f9fa;
    border-radius: 10px;
    padding: 25px;
    border-left: 5px solid #3498db;
}

.section h2 {
    margin-top: 0;
    color: #2c3e50;
    font-size: 1.8em;
    border-bottom: 2px solid #ecf0f1;
    padding-bottom: 10px;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin: 20px 0;
}

.stat-card {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    text-align: center;
    border-top: 4px solid #3498db;
}

.stat-card.success {
    border-top-color: #27ae60;
}

.stat-card.warning {
    border-top-color: #f39c12;
}

.stat-card.error {
    border-top-color: #e74c3c;
}

.stat-number {
    font-size: 2.5em;
    font-weight: bold;
    color: #2c3e50;
    margin-bottom: 10px;
}

.stat-label {
    color: #7f8c8d;
    font-size: 0.9em;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.log-table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
    background: white;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}

.log-table th {
    background: #34495e;
    color: white;
    padding: 15px;
    text-align: left;
    font-weight: 600;
}

.log-table td {
    padding: 12px 15px;
    border-bottom: 1px solid #ecf0f1;
}

.log-table tr:hover {
    background: #f8f9fa;
}

.log-level {
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.8em;
    font-weight: bold;
    text-transform: uppercase;
}

.log-level.debug { background: #bdc3c7; color: white; }
.log-level.info { background: #3498db; color: white; }
.log-level.warning { background: #f39c12; color: white; }
.log-level.error { background: #e74c3c; color: white; }
.log-level.critical { background: #8e44ad; color: white; }

.chart-container {
    background: white;
    padding: 20px;
    border-radius: 10px;
    margin: 20px 0;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}

.progress-bar {
    width: 100%;
    height: 20px;
    background: #ecf0f1;
    border-radius: 10px;
    overflow: hidden;
    margin: 10px 0;
}

.progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #3498db, #2980b9);
    transition: width 0.3s ease;
}

.progress-fill.success { background: linear-gradient(90deg, #27ae60, #229954); }
.progress-fill.warning { background: linear-gradient(90deg, #f39c12, #e67e22); }
.progress-fill.error { background: linear-gradient(90deg, #e74c3c, #c0392b); }

.footer {
    background: #2c3e50;
    color: white;
    text-align: center;
    padding: 20px;
    font-size: 0.9em;
}

.timestamp {
    color: #7f8c8d;
    font-size: 0.8em;
}

.alert {
    padding: 15px;
    border-radius: 8px;
    margin: 15px 0;
    border-left: 4px solid;
}

.alert.success {
    background: #d4edda;
    border-color: #27ae60;
    color: #155724;
}

.alert.warning {
    background: #fff3cd;
    border-color: #f39c12;
    color: #856404;
}

.alert.error {
    background: #f8d7da;
    border-color: #e74c3c;
    color: #721c24;
}

@media (max-width: 768px) {
    .stats-grid {
        grid-template-columns: 1fr;
    }
    
    .container {
        margin: 10px;
        border-radius: 10px;
    }
    
    .content {
        padding: 20px;
    }
}
</style>
EOF
}

# Função para gerar JavaScript
generate_js() {
    cat << 'EOF'
<script>
// Função para atualizar progress bars
function updateProgressBars() {
    const progressBars = document.querySelectorAll('.progress-fill');
    progressBars.forEach(bar => {
        const width = bar.getAttribute('data-width');
        bar.style.width = width + '%';
    });
}

// Função para ordenar tabelas
function sortTable(table, column) {
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    
    rows.sort((a, b) => {
        const aVal = a.cells[column].textContent;
        const bVal = b.cells[column].textContent;
        return aVal.localeCompare(bVal);
    });
    
    rows.forEach(row => tbody.appendChild(row));
}

// Função para filtrar logs por nível
function filterLogs(level) {
    const rows = document.querySelectorAll('.log-table tbody tr');
    rows.forEach(row => {
        const logLevel = row.querySelector('.log-level');
        if (level === 'all' || logLevel.classList.contains(level)) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

// Função para exportar dados
function exportData() {
    const data = {
        timestamp: new Date().toISOString(),
        stats: {},
        logs: []
    };
    
    // Coletar estatísticas
    document.querySelectorAll('.stat-number').forEach(stat => {
        const label = stat.nextElementSibling.textContent;
        data.stats[label] = stat.textContent;
    });
    
    // Coletar logs
    document.querySelectorAll('.log-table tbody tr').forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length >= 4) {
            data.logs.push({
                timestamp: cells[0].textContent,
                level: cells[1].textContent,
                module: cells[2].textContent,
                message: cells[3].textContent
            });
        }
    });
    
    // Download do arquivo
    const blob = new Blob([JSON.stringify(data, null, 2)], {type: 'application/json'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'backup-report-' + new Date().toISOString().split('T')[0] + '.json';
    a.click();
    URL.revokeObjectURL(url);
}

// Inicializar quando a página carregar
document.addEventListener('DOMContentLoaded', function() {
    updateProgressBars();
    
    // Adicionar listeners para filtros
    const filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            const level = this.getAttribute('data-level');
            filterLogs(level);
        });
    });
});
</script>
EOF
}

# Função para gerar cabeçalho HTML
generate_header() {
    local title="$1"
    local subtitle="$2"
    
    cat << EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    $(generate_css)
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🐳 $SYSTEM_NAME</h1>
            <div class="subtitle">$subtitle</div>
        </div>
        <div class="content">
EOF
}

# Função para gerar rodapé HTML
generate_footer() {
    cat << EOF
        </div>
        <div class="footer">
            <p>Relatório gerado automaticamente pelo $SYSTEM_NAME</p>
            <p class="timestamp">Gerado em: $(date)</p>
        </div>
    </div>
    $(generate_js)
</body>
</html>
EOF
}

# Função para gerar seção de estatísticas
generate_stats_section() {
    local days=$1
    
    echo '<div class="section">'
    echo '<h2>📊 Estatísticas Gerais</h2>'
    echo '<div class="stats-grid">'
    
    # Estatísticas básicas
    local total_backups=$(find "$BACKUP_DIR" -name "*.tar.gz" -type f | wc -l)
    local total_logs=$(find "$LOG_DIR" -name "*.log" -type f | wc -l)
    local error_count=$(grep -c "\[ERROR\]\|\[CRITICAL\]" "$LOG_DIR"/*.log 2>/dev/null || echo "0")
    local warning_count=$(grep -c "\[WARNING\]" "$LOG_DIR"/*.log 2>/dev/null || echo "0")
    
    echo "<div class='stat-card success'>"
    echo "<div class='stat-number'>$total_backups</div>"
    echo "<div class='stat-label'>Total de Backups</div>"
    echo "</div>"
    
    echo "<div class='stat-card'>"
    echo "<div class='stat-number'>$total_logs</div>"
    echo "<div class='stat-label'>Arquivos de Log</div>"
    echo "</div>"
    
    echo "<div class='stat-card warning'>"
    echo "<div class='stat-number'>$warning_count</div>"
    echo "<div class='stat-label'>Avisos</div>"
    echo "</div>"
    
    echo "<div class='stat-card error'>"
    echo "<div class='stat-number'>$error_count</div>"
    echo "<div class='stat-label'>Erros</div>"
    echo "</div>"
    
    echo '</div>'
    echo '</div>'
}

# Função para gerar seção de logs recentes
generate_recent_logs_section() {
    local days=$1
    local log_file="$LOG_DIR/backup.log"
    
    if [ ! -f "$log_file" ]; then
        echo '<div class="section">'
        echo '<h2>📝 Logs Recentes</h2>'
        echo '<div class="alert warning">Nenhum arquivo de log encontrado.</div>'
        echo '</div>'
        return
    fi
    
    echo '<div class="section">'
    echo '<h2>📝 Logs Recentes</h2>'
    
    # Filtros
    echo '<div style="margin-bottom: 20px;">'
    echo '<button class="filter-btn" data-level="all" style="margin-right: 10px; padding: 8px 16px; border: none; border-radius: 5px; background: #3498db; color: white; cursor: pointer;">Todos</button>'
    echo '<button class="filter-btn" data-level="info" style="margin-right: 10px; padding: 8px 16px; border: none; border-radius: 5px; background: #27ae60; color: white; cursor: pointer;">Info</button>'
    echo '<button class="filter-btn" data-level="warning" style="margin-right: 10px; padding: 8px 16px; border: none; border-radius: 5px; background: #f39c12; color: white; cursor: pointer;">Avisos</button>'
    echo '<button class="filter-btn" data-level="error" style="margin-right: 10px; padding: 8px 16px; border: none; border-radius: 5px; background: #e74c3c; color: white; cursor: pointer;">Erros</button>'
    echo '</div>'
    
    # Tabela de logs
    echo '<table class="log-table">'
    echo '<thead>'
    echo '<tr>'
    echo '<th>Timestamp</th>'
    echo '<th>Nível</th>'
    echo '<th>Módulo</th>'
    echo '<th>Mensagem</th>'
    echo '</tr>'
    echo '</thead>'
    echo '<tbody>'
    
    # Obter logs recentes
    local cutoff_date=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d 2>/dev/null || echo "")
    grep "\[$cutoff_date" "$log_file" 2>/dev/null | tail -20 | while read line; do
        # Parse da linha de log
        local timestamp=$(echo "$line" | sed -n 's/\[\([^]]*\)\] \[.*/\1/p')
        local level=$(echo "$line" | sed -n 's/.*\[\([A-Z]*\)\] \[.*/\1/p')
        local module=$(echo "$line" | sed -n 's/.*\[[A-Z]*\] \[\([^]]*\)\] .*/\1/p')
        local message=$(echo "$line" | sed -n 's/.*\[[A-Z]*\] \[[^]]*\] \(.*\)/\1/p')
        
        if [ -n "$timestamp" ]; then
            echo "<tr>"
            echo "<td>$timestamp</td>"
            echo "<td><span class='log-level $level'>$level</span></td>"
            echo "<td>$module</td>"
            echo "<td>$message</td>"
            echo "</tr>"
        fi
    done
    
    echo '</tbody>'
    echo '</table>'
    echo '</div>'
}

# Função para gerar seção de performance
generate_performance_section() {
    local performance_log="$LOG_DIR/performance.log"
    
    if [ ! -f "$performance_log" ]; then
        echo '<div class="section">'
        echo '<h2>⚡ Performance</h2>'
        echo '<div class="alert warning">Nenhum dado de performance encontrado.</div>'
        echo '</div>'
        return
    fi
    
    echo '<div class="section">'
    echo '<h2>⚡ Performance</h2>'
    
    # Estatísticas de performance
    local total_ops=$(wc -l < "$performance_log")
    local avg_time=$(awk '{sum+=$4} END {print sum/NR}' "$performance_log" 2>/dev/null || echo "0")
    local max_time=$(awk '{if($4>max) max=$4} END {print max}' "$performance_log" 2>/dev/null || echo "0")
    
    echo '<div class="stats-grid">'
    echo "<div class='stat-card'>"
    echo "<div class='stat-number'>$total_ops</div>"
    echo "<div class='stat-label'>Total de Operações</div>"
    echo "</div>"
    
    echo "<div class='stat-card'>"
    echo "<div class='stat-number'>${avg_time}s</div>"
    echo "<div class='stat-label'>Tempo Médio</div>"
    echo "</div>"
    
    echo "<div class='stat-card'>"
    echo "<div class='stat-number'>${max_time}s</div>"
    echo "<div class='stat-label'>Tempo Máximo</div>"
    echo "</div>"
    echo '</div>'
    
    # Gráfico de performance
    echo '<div class="chart-container">'
    echo '<h3>Últimas Operações</h3>'
    echo '<table class="log-table">'
    echo '<thead>'
    echo '<tr>'
    echo '<th>Timestamp</th>'
    echo '<th>Operação</th>'
    echo '<th>Duração</th>'
    echo '<th>Status</th>'
    echo '</tr>'
    echo '</thead>'
    echo '<tbody>'
    
    tail -10 "$performance_log" | while read line; do
        local timestamp=$(echo "$line" | awk '{print $1, $2}')
        local operation=$(echo "$line" | awk '{print $4}' | sed 's/://')
        local duration=$(echo "$line" | awk '{print $5}' | sed 's/s//')
        local status=$(echo "$line" | awk '{print $7}')
        
        echo "<tr>"
        echo "<td>$timestamp</td>"
        echo "<td>$operation</td>"
        echo "<td>${duration}s</td>"
        echo "<td>$status</td>"
        echo "</tr>"
    done
    
    echo '</tbody>'
    echo '</table>'
    echo '</div>'
    echo '</div>'
}

# Função para gerar seção de backups
generate_backups_section() {
    echo '<div class="section">'
    echo '<h2>💾 Backups Disponíveis</h2>'
    
    local backup_files=$(find "$BACKUP_DIR" -name "*.tar.gz" -type f | wc -l)
    
    if [ "$backup_files" -eq 0 ]; then
        echo '<div class="alert warning">Nenhum backup encontrado.</div>'
    else
        echo '<table class="log-table">'
        echo '<thead>'
        echo '<tr>'
        echo '<th>Nome do Arquivo</th>'
        echo '<th>Tamanho</th>'
        echo '<th>Data de Criação</th>'
        echo '</tr>'
        echo '</thead>'
        echo '<tbody>'
        
        find "$BACKUP_DIR" -name "*.tar.gz" -type f -exec ls -lh {} \; | sort -k6,7 | tail -10 | while read line; do
            local size=$(echo "$line" | awk '{print $5}')
            local date=$(echo "$line" | awk '{print $6, $7}')
            local filename=$(echo "$line" | awk '{print $9}' | sed 's/.*\///')
            
            echo "<tr>"
            echo "<td>$filename</td>"
            echo "<td>$size</td>"
            echo "<td>$date</td>"
            echo "</tr>"
        done
        
        echo '</tbody>'
        echo '</table>'
    fi
    
    echo '</div>'
}

# Função para mostrar ajuda
show_help() {
    echo "🐳 Gerador de Relatórios HTML - $SYSTEM_NAME"
    echo "============================================="
    echo ""
    echo "📋 Uso: $0 [arquivo_saida] [dias]"
    echo ""
    echo "🔧 Argumentos:"
    echo "  arquivo_saida  - Nome do arquivo HTML de saída (opcional)"
    echo "  dias          - Número de dias para análise (padrão: 7)"
    echo ""
    echo "📝 Exemplos:"
    echo "  $0                                    # Gera relatório com nome automático"
    echo "  $0 relatorio.html                     # Gera relatório com nome específico"
    echo "  $0 relatorio.html 30                  # Análise dos últimos 30 dias"
    echo "  $0 reports/meu_relatorio.html 14      # Análise dos últimos 14 dias"
    echo ""
    echo "💡 Dica: Se não especificar arquivo de saída, será gerado automaticamente"
    echo "         no diretório reports/ com timestamp"
}

# Função principal
main() {
    local output_file="$1"
    local days=${2:-7}
    
    # Verificar se o primeiro argumento é help
    if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        return 0
    fi
    
    # Validar número de dias
    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        echo "❌ Erro: Número de dias deve ser um número inteiro"
        echo "💡 Use: $0 [arquivo_saida] [dias]"
        return 1
    fi
    
    # Se não foi especificado arquivo de saída, gerar nome automático
    if [ -z "$output_file" ]; then
        output_file="$REPORTS_DIR/backup_report_$(date +%Y%m%d_%H%M%S).html"
    fi
    
    # Verificar se o arquivo de saída tem extensão .html
    if [[ ! "$output_file" =~ \.html$ ]]; then
        output_file="${output_file}.html"
    fi
    
    mkdir -p "$(dirname "$output_file")"
    
    # Gerar relatório HTML
    {
        generate_header "Relatório de Backup Docker" "Análise dos últimos $days dias"
        generate_stats_section $days
        generate_recent_logs_section $days
        generate_performance_section
        generate_backups_section
        generate_footer
    } > "$output_file"
    
    echo "📁 Relatório HTML gerado: $output_file"
    echo "🌐 Abra no navegador para visualizar"
}

# Executar função principal
main "$@"
