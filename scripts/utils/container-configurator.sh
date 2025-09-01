#!/bin/bash

# =============================================================================
# CONFIGURADOR INTERATIVO DE CONTAINERS PARA BACKUP
# =============================================================================

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKUP_CONFIG="$PROJECT_ROOT/config/backup-config.sh"
BACKUP_CONFIG_BACKUP=""
BACKUP_CONFIG_DIR="$PROJECT_ROOT/config/backups"

# Carregar funções de logging
source "$SCRIPT_DIR/../logging/logging-functions.sh"

# Arrays para armazenar dados
declare -a CONTAINERS=()
declare -a CONTAINER_NAMES=()
declare -a CONTAINER_STATUS=()
declare -a CONTAINER_VOLUMES=()
declare -a CONTAINER_SIZES=()
declare -a SELECTED_CONTAINERS=()
declare -a CONTAINER_PRIORITIES=()
declare -a CONTAINER_BEHAVIORS=()

# Função para mostrar ajuda
show_help() {
    echo "🐳 Configurador de Containers para Backup"
    echo "========================================="
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
    
    # Obter lista de containers
    local docker_containers=$(docker ps -a --format "{{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null)
    
    if [ -z "$docker_containers" ]; then
        log_warning "DETECT" "Nenhum container encontrado"
        return 0
    fi
    
    # Processar containers
    while IFS=$'\t' read -r name status image; do
        if [ -n "$name" ]; then
            CONTAINER_NAMES+=("$name")
            
            # Determinar status
            if [[ "$status" == *"Up"* ]]; then
                CONTAINER_STATUS+=("running")
            else
                CONTAINER_STATUS+=("stopped")
            fi
            
            # Detectar volumes
            local volumes=$(docker inspect "$name" --format '{{range .Mounts}}{{.Source}} {{end}}' 2>/dev/null | tr ' ' '\n' | grep -v '^$' | head -1)
            if [ -n "$volumes" ]; then
                CONTAINER_VOLUMES+=("$volumes")
            else
                CONTAINER_VOLUMES+=("")
            fi
            
            # Estimar tamanho do container individual
            local size=$(docker ps -a --filter "name=$name" --format "{{.Size}}" 2>/dev/null | head -1)
            if [ -n "$size" ] && [ "$size" != "0B" ]; then
                CONTAINER_SIZES+=("$size")
            else
                # Tentar obter tamanho do volume se disponível
                if [ -n "$volumes" ] && [ -d "$volumes" ]; then
                    local volume_size=$(du -sh "$volumes" 2>/dev/null | awk '{print $1}')
                    if [ -n "$volume_size" ]; then
                        CONTAINER_SIZES+=("$volume_size")
                    else
                        CONTAINER_SIZES+=("N/A")
                    fi
                else
                    CONTAINER_SIZES+=("N/A")
                fi
            fi
        fi
    done <<< "$docker_containers"
    
    log_info "DETECT" "Encontrados ${#CONTAINER_NAMES[@]} containers"
}

# Função para carregar configuração atual
load_current_config() {
    log_info "CONFIG" "Carregando configuração atual..."
    
    if [ -f "$BACKUP_CONFIG" ]; then
        source "$BACKUP_CONFIG"
        
        # Processar BACKUP_TARGETS existente
        for target in "${BACKUP_TARGETS[@]}"; do
            local parts=($(echo "$target" | tr ':' '\n'))
            if [ ${#parts[@]} -eq 4 ]; then
                local container="${parts[0]}"
                local volume="${parts[1]}"
                local priority="${parts[2]}"
                local behavior="${parts[3]}"
                
                SELECTED_CONTAINERS+=("$container")
                CONTAINER_PRIORITIES+=("$priority")
                CONTAINER_BEHAVIORS+=("$behavior")
            fi
        done
    fi
}

# Função para mostrar menu principal
show_main_menu() {
    clear
    echo "🐳 Configurador de Containers para Backup"
    echo "========================================="
    echo ""
    
    # Mostrar containers detectados
    echo "📦 Containers Detectados (${#CONTAINER_NAMES[@]}):"
    for i in "${!CONTAINER_NAMES[@]}"; do
        local name="${CONTAINER_NAMES[$i]}"
        local status="${CONTAINER_STATUS[$i]}"
        local volume="${CONTAINER_VOLUMES[$i]}"
        local size="${CONTAINER_SIZES[$i]}"
        
        # Verificar se está selecionado
        local selected=false
        local priority=""
        local behavior=""
        
        for j in "${!SELECTED_CONTAINERS[@]}"; do
            if [ "${SELECTED_CONTAINERS[$j]}" = "$name" ]; then
                selected=true
                priority="${CONTAINER_PRIORITIES[$j]}"
                behavior="${CONTAINER_BEHAVIORS[$j]}"
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
            
            local behavior_icon=""
            case "$behavior" in
                "true") behavior_icon="⏸️ Para antes" ;;
                "false") behavior_icon="▶️ Mantém rodando" ;;
                *) behavior_icon="⚪ Não definido" ;;
            esac
            
            echo "[✓] $name ($status) - $priority_icon - $behavior_icon"
            if [ -n "$volume" ]; then
                echo "    Volume: $volume ($size)"
            fi
        else
            echo "[ ] $name ($status)"
            if [ -n "$volume" ]; then
                echo "    Volume: $volume ($size)"
            fi
        fi
        echo ""
    done
    
    # Mostrar opções
    echo "🔧 Ações:"
    echo "1. Marcar/Desmarcar container"
    echo "2. Configurar prioridade"
    echo "3. Configurar comportamento"
    echo "4. Visualizar configuração atual"
    echo "5. Salvar e sair"
    echo "6. Sair sem salvar"
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
        local status="${CONTAINER_STATUS[$i]}"
        local selected=false
        
        for j in "${!SELECTED_CONTAINERS[@]}"; do
            if [ "${SELECTED_CONTAINERS[$j]}" = "$name" ]; then
                selected=true
                break
            fi
        done
        
        if [ "$selected" = true ]; then
            echo "$((i+1)). [✓] $name ($status)"
        else
            echo "$((i+1)). [ ] $name ($status)"
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
            unset CONTAINER_BEHAVIORS[$found_index]
            
            # Reindexar arrays
            SELECTED_CONTAINERS=("${SELECTED_CONTAINERS[@]}")
            CONTAINER_PRIORITIES=("${CONTAINER_PRIORITIES[@]}")
            CONTAINER_BEHAVIORS=("${CONTAINER_BEHAVIORS[@]}")
            
            log_info "TOGGLE" "Container $name removido da seleção"
        else
            # Adicionar à seleção com valores padrão
            SELECTED_CONTAINERS+=("$name")
            CONTAINER_PRIORITIES+=("2")  # Média prioridade
            CONTAINER_BEHAVIORS+=("false")  # Não para
            
            log_info "TOGGLE" "Container $name adicionado à seleção"
        fi
    else
        echo "❌ Opção inválida"
        sleep 2
    fi
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
        echo "1. 🔴 Alta - Backup primeiro (crítico)"
        echo "2. 🟡 Média - Backup segundo (importante)"
        echo "3. 🟢 Baixa - Backup por último (opcional)"
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

# Função para configurar comportamento
configure_behavior() {
    show_main_menu
    echo "⏸️ Configurar Comportamento"
    echo "==========================="
    echo ""
    
    # Listar containers selecionados
    local count=0
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        local behavior="${CONTAINER_BEHAVIORS[$i]}"
        local behavior_text=""
        
        case "$behavior" in
            "true") behavior_text="⏸️ Para antes" ;;
            "false") behavior_text="▶️ Mantém rodando" ;;
            *) behavior_text="⚪ Não definido" ;;
        esac
        
        echo "$((count+1)). $name - $behavior_text"
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
        echo "Comportamento:"
        echo "1. ⏸️ Parar antes do backup (mais seguro)"
        echo "2. ▶️ Manter rodando (mais rápido)"
        echo ""
        
        read -p "Escolha o comportamento (1-2): " behavior_choice
        
        if [ "$behavior_choice" = "1" ]; then
            CONTAINER_BEHAVIORS[$index]="true"
            log_info "BEHAVIOR" "Comportamento de $name definido como 'parar antes'"
        elif [ "$behavior_choice" = "2" ]; then
            CONTAINER_BEHAVIORS[$index]="false"
            log_info "BEHAVIOR" "Comportamento de $name definido como 'manter rodando'"
        else
            echo "❌ Comportamento inválido"
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
    echo "📋 Preview da Configuração"
    echo "=========================="
    echo ""
    
    if [ ${#SELECTED_CONTAINERS[@]} -eq 0 ]; then
        echo "Nenhum container configurado para backup"
        echo ""
        read -p "Pressione Enter para continuar..."
        return 0
    fi
    
    # Agrupar por prioridade
    echo "🔴 Alta Prioridade (backup primeiro):"
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        if [ "${CONTAINER_PRIORITIES[$i]}" = "1" ]; then
            local name="${SELECTED_CONTAINERS[$i]}"
            local behavior="${CONTAINER_BEHAVIORS[$i]}"
            local behavior_text=""
            
            case "$behavior" in
                "true") behavior_text="Para antes" ;;
                "false") behavior_text="Não para" ;;
            esac
            
            echo "  - $name - $behavior_text"
        fi
    done
    echo ""
    
    echo "🟡 Média Prioridade:"
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        if [ "${CONTAINER_PRIORITIES[$i]}" = "2" ]; then
            local name="${SELECTED_CONTAINERS[$i]}"
            local behavior="${CONTAINER_BEHAVIORS[$i]}"
            local behavior_text=""
            
            case "$behavior" in
                "true") behavior_text="Para antes" ;;
                "false") behavior_text="Não para" ;;
            esac
            
            echo "  - $name - $behavior_text"
        fi
    done
    echo ""
    
    echo "🟢 Baixa Prioridade:"
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        if [ "${CONTAINER_PRIORITIES[$i]}" = "3" ]; then
            local name="${SELECTED_CONTAINERS[$i]}"
            local behavior="${CONTAINER_BEHAVIORS[$i]}"
            local behavior_text=""
            
            case "$behavior" in
                "true") behavior_text="Para antes" ;;
                "false") behavior_text="Não para" ;;
            esac
            
            echo "  - $name - $behavior_text"
        fi
    done
    echo ""
    
    echo "📊 Resumo:"
    echo "  - Containers configurados: ${#SELECTED_CONTAINERS[@]}"
    echo "  - Alta prioridade: $(count_priority 1)"
    echo "  - Média prioridade: $(count_priority 2)"
    echo "  - Baixa prioridade: $(count_priority 3)"
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

