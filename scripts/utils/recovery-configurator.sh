#!/bin/bash

# =============================================================================
# CONFIGURADOR INTERATIVO DE RECUPERAÇÃO DE CONTAINERS
# =============================================================================

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RECOVERY_CONFIG="$PROJECT_ROOT/config/recovery-config.sh"
RECOVERY_CONFIG_BACKUP=""
RECOVERY_CONFIG_DIR="$PROJECT_ROOT/config/backups"

# Carregar funções de logging
source "$SCRIPT_DIR/../logging/logging-functions.sh"

# Arrays para armazenar dados
declare -a CONTAINERS=()
declare -a CONTAINER_NAMES=()
declare -a CONTAINER_IMAGES=()
declare -a CONTAINER_VOLUMES=()
declare -a CONTAINER_PORTS=()
declare -a CONTAINER_ENV=()
declare -a CONTAINER_NETWORKS=()
declare -a SELECTED_CONTAINERS=()
declare -a CONTAINER_PRIORITIES=()
declare -a CONTAINER_TIMEOUTS=()
declare -a CONTAINER_HEALTH_CHECKS=()
declare -a CONTAINER_TEMPLATES=()

# Função para mostrar ajuda
show_help() {
    echo "🔄 Configurador de Recuperação de Containers"
    echo "============================================"
    echo ""
    echo "Uso: $0 [opções]"
    echo ""
    echo "OPÇÕES:"
    echo "  --help, -h     Mostrar esta ajuda"
    echo "  --preview      Mostrar preview da configuração atual"
    echo "  --validate     Validar configuração atual"
    echo "  --reset        Resetar para configuração padrão"
    echo ""
    echo "EXEMPLOS:"
    echo "  $0              # Modo interativo"
    echo "  $0 --preview    # Preview da configuração"
    echo "  $0 --validate   # Validar configuração"
}

# Função para detectar containers Docker
detect_containers() {
    log_info "DETECT" "Detectando containers Docker..."
    
    # Verificar se Docker está rodando
    if ! docker info >/dev/null 2>&1; then
        log_error "DETECT" "Docker não está rodando"
        return 1
    fi
    
    # Obter lista de containers (incluindo parados)
    local docker_containers=$(docker ps -a --format "{{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null)
    
    if [ -z "$docker_containers" ]; then
        log_warning "DETECT" "Nenhum container encontrado"
        return 0
    fi
    
    # Processar containers
    while IFS=$'\t' read -r name image status; do
        if [ -n "$name" ]; then
            CONTAINER_NAMES+=("$name")
            CONTAINER_IMAGES+=("$image")
            
            # Detectar volumes
            local volumes=$(docker inspect "$name" --format '{{range .Mounts}}{{.Source}} {{end}}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
            if [ -n "$volumes" ]; then
                CONTAINER_VOLUMES+=("$volumes")
            else
                CONTAINER_VOLUMES+=("")
            fi
            
            # Detectar portas
            local ports=$(docker inspect "$name" --format '{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{$p}} {{end}}{{end}}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
            if [ -n "$ports" ]; then
                CONTAINER_PORTS+=("$ports")
            else
                CONTAINER_PORTS+=("")
            fi
            
            # Detectar redes
            local networks=$(docker inspect "$name" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
            if [ -n "$networks" ]; then
                CONTAINER_NETWORKS+=("$networks")
            else
                CONTAINER_NETWORKS+=("")
            fi
            
            # Detectar variáveis de ambiente
            local env_vars=$(docker inspect "$name" --format '{{range .Config.Env}}{{.}} {{end}}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -3 | tr '\n' ' ')
            if [ -n "$env_vars" ]; then
                CONTAINER_ENV+=("$env_vars")
            else
                CONTAINER_ENV+=("")
            fi
        fi
    done <<< "$docker_containers"
    
    log_info "DETECT" "Encontrados ${#CONTAINER_NAMES[@]} containers"
}

# Função para carregar configuração atual
load_current_config() {
    log_info "CONFIG" "Carregando configuração atual..."
    
    if [ -f "$RECOVERY_CONFIG" ]; then
        source "$RECOVERY_CONFIG"
        
        # Processar RECOVERY_TARGETS existente
        for target in "${RECOVERY_TARGETS[@]}"; do
            local parts=($(echo "$target" | tr ':' '\n'))
            if [ ${#parts[@]} -eq 5 ]; then
                local container="${parts[0]}"
                local volume="${parts[1]}"
                local priority="${parts[2]}"
                local timeout="${parts[3]}"
                local health_check="${parts[4]}"
                
                SELECTED_CONTAINERS+=("$container")
                CONTAINER_PRIORITIES+=("$priority")
                CONTAINER_TIMEOUTS+=("$timeout")
                CONTAINER_HEALTH_CHECKS+=("$health_check")
            fi
        done
    fi
}

# Função para detectar template do container
detect_container_template() {
    local image="$1"
    local name="$2"
    
    # Detectar templates baseados na imagem ou nome
    case "$image" in
        *postgres*|*psql*)
            echo "postgresql"
            ;;
        *mongo*|*mongod*)
            echo "mongodb"
            ;;
        *rabbit*|*amqp*)
            echo "rabbitmq"
            ;;
        *redis*)
            echo "redis"
            ;;
        *mysql*|*mariadb*)
            echo "mysql"
            ;;
        *nginx*)
            echo "nginx"
            ;;
        *apache*|*httpd*)
            echo "apache"
            ;;
        *)
            echo "custom"
            ;;
    esac
}

