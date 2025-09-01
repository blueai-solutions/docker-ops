#!/bin/bash

# Script para recuperar containers Docker com volumes nomeados
# Autor: Assistente IA
# Data: $(date)

set -e  # Para o script se houver erro

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Carregar configuração de recuperação
RECOVERY_CONFIG="$PROJECT_ROOT/config/recovery-config.sh"
if [ -f "$RECOVERY_CONFIG" ]; then
    source "$RECOVERY_CONFIG"
else
    echo "❌ Arquivo de configuração de recuperação não encontrado: $RECOVERY_CONFIG"
    exit 1
fi

echo "🐳 Iniciando recuperação de containers Docker..."
echo "================================================"

# Função para verificar se um container existe
container_exists() {
    docker ps -a --format "{{.Names}}" | grep -q "^$1$"
}

# Função para verificar se um volume existe
volume_exists() {
    docker volume ls --format "{{.Name}}" | grep -q "^$1$"
}

# Função para criar volume se não existir
create_volume_if_not_exists() {
    local volume_name=$1
    if ! volume_exists "$volume_name"; then
        echo "📦 Criando volume: $volume_name"
        docker volume create "$volume_name"
    else
        echo "✅ Volume já existe: $volume_name"
    fi
}

# Função para parar container se existir (sem remover)
stop_container_if_exists() {
    local container_name=$1
    if container_exists "$container_name"; then
        echo "⏸️  Parando container: $container_name"
        docker stop "$container_name" 2>/dev/null || true
    fi
}

# Função para aguardar container estar pronto
wait_for_container() {
    local container_name=$1
    local service_type=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Aguardando container $container_name estar pronto..."
    while [ $attempt -le $max_attempts ]; do
        if docker ps --format "{{.Names}}" | grep -q "^$container_name$"; then
            # Verificar se o container está rodando baseado no tipo de serviço
            case $service_type in
                "postgres"|"psql")
                    if docker exec "$container_name" psql -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
                        echo "✅ Container $container_name está pronto!"
                        return 0
                    fi
                    ;;
                "mongo"|"mongodb")
                    if docker exec "$container_name" mongosh --eval "db.runCommand('ping')" >/dev/null 2>&1; then
                        echo "✅ Container $container_name está pronto!"
                        return 0
                    fi
                    ;;
                "rabbit"|"rabbitmq")
                    if docker exec "$container_name" rabbitmq-diagnostics ping >/dev/null 2>&1; then
                        echo "✅ Container $container_name está pronto!"
                        return 0
                    fi
                    ;;
                "redis")
                    if docker exec "$container_name" redis-cli ping >/dev/null 2>&1; then
                        echo "✅ Container $container_name está pronto!"
                        return 0
                    fi
                    ;;
                "mysql"|"mariadb")
                    if docker exec "$container_name" mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
                        echo "✅ Container $container_name está pronto!"
                        return 0
                    fi
                    ;;
                *)
                    # Verificação genérica para outros containers
                    if docker exec "$container_name" ps aux >/dev/null 2>&1; then
                        echo "✅ Container $container_name está pronto!"
                        return 0
                    fi
                    ;;
            esac
        fi
        echo "   Tentativa $attempt/$max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ Timeout aguardando container $container_name"
    return 1
}

echo ""
echo "🔍 Verificando containers existentes..."

# Listar containers existentes
echo "Containers atualmente rodando:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "📋 Containers parados:"
docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "🚀 Iniciando recuperação..."

