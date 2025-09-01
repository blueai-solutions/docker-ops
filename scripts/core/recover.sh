#!/bin/bash

# Script principal para recuperação de containers Docker
# Autor: BlueAI Solutions
# Data: $(date)

# Diretório onde estão os scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Função para mostrar ajuda
show_help() {
    echo "🐳 Sistema de Recuperação de Containers Docker"
    echo "=============================================="
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  recover   - Recupera todos os containers (PostgreSQL, MongoDB, RabbitMQ)"
    echo "  start     - Inicia todos os containers"
    echo "  stop      - Para todos os containers"
    echo "  restart   - Reinicia todos os containers"
    echo "  status    - Mostra status dos containers"
    echo "  logs      - Mostra logs dos containers"
    echo "  backup    - Faz backup de todos os volumes"
    echo "  restore   - Restaura backup específico"
    echo "  list      - Lista backups disponíveis"
    echo "  clean     - Para containers e limpa backups antigos"
    echo "  help      - Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 recover    # Recupera todos os containers"
    echo "  $0 status     # Verifica status"
    echo "  $0 backup     # Faz backup dos volumes"
    echo "  $0 start      # Inicia containers"
    echo ""
    echo "📁 Scripts disponíveis:"
    echo "  - recover-containers.sh: Recuperação completa"
    echo "  - manage-containers.sh: Gerenciamento de containers"
    echo "  - backup-volumes.sh: Backup e restauração"
    echo ""
    echo "📖 Para mais detalhes, consulte o README.md"
}

# Função para executar script
run_script() {
    local script_name=$1
    local script_path="$SCRIPT_DIR/$script_name"
    
    if [ -f "$script_path" ]; then
        echo "🚀 Executando: $script_name"
        echo "=================================="
        "$script_path" "${@:2}"
    else
        echo "❌ Erro: Script não encontrado: $script_path"
        exit 1
    fi
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Processar comando
case "$1" in
    recover)
        run_script "recover-containers.sh"
        ;;
    start)
        run_script "manage-containers.sh" "start"
        ;;
    stop)
        run_script "manage-containers.sh" "stop"
        ;;
    restart)
        run_script "manage-containers.sh" "restart"
        ;;
    status)
        run_script "manage-containers.sh" "status"
        ;;
    logs)
        run_script "manage-containers.sh" "logs"
        ;;
    backup)
        BACKUP_DIR="${BACKUP_DIR:-./backups}" run_script "backup-volumes.sh" "backup"
        ;;
    restore)
        if [ -z "$2" ]; then
            echo "❌ Erro: Especifique o arquivo de backup"
            echo "Exemplo: $0 restore postgres-local-data_20241201_143022.tar.gz"
            exit 1
        fi
        run_script "backup-volumes.sh" "restore" "$2"
        ;;
    list)
        run_script "backup-volumes.sh" "list"
        ;;
    clean)
        echo "🧹 Limpeza de containers e backups..."
        echo "====================================="
        echo ""
        echo "1. Limpar containers (mantém volumes):"
        run_script "manage-containers.sh" "clean"
        echo ""
        echo "2. Limpar backups antigos:"
        run_script "backup-volumes.sh" "clean"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Comando inválido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