# Função para mostrar menu principal
show_main_menu() {
    clear
    echo "🔄 Configurador de Recuperação de Containers"
    echo "============================================"
    echo ""
    
    # Mostrar containers detectados
    echo "📦 Containers Detectados (${#CONTAINER_NAMES[@]}):"
    for i in "${!CONTAINER_NAMES[@]}"; do
        local name="${CONTAINER_NAMES[$i]}"
        local image="${CONTAINER_IMAGES[$i]}"
        local volume="${CONTAINER_VOLUMES[$i]}"
        local ports="${CONTAINER_PORTS[$i]}"
        
        # Verificar se está selecionado
        local selected=false
        local priority=""
        local timeout=""
        local health_check=""
        
        for j in "${!SELECTED_CONTAINERS[@]}"; do
            if [ "${SELECTED_CONTAINERS[$j]}" = "$name" ]; then
                selected=true
                priority="${CONTAINER_PRIORITIES[$j]}"
                timeout="${CONTAINER_TIMEOUTS[$j]}"
                health_check="${CONTAINER_HEALTH_CHECKS[$j]}"
                break
            fi
        done
        
        if [ "$selected" = true ]; then
            local priority_icon=""
            case "$priority" in
                "1") priority_icon="🔴 Alta" ;;
                "2") priority_icon="🟡 Média" ;;
                "3") priority_icon="🟢 Baixa" ;;
                *) priority_icon="⚪ Não definida" ;;
            esac
            
            local health_icon=""
            case "$health_check" in
                "true") health_icon="✅ Verificar" ;;
                "false") health_icon="❌ Não verificar" ;;
                *) health_icon="⚪ Não definido" ;;
            esac
            
            echo "[✓] $name ($image) - $priority_icon - ${timeout}s - $health_icon"
            if [ -n "$volume" ]; then
                echo "    Volume: $volume"
            fi
            if [ -n "$ports" ]; then
                echo "    Porta: $ports"
            fi
        else
            echo "[ ] $name ($image)"
            if [ -n "$volume" ]; then
                echo "    Volume: $volume"
            fi
            if [ -n "$ports" ]; then
                echo "    Porta: $ports"
            fi
        fi
        echo ""
    done
    
    # Mostrar opções
    echo "🔧 Ações:"
    echo "1. Marcar/Desmarcar container"
    echo "2. Marcar todos os containers"
    echo "3. Desmarcar todos os containers"
    echo "4. Configurar prioridade"
    echo "5. Configurar timeout"
    echo "6. Configurar health check"
    echo "7. Visualizar configuração atual"
    echo "8. Salvar e sair"
    echo "9. Sair sem salvar"
    echo ""
}