# Função para salvar configuração
save_configuration() {
    log_info "SAVE" "Salvando configuração..."
    
    # Fazer backup da configuração atual
    if [ -f "$BACKUP_CONFIG" ]; then
        # Criar pasta de backups se não existir
        mkdir -p "$BACKUP_CONFIG_DIR"
        BACKUP_CONFIG_BACKUP="$BACKUP_CONFIG_DIR/backup-config.sh.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$BACKUP_CONFIG" "$BACKUP_CONFIG_BACKUP"
        log_info "SAVE" "Backup criado: $BACKUP_CONFIG_BACKUP"
    fi
    
    # Gerar nova configuração
    cat > "$BACKUP_CONFIG" << EOF
# =============================================================================
# CONFIGURAÇÃO DE BACKUP DINÂMICO - GERADA AUTOMATICAMENTE
# =============================================================================
# Data de geração: $(date)
# Use: ./blueai-docker-ops.sh config containers para modificar

# Diretório de backup
BACKUP_DIR="$PROJECT_ROOT/backups"

# Configurações de retenção
BACKUP_RETENTION_DAYS=7
BACKUP_MAX_SIZE_GB=10
BACKUP_COMPRESSION=true
BACKUP_PARALLEL=false

# Containers configurados para backup
# Formato: container:volume:priority:stop_before_backup
BACKUP_TARGETS=(
EOF
    
    # Adicionar containers configurados
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        local volume="${CONTAINER_VOLUMES[$i]}"
        local priority="${CONTAINER_PRIORITIES[$i]}"
        local behavior="${CONTAINER_BEHAVIORS[$i]}"
        
        # Se não tem volume, usar nome do container
        if [ -z "$volume" ]; then
            volume="$name-data"
        fi
        
        echo "    \"$name:$volume:$priority:$behavior\"" >> "$BACKUP_CONFIG"
    done
    
    cat >> "$BACKUP_CONFIG" << EOF
)

# Configurações de notificação por container
BACKUP_NOTIFICATIONS=(
EOF
    
    # Adicionar notificações para todos os containers
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        echo "    \"$name:true\"" >> "$BACKUP_CONFIG"
    done
    
    cat >> "$BACKUP_CONFIG" << EOF
)

# Configurações de log por container
BACKUP_LOG_LEVELS=(
EOF
    
    # Adicionar níveis de log para todos os containers
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        echo "    \"$name:1\"" >> "$BACKUP_CONFIG"
    done
    
    cat >> "$BACKUP_CONFIG" << EOF
)

# Configurações de timeout por container
BACKUP_TIMEOUTS=(
EOF
    
    # Adicionar timeouts para todos os containers
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        echo "    \"$name:300\"" >> "$BACKUP_CONFIG"
    done
    
    cat >> "$BACKUP_CONFIG" << EOF
)

# Configurações de compressão por container
BACKUP_COMPRESSION_LEVELS=(
EOF
    
    # Adicionar níveis de compressão para todos os containers
    for i in "${!SELECTED_CONTAINERS[@]}"; do
        local name="${SELECTED_CONTAINERS[$i]}"
        echo "    \"$name:6\"" >> "$BACKUP_CONFIG"
    done
    
    cat >> "$BACKUP_CONFIG" << EOF
)

# Configurações avançadas
BACKUP_PRE_CHECK=true
BACKUP_INTEGRITY_CHECK=true
BACKUP_SECURITY_CHECK=true
EOF
    
    log_info "SAVE" "Configuração salva com sucesso"
    echo "✅ Configuração salva em: $BACKUP_CONFIG"
}