# Função para recuperar container baseado na configuração
recover_container() {
    local target="$1"
    local parts=($(echo "$target" | tr ':' '\n'))
    
    if [ ${#parts[@]} -lt 5 ]; then
        echo "❌ Formato inválido para target: $target"
        echo "💡 Formato esperado: container:volume:priority:timeout:health_check:service_type"
        return 1
    fi
    
    local container_name="${parts[0]}"
    local volume_path="${parts[1]}"
    local priority="${parts[2]}"
    local timeout="${parts[3]}"
    local health_check="${parts[4]:-true}"
    local service_type="${parts[5]:-generic}"
    
    # Extrair nome do volume do caminho
    local volume_name=$(echo "$volume_path" | sed 's|.*volumes/||' | sed 's|/_data$||')
    if [ -z "$volume_name" ]; then
        volume_name="${container_name}-data"
    fi
    
    echo ""
    echo "🔧 Recuperando $container_name (Prioridade: $priority)..."
    
    # Criar volume se não existir
    create_volume_if_not_exists "$volume_name"
    
    # Função para extrair configurações dinamicamente de um container existente
    extract_container_config() {
        local container_name="$1"
        local volume_name="$2"
        
        # Verificar se existe um container com esse nome
        if docker ps -a --format "{{.Names}}" | grep -q "^$container_name$"; then
            echo "🔍 Extraindo configurações do container existente: $container_name"
            
            # Extrair imagem
            local image=$(docker inspect "$container_name" --format '{{.Config.Image}}' 2>/dev/null)
            if [ -z "$image" ]; then
                echo "❌ Não foi possível extrair imagem do container"
                return 1
            fi
            
            # Extrair variáveis de ambiente
            local env_vars=""
            local env_list=$(docker inspect "$container_name" --format '{{range .Config.Env}}-e {{.}} {{end}}' 2>/dev/null | tr ' ' '\n' | grep -E '^-e' | tr '\n' ' ')
            if [ -n "$env_list" ]; then
                env_vars="$env_list"
            fi
            
            # Extrair portas
            local ports=""
            local port_list=$(docker inspect "$container_name" --format '{{range $k, $v := .NetworkSettings.Ports}}{{$k}} {{end}}' 2>/dev/null)
            if [ -n "$port_list" ]; then
                ports=$(echo "$port_list" | tr ' ' '\n' | grep -v '^$' | sed 's|/tcp$||' | sed 's|^|-p |' | sed 's|^\([0-9]*\)$|-p \1:\1|' | tr '\n' ' ')
            fi
            
            # Determinar volume correto baseado no tipo de serviço
            local volumes=""
            case $service_type in
                "postgres"|"psql")
                    volumes="-v $volume_name:/var/lib/postgresql/data"
                    ;;
                "mongo"|"mongodb")
                    volumes="-v $volume_name:/data/db"
                    ;;
                "rabbit"|"rabbitmq")
                    volumes="-v $volume_name:/var/lib/rabbitmq"
                    ;;
                "redis")
                    volumes="-v $volume_name:/data"
                    ;;
                "mysql"|"mariadb")
                    volumes="-v $volume_name:/var/lib/mysql"
                    ;;
                *)
                    volumes="-v $volume_name:/data"
                    ;;
            esac
            
            echo "image:$image|env:$env_vars|ports:$ports|volumes:$volumes"
            return 0
        fi
        
        return 1
    }
    
    # Função para obter configurações padrão baseadas no tipo de serviço
    get_default_config() {
        local service_type="$1"
        local volume_name="$2"
        
        case $service_type in
            "postgres"|"psql")
                echo "image:postgres:latest|env:-e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=12345 -e POSTGRES_DB=postgres|ports:-p 5432:5432|volumes:-v $volume_name:/var/lib/postgresql/data"
                ;;
            "mongo"|"mongodb")
                echo "image:mongo:latest|ports:-p 27017:27017|volumes:-v $volume_name:/data/db"
                ;;
            "rabbit"|"rabbitmq")
                echo "image:rabbitmq:3-management|ports:-p 5672:5672 -p 15672:15672|volumes:-v $volume_name:/var/lib/rabbitmq"
                ;;
            "redis")
                echo "image:redis:latest|ports:-p 6379:6379|volumes:-v $volume_name:/data"
                ;;
            "mysql"|"mariadb")
                echo "image:mysql:8.0|env:-e MYSQL_ROOT_PASSWORD=12345 -e MYSQL_DATABASE=mysql|ports:-p 3306:3306|volumes:-v $volume_name:/var/lib/mysql"
                ;;
            *)
                echo "image:alpine:latest|volumes:-v $volume_name:/data"
                ;;
        esac
    }
    
    # Tentar extrair configurações de container existente primeiro
    local container_config=""
    local extracted_config=$(extract_container_config "$container_name" "$volume_name")
    if [ $? -eq 0 ] && [ -n "$extracted_config" ]; then
        container_config="$extracted_config"
        echo "✅ Configurações extraídas do container existente"
    else
        container_config=$(get_default_config "$service_type" "$volume_name")
        echo "📋 Usando configurações padrão para $service_type"
    fi
    
    # Parsear configurações
    local image=$(echo "$container_config" | sed -n 's/.*image:\([^|]*\).*/\1/p')
    local env_vars=$(echo "$container_config" | sed -n 's/.*env:\([^|]*\).*/\1/p')
    local ports=$(echo "$container_config" | sed -n 's/.*ports:\([^|]*\).*/\1/p')
    local volumes=$(echo "$container_config" | sed -n 's/.*volumes:\([^|]*\).*/\1/p')
    
    # Remover container se existir (após detectar configurações)
            stop_container_if_exists "$container_name"
    
    echo "🔧 Criando container $container_name..."
    echo "   Imagem: $image"
    echo "   Volume: $volume_name"
    echo "   Portas: $ports"
    
    # Criar container
    local docker_cmd="docker run -d --name \"$container_name\""
    
    if [ -n "$env_vars" ]; then
        docker_cmd="$docker_cmd $env_vars"
    fi
    
    if [ -n "$volumes" ]; then
        docker_cmd="$docker_cmd $volumes"
    fi
    
    if [ -n "$ports" ]; then
        docker_cmd="$docker_cmd $ports"
    fi
    
    docker_cmd="$docker_cmd \"$image\""
    
    eval "$docker_cmd"
    
    # Aguardar container estar pronto
    wait_for_container "$container_name" "$service_type"
    
    # Verificar se container está funcionando
    if [ "$health_check" = "true" ]; then
        case $service_type in
            "postgres"|"psql")
                if docker exec "$container_name" psql -U postgres -c "SELECT 1;" >/dev/null 2>&1; then
                    echo "✅ $container_name criado com sucesso!"
                    echo "   Bancos disponíveis:"
                    docker exec "$container_name" psql -U postgres -l --no-align --tuples-only | grep -v "template" | grep -v "^$" 2>/dev/null || echo "   Nenhum banco encontrado"
                else
                    echo "❌ Erro ao verificar $container_name"
                fi
                ;;
            "mongo"|"mongodb")
                if docker exec "$container_name" mongosh --eval "db.runCommand('ping')" >/dev/null 2>&1; then
                    echo "✅ $container_name criado com sucesso!"
                    echo "   Bancos disponíveis:"
                    docker exec "$container_name" mongosh --eval "show dbs" --quiet 2>/dev/null || echo "   Nenhum banco encontrado"
                else
                    echo "❌ Erro ao verificar $container_name"
                fi
                ;;
            "rabbit"|"rabbitmq")
                if docker exec "$container_name" rabbitmq-diagnostics ping >/dev/null 2>&1; then
                    echo "✅ $container_name criado com sucesso!"
                    echo "   Interface web disponível em: http://localhost:15672"
                    echo "   Credenciais padrão: guest/guest"
                else
                    echo "❌ Erro ao verificar $container_name"
                fi
                ;;
            "redis")
                if docker exec "$container_name" redis-cli ping >/dev/null 2>&1; then
                    echo "✅ $container_name criado com sucesso!"
                else
                    echo "❌ Erro ao verificar $container_name"
                fi
                ;;
            "mysql"|"mariadb")
                if docker exec "$container_name" mysql -u root -p12345 -e "SELECT 1;" >/dev/null 2>&1; then
                    echo "✅ $container_name criado com sucesso!"
                    echo "   Bancos disponíveis:"
                    docker exec "$container_name" mysql -u root -p12345 -e "SHOW DATABASES;" 2>/dev/null || echo "   Nenhum banco encontrado"
                else
                    echo "❌ Erro ao verificar $container_name"
                fi
                ;;
            *)
                if docker exec "$container_name" ps aux >/dev/null 2>&1; then
                    echo "✅ $container_name criado com sucesso!"
                else
                    echo "❌ Erro ao verificar $container_name"
                fi
                ;;
        esac
    else
        echo "✅ $container_name criado (health check desabilitado)"
    fi
}