# Função para marcar/desmarcar container
toggle_container() {
    show_main_menu
    echo "📦 Marcar/Desmarcar Container"
    echo "============================="
    echo ""
    
    # Listar containers numerados
    for i in "${!CONTAINER_NAMES[@]}"; do
        local name="${CONTAINER_NAMES[$i]}"
        local image="${CONTAINER_IMAGES[$i]}"
        local selected=false
        
        for j in "${!SELECTED_CONTAINERS[@]}"; do
            if [ "${SELECTED_CONTAINERS[$j]}" = "$name" ]; then
                selected=true
                break
            fi
        done
        
        if [ "$selected" = true ]; then
            echo "$((i+1)). [✓] $name ($image)"
        else
            echo "$((i+1)). [ ] $name ($image)"
        fi
    done
    
    echo ""
    read -p "Escolha o número do container (0 para voltar): " choice
    
    if [ "$choice" = "0" ]; then
        return 0
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#CONTAINER_NAMES[@]} ]; then
        local index=$((choice-1))
        local name="${CONTAINER_NAMES[$index]}"
        local image="${CONTAINER_IMAGES[$index]}"
        
        # Verificar se já está selecionado
        local found=false
        local found_index=0
        
        for i in "${!SELECTED_CONTAINERS[@]}"; do
            if [ "${SELECTED_CONTAINERS[$i]}" = "$name" ]; then
                found=true
                found_index=$i
                break
            fi
        done
        
        if [ "$found" = true ]; then
            # Remover da seleção
            unset SELECTED_CONTAINERS[$found_index]
            unset CONTAINER_PRIORITIES[$found_index]
            unset CONTAINER_TIMEOUTS[$found_index]
            unset CONTAINER_HEALTH_CHECKS[$found_index]
            
            # Reindexar arrays
            SELECTED_CONTAINERS=("${SELECTED_CONTAINERS[@]}")
            CONTAINER_PRIORITIES=("${CONTAINER_PRIORITIES[@]}")
            CONTAINER_TIMEOUTS=("${CONTAINER_TIMEOUTS[@]}")
            CONTAINER_HEALTH_CHECKS=("${CONTAINER_HEALTH_CHECKS[@]}")
            
            log_info "TOGGLE" "Container $name removido da seleção"
        else
            # Adicionar à seleção com valores padrão
            SELECTED_CONTAINERS+=("$name")
            CONTAINER_PRIORITIES+=("2")  # Média prioridade
            CONTAINER_TIMEOUTS+=("30")   # 30 segundos
            CONTAINER_HEALTH_CHECKS+=("true")  # Verificar saúde
            
            log_info "TOGGLE" "Container $name adicionado à seleção"
        fi
    else
        echo "❌ Opção inválida"
        sleep 2
    fi
}

# Função para marcar todos os containers
select_all_containers() {
    show_main_menu
    echo "✅ Marcar Todos os Containers"
    echo "============================"
    echo ""
    
    # Limpar seleção atual
    SELECTED_CONTAINERS=()
    CONTAINER_PRIORITIES=()
    CONTAINER_TIMEOUTS=()
    CONTAINER_HEALTH_CHECKS=()
    
    # Adicionar todos os containers
    for i in "${!CONTAINER_NAMES[@]}"; do
        local name="${CONTAINER_NAMES[$i]}"
        SELECTED_CONTAINERS+=("$name")
        CONTAINER_PRIORITIES+=("2")  # Média prioridade por padrão
        CONTAINER_TIMEOUTS+=("30")   # 30 segundos por padrão
        CONTAINER_HEALTH_CHECKS+=("true")  # Verificar saúde por padrão
    done
    
    echo "✅ Todos os ${#CONTAINER_NAMES[@]} containers foram marcados!"
    echo "📋 Configurações padrão aplicadas:"
    echo "   - Prioridade: 🟡 Média"
    echo "   - Timeout: 30 segundos"
    echo "   - Health Check: ✅ Ativado"
    echo ""
    echo "💡 Use as opções 4, 5 e 6 para personalizar as configurações"
    echo ""
    read -p "Pressione ENTER para continuar..."
    
    log_info "SELECT_ALL" "Todos os ${#CONTAINER_NAMES[@]} containers foram selecionados"
}