# Função para validar configuração
validate_configuration() {
    log_info "VALIDATE" "Validando configuração..."
    
    if [ ! -f "$BACKUP_CONFIG" ]; then
        log_error "VALIDATE" "Arquivo de configuração não encontrado"
        return 1
    fi
    
    # Verificar sintaxe do arquivo
    if ! bash -n "$BACKUP_CONFIG" 2>/dev/null; then
        log_error "VALIDATE" "Erro de sintaxe no arquivo de configuração"
        return 1
    fi
    
    # Carregar configuração para validação
    source "$BACKUP_CONFIG"
    
    local errors=0
    
    # Verificar se BACKUP_TARGETS está definido
    if [ ${#BACKUP_TARGETS[@]} -eq 0 ]; then
        log_warning "VALIDATE" "Nenhum container configurado para backup"
    fi
    
    # Validar formato de cada target
    for target in "${BACKUP_TARGETS[@]}"; do
        local parts=($(echo "$target" | tr ':' '\n'))
        
        if [ ${#parts[@]} -ne 4 ]; then
            log_error "VALIDATE" "Formato inválido: $target"
            ((errors++))
            continue
        fi
        
        local container="${parts[0]}"
        local volume="${parts[1]}"
        local priority="${parts[2]}"
        local stop_before="${parts[3]}"
        
        # Verificar se container existe
        if ! docker ps -a --format "{{.Names}}" | grep -q "^$container$"; then
            log_warning "VALIDATE" "Container não encontrado: $container"
        fi
        
        # Validar prioridade
        if ! [[ "$priority" =~ ^[1-3]$ ]]; then
            log_error "VALIDATE" "Prioridade inválida para $container: $priority"
            ((errors++))
        fi
        
        # Validar stop_before
        if [ "$stop_before" != "true" ] && [ "$stop_before" != "false" ]; then
            log_error "VALIDATE" "stop_before inválido para $container: $stop_before"
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
    if [ -f "$BACKUP_CONFIG" ]; then
        # Criar pasta de backups se não existir
        mkdir -p "$BACKUP_CONFIG_DIR"
        BACKUP_CONFIG_BACKUP="$BACKUP_CONFIG_DIR/backup-config.sh.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$BACKUP_CONFIG" "$BACKUP_CONFIG_BACKUP"
        log_info "RESET" "Backup criado: $BACKUP_CONFIG_BACKUP"
    fi
    
    # Criar configuração padrão
    cat > "$BACKUP_CONFIG" << 'EOF'
# =============================================================================
# CONFIGURAÇÃO DE BACKUP DINÂMICO - PADRÃO
# =============================================================================
# Data de reset: $(date)
# Use: ./blueai-docker-ops.sh config containers para configurar

# Diretório de backup
BACKUP_DIR="$PROJECT_ROOT/backups"

# Configurações de retenção
BACKUP_RETENTION_DAYS=7
BACKUP_MAX_SIZE_GB=10
BACKUP_COMPRESSION=true
BACKUP_PARALLEL=false

# Containers configurados para backup (vazio por padrão)
BACKUP_TARGETS=()

# Configurações de notificação por container
BACKUP_NOTIFICATIONS=()

# Configurações de log por container
BACKUP_LOG_LEVELS=()

# Configurações de timeout por container
BACKUP_TIMEOUTS=()

# Configurações de compressão por container
BACKUP_COMPRESSION_LEVELS=()

# Configurações avançadas
BACKUP_PRE_CHECK=true
BACKUP_INTEGRITY_CHECK=true
BACKUP_SECURITY_CHECK=true
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
                        configure_priority
                        ;;
                    3)
                        configure_behavior
                        ;;
                    4)
                        show_configuration_preview
                        ;;
                    5)
                        save_configuration
                        echo ""
                        echo "🎉 Configuração salva com sucesso!"
                        echo "💡 Use './blueai-docker-ops.sh dynamic list' para verificar"
                        exit 0
                        ;;
                    6)
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