# Recuperar containers baseado na configuração
if [ ${#RECOVERY_TARGETS[@]} -eq 0 ]; then
    echo "❌ Nenhum container configurado para recuperação"
    echo "💡 Use './blueai-docker-ops.sh recovery config' para configurar containers"
    exit 1
fi

# Ordenar containers por prioridade
sorted_targets=($(for target in "${RECOVERY_TARGETS[@]}"; do
    parts=($(echo "$target" | tr ':' '\n'))
    priority="${parts[2]}"
    echo "$priority:$target"
done | sort -n | cut -d: -f2-))

# Recuperar cada container
for target in "${sorted_targets[@]}"; do
    if ! recover_container "$target"; then
        echo "❌ Falha ao recuperar container: $target"
    fi
done

# ========================================
# RESUMO FINAL
# ========================================
echo ""
echo "🎉 Recuperação concluída!"
echo "================================================"
echo ""
echo "📊 Status dos containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "📋 Volumes criados:"
docker volume ls --format "table {{.Name}}\t{{.Driver}}"

echo ""
echo "🔗 Informações de conexão:"
# Gerar informações de conexão dinamicamente
for target in "${RECOVERY_TARGETS[@]}"; do
    parts=($(echo "$target" | tr ':' '\n'))
    container_name="${parts[0]}"
    service_type="${parts[5]:-generic}"
    
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
        "mysql"|"mariadb")
            echo "   $container_name: localhost:3306 (root/12345)"
            ;;
        *)
            echo "   $container_name: Container genérico"
            ;;
    esac
done

echo ""
echo "💡 Comandos úteis:"
echo "   Ver logs: docker logs <container-name>"
echo "   Acessar shell: docker exec -it <container-name> bash"

# Gerar comandos de parar/iniciar dinamicamente
stop_containers=""
start_containers=""
for target in "${RECOVERY_TARGETS[@]}"; do
    parts=($(echo "$target" | tr ':' '\n'))
    container_name="${parts[0]}"
    stop_containers="$stop_containers $container_name"
    start_containers="$start_containers $container_name"
done

echo "   Parar todos: docker stop$stop_containers"
echo "   Iniciar todos: docker start$start_containers"

echo ""
echo "✅ Recuperação finalizada com sucesso!"