# Função para desmarcar todos os containers
deselect_all_containers() {
    show_main_menu
    echo "❌ Desmarcar Todos os Containers"
    echo "==============================="
    echo ""
    
    if [ ${#SELECTED_CONTAINERS[@]} -eq 0 ]; then
        echo "ℹ️  Nenhum container está selecionado"
        sleep 2
        return 0
    fi
    
    echo "⚠️  Tem certeza que deseja desmarcar todos os containers?"
    echo "   Containers que serão desmarcados: ${#SELECTED_CONTAINERS[@]}"
    echo ""
    read -p "Digite 'SIM' para confirmar: " confirmation
    
    if [ "$confirmation" = "SIM" ]; then
        # Limpar todos os arrays
        SELECTED_CONTAINERS=()
        CONTAINER_PRIORITIES=()
        CONTAINER_TIMEOUTS=()
        CONTAINER_HEALTH_CHECKS=()
        
        echo "✅ Todos os containers foram desmarcados!"
        log_info "DESELECT_ALL" "Todos os containers foram desmarcados"
    else
        echo "❌ Operação cancelada"
    fi
    
    sleep 2
}

# Função para configurar prioridade
configure_priority() {
    show_main_menu
    echo "🔴 Configurar Prioridade"
    echo "======================="
    echo ""
    
    # Listar containers selecionados
    local count=0
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        local priority="${CONTAINER_PRIORITIES[$i]}"
        local priority_text=""
        
        case "$priority" in
            "1") priority_text="🔴 Alta" ;;
            "2") priority_text="🟡 Média" ;;
            "3") priority_text="🟢 Baixa" ;;
            *) priority_text="⚪ Não definida" ;;
        esac
        
        echo "$((count+1)). $name - $priority_text"
        ((count++))
    done
    
    if [ $count -eq 0 ]; then
        echo "Nenhum container selecionado"
        sleep 2
        return 0
    fi
    
    echo ""
    read -p "Escolha o número do container (0 para voltar): " choice
    
    if [ "$choice" = "0" ]; then
        return 0
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $count ]; then
        local index=$((choice-1))
        local name="${SELECTED_CONTAINERS[$index]}"
        
        echo ""
        echo "📦 Configurando: $name"
        echo "====================="
        echo ""
        echo "Prioridade:"
        echo "1. 🔴 Alta - Recuperar primeiro (crítico)"
        echo "2. 🟡 Média - Recuperar segundo (importante)"
        echo "3. 🟢 Baixa - Recuperar por último (opcional)"
        echo ""
        
        read -p "Escolha a prioridade (1-3): " priority_choice
        
        if [[ "$priority_choice" =~ ^[1-3]$ ]]; then
            CONTAINER_PRIORITIES[$index]="$priority_choice"
            log_info "PRIORITY" "Prioridade de $name definida como $priority_choice"
        else
            echo "❌ Prioridade inválida"
            sleep 2
        fi
    else
        echo "❌ Opção inválida"
        sleep 2
    fi
}

