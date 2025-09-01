#!/bin/bash

# Script para gerenciar containers Docker
# Autor: BlueAI Solutions
# Data: $(date)

# Carregar configuração de recuperação
CONFIG_FILE="$(dirname "$0")/../../config/recovery-config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    # Extrair nomes dos containers da configuração
    CONTAINERS=()
    for target in "${RECOVERY_TARGETS[@]}"; do
        parts=($(echo "$target" | tr ':' '\n'))
        if [ ${#parts[@]} -ge 5 ]; then
            CONTAINERS+=("${parts[0]}")
        fi
    done
else
    # Fallback para lista padrão se arquivo não existir
    CONTAINERS=("postgres-local" "mongo-local" "rabbit-local")
fi

# Função para mostrar ajuda
show_help() {
    echo "🐳 Gerenciador de Containers Docker"
    echo "===================================="
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  start     - Inicia todos os containers"
    echo "  stop      - Para todos os containers"
    echo "  restart   - Reinicia todos os containers"
    echo "  status    - Mostra status dos containers"
    echo "  logs      - Mostra logs dos containers"
    echo "  clean     - Para containers (sem remover)"
    echo "  help      - Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 logs"
}

# Função para verificar se container existe
container_exists() {
    docker ps -a --format "{{.Names}}" | grep -q "^$1$"
}

# Função para verificar se container está rodando
container_running() {
    docker ps --format "{{.Names}}" | grep -q "^$1$"
}

# Função para iniciar containers
start_containers() {
    echo "🚀 Iniciando containers..."
    for container in "${CONTAINERS[@]}"; do
        if container_exists "$container"; then
            if ! container_running "$container"; then
                echo "  ▶️  Iniciando $container..."
                docker start "$container"
            else
                echo "  ✅ $container já está rodando"
            fi
        else
            echo "  ❌ Container $container não existe"
        fi
    done
    echo "✅ Inicialização concluída!"
}

# Função para parar containers
stop_containers() {
    echo "🛑 Parando containers..."
    for container in "${CONTAINERS[@]}"; do
        if container_running "$container"; then
            echo "  ⏹️  Parando $container..."
            docker stop "$container"
        else
            echo "  ✅ $container já está parado"
        fi
    done
    echo "✅ Parada concluída!"
}

# Função para reiniciar containers
restart_containers() {
    echo "🔄 Reiniciando containers..."
    stop_containers
    sleep 2
    start_containers
    echo "✅ Reinicialização concluída!"
}

# Função para mostrar status
show_status() {
    echo "📊 Status dos Containers"
    echo "========================"
    echo ""
    
    # Construir filtro dinâmico para containers
    local container_filter=""
    for container in "${CONTAINERS[@]}"; do
        if [ -n "$container_filter" ]; then
            container_filter="$container_filter|$container"
        else
            container_filter="$container"
        fi
    done
    
    # Construir filtro dinâmico para volumes
    local volume_filter=""
    for target in "${RECOVERY_TARGETS[@]}"; do
        local parts=($(echo "$target" | tr ':' '\n'))
        if [ ${#parts[@]} -ge 5 ]; then
            local volume_name=$(echo "${parts[1]}" | sed 's|/var/lib/docker/volumes/||' | sed 's|/_data||')
            if [ -n "$volume_filter" ]; then
                volume_filter="$volume_filter|$volume_name"
            else
                volume_filter="$volume_name"
            fi
        fi
    done
    
    # Containers rodando
    echo "🟢 Containers Rodando:"
    if [ -n "$container_filter" ]; then
        docker ps --filter "name=$container_filter" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        echo "  Nenhum container configurado"
    fi
    
    echo ""
    echo "🔴 Containers Parados:"
    if [ -n "$container_filter" ]; then
        docker ps -a --filter "name=$container_filter" --filter "status=exited" --format "table {{.Names}}\t{{.Status}}"
    else
        echo "  Nenhum container configurado"
    fi
    
    echo ""
    echo "📋 Volumes:"
    if [ -n "$volume_filter" ]; then
        docker volume ls --filter "name=$volume_filter" --format "table {{.Name}}\t{{.Driver}}"
    else
        echo "  Nenhum volume configurado"
    fi
    
    echo ""
    echo "🔗 Informações de Conexão:"
    for target in "${RECOVERY_TARGETS[@]}"; do
        local parts=($(echo "$target" | tr ':' '\n'))
        if [ ${#parts[@]} -ge 6 ]; then
            local container_name="${parts[0]}"
            local service_type="${parts[5]}"
            case $service_type in
                "postgres"|"psql")
                    echo "   $container_name: localhost:5432 (postgres/12345)"
                    ;;
                "mongo"|"mongodb")
                    echo "   $container_name: localhost:27017"
                    ;;
                "rabbit"|"rabbitmq")
                    echo "   $container_name: localhost:5672 (AMQP)"
                    echo "   $container_name Web UI: http://localhost:15672 (guest/guest)"
                    ;;
                "redis")
                    echo "   $container_name: localhost:6379"
                    ;;
                *)
                    echo "   $container_name: tipo $service_type"
                    ;;
            esac
        fi
    done
}

# Função para mostrar logs
show_logs() {
    echo "📝 Logs dos Containers"
    echo "======================"
    echo ""
    
    for container in "${CONTAINERS[@]}"; do
        if container_exists "$container"; then
            echo "📋 Logs de $container:"
            echo "----------------------------------------"
            docker logs --tail 10 "$container" 2>/dev/null || echo "  Nenhum log disponível"
            echo ""
        fi
    done
}

# Função para parar containers (sem remover)
clean_containers() {
    echo "⏸️  Parando containers (sem remover)..."
    for container in "${CONTAINERS[@]}"; do
        if container_exists "$container"; then
            echo "  ⏸️  Parando $container..."
            docker stop "$container" 2>/dev/null || true
        fi
    done
    echo "✅ Containers parados!"
    echo "💡 Containers foram parados mas não removidos. Use 'start' para reiniciá-los."
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Processar comando
case "$1" in
    start)
        start_containers
        ;;
    stop)
        stop_containers
        ;;
    restart)
        restart_containers
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_containers
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