# Função para configurar timeout
configure_timeout() {
    show_main_menu
    echo "⏰ Configurar Timeout"
    echo "===================="
    echo ""
    
    # Listar containers selecionados
    local count=0
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        local timeout="${CONTAINER_TIMEOUTS[$i]}"
        
        echo "$((count+1)). $name - ${timeout}s"
        ((count++))
    done
    
    if [ $count -eq 0 ]; then
        echo "Nenhum container selecionado"
        sleep 2
        return 0
    fi
    
    echo ""
    read -p "Escolha o número do container (0 para voltar): " choice
    
    if [ "$choice" = "0" ]; then
        return 0
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $count ]; then
        local index=$((choice-1))
        local name="${SELECTED_CONTAINERS[$index]}"
        
        echo ""
        echo "📦 Configurando: $name"
        echo "====================="
        echo ""
        echo "Timeout (em segundos):"
        echo "  - 15s: Rápido (containers simples)"
        echo "  - 30s: Padrão (maioria dos containers)"
        echo "  - 60s: Lento (containers complexos)"
        echo "  - 120s: Muito lento (containers pesados)"
        echo ""
        
        read -p "Digite o timeout em segundos (15-120): " timeout_choice
        
        if [[ "$timeout_choice" =~ ^[0-9]+$ ]] && [ "$timeout_choice" -ge 15 ] && [ "$timeout_choice" -le 120 ]; then
            CONTAINER_TIMEOUTS[$index]="$timeout_choice"
            log_info "TIMEOUT" "Timeout de $name definido como ${timeout_choice}s"
        else
            echo "❌ Timeout inválido (use 15-120 segundos)"
            sleep 2
        fi
    else
        echo "❌ Opção inválida"
        sleep 2
    fi
}

# Função para configurar health check
configure_health_check() {
    show_main_menu
    echo "✅ Configurar Health Check"
    echo "========================="
    echo ""
    
    # Listar containers selecionados
    local count=0
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        local health_check="${CONTAINER_HEALTH_CHECKS[$i]}"
        local health_text=""
        
        case "$health_check" in
            "true") health_text="✅ Verificar" ;;
            "false") health_text="❌ Não verificar" ;;
            *) health_text="⚪ Não definido" ;;
        esac
        
        echo "$((count+1)). $name - $health_text"
        ((count++))
    done
    
    if [ $count -eq 0 ]; then
        echo "Nenhum container selecionado"
        sleep 2
        return 0
    fi
    
    echo ""
    read -p "Escolha o número do container (0 para voltar): " choice
    
    if [ "$choice" = "0" ]; then
        return 0
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $count ]; then
        local index=$((choice-1))
        local name="${SELECTED_CONTAINERS[$index]}"
        
        echo ""
        echo "📦 Configurando: $name"
        echo "====================="
        echo ""
        echo "Health Check:"
        echo "1. ✅ Verificar saúde (mais seguro, mais lento)"
        echo "2. ❌ Não verificar (mais rápido, menos seguro)"
        echo ""
        
        read -p "Escolha a opção (1-2): " health_choice
        
        if [ "$health_choice" = "1" ]; then
            CONTAINER_HEALTH_CHECKS[$index]="true"
            log_info "HEALTH" "Health check de $name habilitado"
        elif [ "$health_choice" = "2" ]; then
            CONTAINER_HEALTH_CHECKS[$index]="false"
            log_info "HEALTH" "Health check de $name desabilitado"
        else
            echo "❌ Opção inválida"
            sleep 2
        fi
    else
        echo "❌ Opção inválida"
        sleep 2
    fi
}

# Função para mostrar preview da configuração
show_configuration_preview() {
    clear
    echo "📋 Preview da Configuração de Recuperação"
    echo "========================================="
    echo ""
    
    if [ ${#SELECTED_CONTAINERS[@]} -eq 0 ]; then
        echo "Nenhum container configurado para recuperação"
        echo ""
        read -p "Pressione Enter para continuar..."
        return 0
    fi
    
    # Agrupar por prioridade
    echo "🔴 Alta Prioridade (recuperar primeiro):"
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        if [ "${CONTAINER_PRIORITIES[$i]}" = "1" ]; then
            local name="${SELECTED_CONTAINERS[$i]}"
            local timeout="${CONTAINER_TIMEOUTS[$i]}"
            local health_check="${CONTAINER_HEALTH_CHECKS[$i]}"
            local health_text=""
            
            case "$health_check" in
                "true") health_text="Verificar saúde" ;;
                "false") health_text="Não verificar" ;;
            esac
            
            echo "  - $name (${timeout}s, $health_text)"
        fi
    done
    echo ""
    
    echo "🟡 Média Prioridade:"
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        if [ "${CONTAINER_PRIORITIES[$i]}" = "2" ]; then
            local name="${SELECTED_CONTAINERS[$i]}"
            local timeout="${CONTAINER_TIMEOUTS[$i]}"
            local health_check="${CONTAINER_HEALTH_CHECKS[$i]}"
            local health_text=""
            
            case "$health_check" in
                "true") health_text="Verificar saúde" ;;
                "false") health_text="Não verificar" ;;
            esac
            
            echo "  - $name (${timeout}s, $health_text)"
        fi
    done
    echo ""
    
    echo "🟢 Baixa Prioridade:"
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        if [ "${CONTAINER_PRIORITIES[$i]}" = "3" ]; then
            local name="${SELECTED_CONTAINERS[$i]}"
            local timeout="${CONTAINER_TIMEOUTS[$i]}"
            local health_check="${CONTAINER_HEALTH_CHECKS[$i]}"
            local health_text=""
            
            case "$health_check" in
                "true") health_text="Verificar saúde" ;;
                "false") health_text="Não verificar" ;;
            esac
            
            echo "  - $name (${timeout}s, $health_text)"
        fi
    done
    echo ""
    
    echo "📊 Resumo:"
    echo "  - Containers configurados: ${#SELECTED_CONTAINERS[@]}"
    echo "  - Alta prioridade: $(count_priority 1)"
    echo "  - Média prioridade: $(count_priority 2)"
    echo "  - Baixa prioridade: $(count_priority 3)"
    echo "  - Health checks habilitados: $(count_health_check true)"
    echo ""
    
    read -p "Pressione Enter para continuar..."
}

# Função para contar containers por prioridade
count_priority() {
    local priority="$1"
    local count=0
    
    for i in "${!CONTAINER_PRIORITIES[@]}"; do
        if [ "${CONTAINER_PRIORITIES[$i]}" = "$priority" ]; then
            ((count++))
        fi
    done
    
    echo $count
}

# Função para contar health checks
count_health_check() {
    local health_check="$1"
    local count=0
    
    for i in "${!CONTAINER_HEALTH_CHECKS[@]}"; do
        if [ "${CONTAINER_HEALTH_CHECKS[$i]}" = "$health_check" ]; then
            ((count++))
        fi
    done
    
    echo $count
}

# Função para salvar configuração
save_configuration() {
    log_info "SAVE" "Salvando configuração..."
    
    # Fazer backup da configuração atual
    if [ -f "$RECOVERY_CONFIG" ]; then
        # Criar pasta de backups se não existir
        mkdir -p "$RECOVERY_CONFIG_DIR"
        RECOVERY_CONFIG_BACKUP="$RECOVERY_CONFIG_DIR/recovery-config.sh.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$RECOVERY_CONFIG" "$RECOVERY_CONFIG_BACKUP"
        log_info "SAVE" "Backup criado: $RECOVERY_CONFIG_BACKUP"
    fi
    
    # Gerar nova configuração
    cat > "$RECOVERY_CONFIG" << EOF
# =============================================================================
# CONFIGURAÇÃO DE RECUPERAÇÃO DINÂMICA - GERADA AUTOMATICAMENTE
# =============================================================================
# Data de geração: $(date)
# Use: ./blueai-docker-ops.sh recovery config para modificar

# Diretório de backups
BACKUP_DIR="$PROJECT_ROOT/backups"

# Configurações de recuperação
RECOVERY_PARALLEL=false
RECOVERY_RETRY_ATTEMPTS=3
RECOVERY_RETRY_DELAY=5

# Containers configurados para recuperação
# Formato: container:volume:priority:timeout:health_check
RECOVERY_TARGETS=(
EOF
    
    # Adicionar containers configurados
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        local volume="${CONTAINER_VOLUMES[$i]}"
        local priority="${CONTAINER_PRIORITIES[$i]}"
        local timeout="${CONTAINER_TIMEOUTS[$i]}"
        local health_check="${CONTAINER_HEALTH_CHECKS[$i]}"
        
        # Se não tem volume, usar nome do container
        if [ -z "$volume" ]; then
            volume="$name-data"
        fi
        
        echo "    \"$name:$volume:$priority:$timeout:$health_check\"" >> "$RECOVERY_CONFIG"
    done
    
    cat >> "$RECOVERY_CONFIG" << EOF
)

# Configurações de notificação por container
RECOVERY_NOTIFICATIONS=(
EOF
    
    # Adicionar notificações para todos os containers
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        echo "    \"$name:true\"" >> "$RECOVERY_CONFIG"
    done
    
    cat >> "$RECOVERY_CONFIG" << EOF
)

# Configurações de log por container
RECOVERY_LOG_LEVELS=(
EOF
    
    # Adicionar níveis de log para todos os containers
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        echo "    \"$name:1\"" >> "$RECOVERY_CONFIG"
    done
    
    cat >> "$RECOVERY_CONFIG" << EOF
)

# Configurações de rede por container
RECOVERY_NETWORKS=(
EOF
    
    # Adicionar redes para todos os containers
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        local network="${CONTAINER_NETWORKS[$i]}"
        if [ -z "$network" ]; then
            network="bridge"
        fi
        echo "    \"$name:$network\"" >> "$RECOVERY_CONFIG"
    done
    
    cat >> "$RECOVERY_CONFIG" << EOF
)

# Configurações avançadas
RECOVERY_PRE_CHECK=true
RECOVERY_INTEGRITY_CHECK=true
RECOVERY_SECURITY_CHECK=true
RECOVERY_CLEANUP_OLD_CONTAINERS=true
EOF
    
    log_info "SAVE" "Configuração salva com sucesso"
    echo "✅ Configuração salva em: $RECOVERY_CONFIG"
}

# Função para validar configuração
validate_configuration() {
    log_info "VALIDATE" "Validando configuração..."
    
    if [ ! -f "$RECOVERY_CONFIG" ]; then
        log_error "VALIDATE" "Arquivo de configuração não encontrado"
        return 1
    fi
    
    # Verificar sintaxe do arquivo
    if ! bash -n "$RECOVERY_CONFIG" 2>/dev/null; then
        log_error "VALIDATE" "Erro de sintaxe no arquivo de configuração"
        return 1
    fi
    
    # Carregar configuração para validação
    source "$RECOVERY_CONFIG"
    
    local errors=0
    
    # Verificar se RECOVERY_TARGETS está definido
    if [ ${#RECOVERY_TARGETS[@]} -eq 0 ]; then
        log_warning "VALIDATE" "Nenhum container configurado para recuperação"
    fi
    
    # Validar formato de cada target
    for target in "${RECOVERY_TARGETS[@]}"; do
        local parts=($(echo "$target" | tr ':' '\n'))
        
        if [ ${#parts[@]} -ne 5 ]; then
            log_error "VALIDATE" "Formato inválido: $target"
            ((errors++))
            continue
        fi
        
        local container="${parts[0]}"
        local volume="${parts[1]}"
        local priority="${parts[2]}"
        local timeout="${parts[3]}"
        local health_check="${parts[4]}"
        
        # Verificar se container existe
        if ! docker ps -a --format "{{.Names}}" | grep -q "^$container$"; then
            log_warning "VALIDATE" "Container não encontrado: $container"
        fi
        
        # Validar prioridade
        if ! [[ "$priority" =~ ^[1-3]$ ]]; then
            log_error "VALIDATE" "Prioridade inválida para $container: $priority"
            ((errors++))
        fi
        
        # Validar timeout
        if ! [[ "$timeout" =~ ^[0-9]+$ ]] || [ "$timeout" -lt 15 ] || [ "$timeout" -gt 300 ]; then
            log_error "VALIDATE" "Timeout inválido para $container: $timeout"
            ((errors++))
        fi
        
        # Validar health_check
        if [ "$health_check" != "true" ] && [ "$health_check" != "false" ]; then
            log_error "VALIDATE" "Health check inválido para $container: $health_check"
            ((errors++))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        log_info "VALIDATE" "Configuração válida"
        echo "✅ Configuração válida"
        return 0
    else
        log_error "VALIDATE" "Encontrados $errors erro(s) na configuração"
        echo "❌ Encontrados $errors erro(s) na configuração"
        return 1
    fi
}

# Função para resetar configuração
reset_configuration() {
    log_info "RESET" "Resetando configuração..."
    
    # Fazer backup da configuração atual
    if [ -f "$RECOVERY_CONFIG" ]; then
        # Criar pasta de backups se não existir
        mkdir -p "$RECOVERY_CONFIG_DIR"
        RECOVERY_CONFIG_BACKUP="$RECOVERY_CONFIG_DIR/recovery-config.sh.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$RECOVERY_CONFIG" "$RECOVERY_CONFIG_BACKUP"
        log_info "RESET" "Backup criado: $RECOVERY_CONFIG_BACKUP"
    fi
    
    # Criar configuração padrão
    cat > "$RECOVERY_CONFIG" << 'EOF'
# =============================================================================
# CONFIGURAÇÃO DE RECUPERAÇÃO DINÂMICA - PADRÃO
# =============================================================================
# Data de reset: $(date)
# Use: ./blueai-docker-ops.sh recovery config para configurar

# Diretório de backups
BACKUP_DIR="$PROJECT_ROOT/backups"

# Configurações de recuperação
RECOVERY_PARALLEL=false
RECOVERY_RETRY_ATTEMPTS=3
RECOVERY_RETRY_DELAY=5

# Containers configurados para recuperação (vazio por padrão)
RECOVERY_TARGETS=()

# Configurações de notificação por container
RECOVERY_NOTIFICATIONS=()

# Configurações de log por container
RECOVERY_LOG_LEVELS=()

# Configurações de rede por container
RECOVERY_NETWORKS=()

# Configurações avançadas
RECOVERY_PRE_CHECK=true
RECOVERY_INTEGRITY_CHECK=true
RECOVERY_SECURITY_CHECK=true
RECOVERY_CLEANUP_OLD_CONTAINERS=true
EOF
    
    log_info "RESET" "Configuração resetada para padrão"
    echo "✅ Configuração resetada para padrão"
}

# Função principal
main() {
    local command=""
    
    # Processar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --preview)
                command="preview"
                shift
                ;;
            --validate)
                command="validate"
                shift
                ;;
            --reset)
                command="reset"
                shift
                ;;
            *)
                echo "❌ Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Se nenhum comando foi especificado, modo interativo
    if [ -z "$command" ]; then
        command="interactive"
    fi
    
    # Executar comando
    case $command in
        interactive)
            # Detectar containers
            if ! detect_containers; then
                exit 1
            fi
            
            # Carregar configuração atual
            load_current_config
            
            # Loop principal
            while true; do
                show_main_menu
                read -p "Escolha uma opção: " choice
                
                case $choice in
                    1)
                        toggle_container
                        ;;
                    2)
                        select_all_containers
                        ;;
                    3)
                        deselect_all_containers
                        ;;
                    4)
                        configure_priority
                        ;;
                    5)
                        configure_timeout
                        ;;
                    6)
                        configure_health_check
                        ;;
                    7)
                        show_configuration_preview
                        ;;
                    8)
                        save_configuration
                        echo ""
                        echo "🎉 Configuração salva com sucesso!"
                        echo "💡 Use './blueai-docker-ops.sh recovery list' para verificar"
                        exit 0
                        ;;
                    9)
                        echo "❌ Configuração não salva"
                        exit 0
                        ;;
                    *)
                        echo "❌ Opção inválida"
                        sleep 2
                        ;;
                esac
            done
            ;;
        preview)
            load_current_config
            show_configuration_preview
            ;;
        validate)
            validate_configuration
            ;;
        reset)
            reset_configuration
            ;;
        *)
            echo "❌ Comando desconhecido: $command"
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
