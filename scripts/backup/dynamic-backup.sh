#!/bin/bash

# =============================================================================
# SCRIPT DE BACKUP DINÂMICO - BLUEAI DOCKER OPS
# =============================================================================

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Carregar configurações
source "$PROJECT_ROOT/config/backup-config.sh"
source "$PROJECT_ROOT/config/notification-config.sh"
source "$PROJECT_ROOT/config/version-config.sh"
source "$SCRIPT_DIR/../logging/logging-functions.sh"

# Função para mostrar ajuda
show_help() {
    echo "💾 Script de Backup Dinâmico"
    echo "============================"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  backup    - Executa backup de todos os containers configurados"
    echo "  list      - Lista containers configurados para backup"
    echo "  validate  - Valida configuração de backup"
    echo "  test      - Testa backup sem executar"
    echo "  help      - Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 backup"
    echo "  $0 list"
    echo "  $0 validate"
}

# Função para validar configuração
validate_backup_config() {
    log_info "CONFIG" "Validando configuração de backup"
    
    local errors=0
    
    # Verificar se BACKUP_TARGETS está definido
    if [ ${#BACKUP_TARGETS[@]} -eq 0 ]; then
        log_error "CONFIG" "BACKUP_TARGETS não está configurado"
        ((errors++))
    fi
    
    # Verificar formato de cada target
    for target in "${BACKUP_TARGETS[@]}"; do
        local parts=($(echo "$target" | tr ':' '\n'))
        
        if [ ${#parts[@]} -ne 4 ]; then
            log_error "CONFIG" "Formato inválido: $target"
            ((errors++))
            continue
        fi
        
        local container="${parts[0]}"
        local volume="${parts[1]}"
        local priority="${parts[2]}"
        local stop_before="${parts[3]}"
        
        # Validar prioridade
        if ! [[ "$priority" =~ ^[1-3]$ ]]; then
            log_error "CONFIG" "Prioridade inválida para $container: $priority (deve ser 1-3)"
            ((errors++))
        fi
        
        # Validar stop_before
        if [ "$stop_before" != "true" ] && [ "$stop_before" != "false" ]; then
            log_error "CONFIG" "stop_before inválido para $container: $stop_before (deve ser true/false)"
            ((errors++))
        fi
    done
    
    # Verificar diretório de backup
    if [ ! -d "$BACKUP_DIR" ]; then
        log_warning "CONFIG" "Diretório de backup não existe: $BACKUP_DIR"
        log_info "CONFIG" "Criando diretório de backup"
        mkdir -p "$BACKUP_DIR"
    fi
    
    if [ $errors -eq 0 ]; then
        log_info "CONFIG" "Configuração válida"
        return 0
    else
        log_error "CONFIG" "Encontrados $errors erro(s) na configuração"
        return 1
    fi
}

# Função para listar containers configurados
list_backup_targets() {
    log_info "LIST" "Containers configurados para backup"
    
    if [ ${#BACKUP_TARGETS[@]} -eq 0 ]; then
        log_warning "LIST" "Nenhum container configurado para backup"
        return 1
    fi
    
    echo ""
    echo "📋 Containers Configurados para Backup"
    echo "======================================"
    echo ""
    
    # Ordenar por prioridade
    local sorted_targets=($(for target in "${BACKUP_TARGETS[@]}"; do
        local priority=$(echo "$target" | cut -d: -f3)
        echo "$priority:$target"
    done | sort -n | cut -d: -f2-))
    
    for target in "${sorted_targets[@]}"; do
        local container=$(echo "$target" | cut -d: -f1)
        local volume=$(echo "$target" | cut -d: -f2)
        local priority=$(echo "$target" | cut -d: -f3)
        local stop_before=$(echo "$target" | cut -d: -f4)
        
        local priority_text=""
        case $priority in
            1) priority_text="🔴 Alta" ;;
            2) priority_text="🟡 Média" ;;
            3) priority_text="🟢 Baixa" ;;
        esac
        
        local stop_text=""
        if [ "$stop_before" = "true" ]; then
            stop_text="⏸️  Para antes"
        else
            stop_text="▶️  Não para"
        fi
        
        echo "  📦 $container"
        echo "     Volume: $volume"
        echo "     Prioridade: $priority_text"
        echo "     Comportamento: $stop_text"
        echo ""
    done
}

# Função para verificar se container existe
container_exists() {
    local container="$1"
    docker ps -a --format "{{.Names}}" | grep -q "^$container$"
}

# Função para verificar se container está rodando
container_running() {
    local container="$1"
    docker ps --format "{{.Names}}" | grep -q "^$container$"
}

# Função para verificar se volume existe
volume_exists() {
    local volume_path="$1"
    
    # Extrair nome do volume do caminho completo
    local volume_name=$(echo "$volume_path" | sed 's|/var/lib/docker/volumes/||' | sed 's|/_data||')
    
    # Verificar se o volume existe
    docker volume ls --format "{{.Name}}" | grep -q "^$volume_name$"
}

# Função para fazer backup de um container
backup_container() {
    local container="$1"
    local volume="$2"
    local stop_before="$3"
    local priority="$4"
    
    local timer=$(start_performance_timer "Backup $container")
    
    log_info "BACKUP" "Iniciando backup de $container (volume: $volume, prioridade: $priority)"
    
    # Verificar se container existe
    if ! container_exists "$container"; then
        log_warning "BACKUP" "Container $container não encontrado, pulando..."
        end_performance_timer "$timer"
        return 0
    fi
    
    # Verificar se volume existe
    if ! volume_exists "$volume"; then
        log_warning "BACKUP" "Volume $volume não encontrado, pulando..."
        end_performance_timer "$timer"
        return 0
    fi
    
    # Verificar se container está rodando
    local was_running=false
    if container_running "$container"; then
        was_running=true
        log_info "BACKUP" "Container $container está rodando"
    else
        log_info "BACKUP" "Container $container não está rodando"
    fi
    
    # Parar container se necessário
    if [ "$stop_before" = "true" ] && [ "$was_running" = "true" ]; then
        log_info "BACKUP" "Parando container $container antes do backup"
        docker stop "$container"
        sleep 2
    fi
    
    # Criar nome do arquivo de backup
    local volume_name=$(echo "$volume" | sed 's|/var/lib/docker/volumes/||' | sed 's|/_data||')
    local backup_file="$BACKUP_DIR/${volume_name}_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # Executar backup
    log_info "BACKUP" "Executando backup: $backup_file"
    
    local backup_output
    backup_output=$(docker run --rm \
        -v "$volume":/source \
        -v "$BACKUP_DIR":/backup \
        alpine tar czf "/backup/$(basename "$backup_file")" -C /source . 2>&1)
    local backup_exit_code=$?
    
    if [ $backup_exit_code -eq 0 ]; then
        
        # Verificar se o arquivo foi realmente criado e tem tamanho > 0
        if [ -f "$backup_file" ] && [ -s "$backup_file" ]; then
            local file_size=$(ls -lh "$backup_file" | awk '{print $5}')
            log_info "BACKUP" "Backup de $container concluído: $(basename "$backup_file") (${file_size})"
        else
            log_error "BACKUP" "Arquivo de backup não foi criado ou está vazio: $backup_file"
            end_performance_timer "$timer"
            return 1
        fi
        
        # Verificar integridade se habilitado
        if [ "$BACKUP_VERIFY_INTEGRITY" = true ]; then
            log_info "BACKUP" "Verificando integridade do backup"
            if tar -tzf "$backup_file" >/dev/null 2>&1; then
                log_info "BACKUP" "Integridade do backup verificada"
            else
                log_error "BACKUP" "Backup corrompido: $backup_file"
                rm -f "$backup_file"
                end_performance_timer "$timer"
                return 1
            fi
        fi
        
        # Reiniciar container se foi parado
        if [ "$stop_before" = "true" ] && [ "$was_running" = "true" ]; then
            log_info "BACKUP" "Reiniciando container $container"
            docker start "$container"
        fi
        
        # Enviar notificação se habilitado
        local should_notify=false
        for notification in "${BACKUP_NOTIFICATIONS[@]}"; do
            local notif_container=$(echo "$notification" | cut -d: -f1)
            local notif_enabled=$(echo "$notification" | cut -d: -f2)
            if [ "$notif_container" = "$container" ] && [ "$notif_enabled" = "true" ]; then
                should_notify=true
                break
            fi
        done
        
        if [ "$should_notify" = true ]; then
            local notification_message="Backup de $container concluído"
            local notification_details="Arquivo: $(basename "$backup_file")"
            
            if [ "$NOTIFICATIONS_ENABLED" = true ]; then
                # Notificação macOS
                if [ "$MACOS_NOTIFICATIONS_ENABLED" = true ]; then
                    osascript -e "display notification \"$notification_message\" with title \"$NOTIFICATION_TITLE\" subtitle \"$notification_details\" sound name \"$NOTIFICATION_SOUND\"" 2>/dev/null || true
                fi
                
                # Notificação por email
                if [ "$EMAIL_ENABLED" = true ] && [ -n "$EMAIL_TO" ]; then
                    local email_subject="SUCESSO: $notification_message"
                    local email_body="✅ $notification_message\n\n$notification_details\n\nData: $DATE"
                    
                    if command -v mail >/dev/null 2>&1; then
                        echo "$email_body" | mail -s "$EMAIL_SUBJECT_PREFIX $email_subject" "$EMAIL_TO" 2>/dev/null || true
                    fi
                fi
            fi
        fi
        
        end_performance_timer "$timer"
        return 0
    else
        # Verificar se é erro de espaço em disco
        if echo "$backup_output" | grep -q "No space left on device"; then
            log_error "BACKUP" "Erro de espaço em disco durante backup de $container"
            log_info "BACKUP" "Tentando limpar recursos Docker para liberar espaço"
            cleanup_docker_resources
            log_error "BACKUP" "Execute o backup novamente após a limpeza"
        else
            log_error "BACKUP" "Falha no backup de $container: $backup_output"
        fi
        
        # Reiniciar container se foi parado
        if [ "$stop_before" = "true" ] && [ "$was_running" = "true" ]; then
            log_info "BACKUP" "Reiniciando container $container após falha"
            docker start "$container"
        fi
        
        end_performance_timer "$timer"
        return 1
    fi
}

# Função para limpar recursos Docker
cleanup_docker_resources() {
    log_info "BACKUP" "Limpando recursos Docker não utilizados"
    
    # Limpar containers parados
    local stopped_containers=$(docker container prune -f 2>/dev/null | grep -o '[0-9]*' | tail -1)
    if [ -n "$stopped_containers" ] && [ "$stopped_containers" -gt 0 ]; then
        log_info "BACKUP" "Removidos $stopped_containers containers parados"
    fi
    
    # Limpar imagens não utilizadas
    local unused_images=$(docker image prune -f 2>/dev/null | grep -o '[0-9]*' | tail -1)
    if [ -n "$unused_images" ] && [ "$unused_images" -gt 0 ]; then
        log_info "BACKUP" "Removidas $unused_images imagens não utilizadas"
    fi
    
    # Limpar volumes não utilizados
    local unused_volumes=$(docker volume prune -f 2>/dev/null | grep -o '[0-9]*' | tail -1)
    if [ -n "$unused_volumes" ] && [ "$unused_volumes" -gt 0 ]; then
        log_info "BACKUP" "Removidos $unused_volumes volumes não utilizados"
    fi
    
    # Limpar cache de build
    local build_cache=$(docker builder prune -f 2>/dev/null | grep -o '[0-9]*' | tail -1)
    if [ -n "$build_cache" ] && [ "$build_cache" -gt 0 ]; then
        log_info "BACKUP" "Removido $build_cache de cache de build"
    fi
}

# Função para executar backup completo
execute_backup() {
    local timer=$(start_performance_timer "Backup Completo Dinâmico")
    
    log_info "BACKUP" "Iniciando backup dinâmico de ${#BACKUP_TARGETS[@]} containers"
    
    # Validar configuração
    if ! validate_backup_config; then
        log_error "BACKUP" "Configuração inválida, abortando backup"
        end_performance_timer "$timer"
        return 1
    fi
    
    # Verificar Docker
    if [ "$BACKUP_CHECK_DOCKER" = true ]; then
        log_info "BACKUP" "Verificando Docker"
        if ! docker info >/dev/null 2>&1; then
            log_error "BACKUP" "Docker não está rodando"
            end_performance_timer "$timer"
            return 1
        fi
    fi
    
    # Verificar espaço em disco
    if [ "$BACKUP_CHECK_DISK_SPACE" = true ]; then
        log_info "BACKUP" "Verificando espaço em disco"
        local available_space=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
        local required_space=$((BACKUP_MIN_DISK_SPACE_GB * 1024 * 1024))  # Convert to KB
        
        if [ "$available_space" -lt "$required_space" ]; then
            log_warning "BACKUP" "Espaço insuficiente em disco: ${available_space}KB disponível, ${required_space}KB necessário"
            log_info "BACKUP" "Tentando limpar recursos Docker para liberar espaço"
            cleanup_docker_resources
            
            # Verificar novamente após limpeza
            local new_available_space=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
            if [ "$new_available_space" -lt "$required_space" ]; then
                log_error "BACKUP" "Espaço ainda insuficiente após limpeza: ${new_available_space}KB disponível, ${required_space}KB necessário"
                end_performance_timer "$timer"
                return 1
            else
                log_info "BACKUP" "Espaço suficiente após limpeza: ${new_available_space}KB disponível"
            fi
        fi
    fi
    
    # Ordenar containers por prioridade
    local sorted_targets=($(for target in "${BACKUP_TARGETS[@]}"; do
        local priority=$(echo "$target" | cut -d: -f3)
        echo "$priority:$target"
    done | sort -n | cut -d: -f2-))
    
    local success_count=0
    local total_count=${#sorted_targets[@]}
    
    # Executar backup de cada container
    for target in "${sorted_targets[@]}"; do
        local container=$(echo "$target" | cut -d: -f1)
        local volume=$(echo "$target" | cut -d: -f2)
        local priority=$(echo "$target" | cut -d: -f3)
        local stop_before=$(echo "$target" | cut -d: -f4)
        
        if backup_container "$container" "$volume" "$stop_before" "$priority"; then
            ((success_count++))
        fi
    done
    
    # Relatório final
    log_info "BACKUP" "Backup dinâmico concluído: $success_count/$total_count containers"
    
    if [ $success_count -eq $total_count ]; then
        log_info "BACKUP" "🎉 Todos os backups foram concluídos com sucesso!"
        
        # Verificação final: listar todos os arquivos criados
        log_info "BACKUP" "📁 Verificando arquivos criados em: $BACKUP_DIR"
        if [ -d "$BACKUP_DIR" ]; then
            local backup_files=$(find "$BACKUP_DIR" -name "*.tar.gz" -type f -newer "$BACKUP_DIR" 2>/dev/null | wc -l)
            if [ "$backup_files" -gt 0 ]; then
                log_info "BACKUP" "✅ $backup_files arquivo(s) de backup encontrado(s):"
                find "$BACKUP_DIR" -name "*.tar.gz" -type f -newer "$BACKUP_DIR" 2>/dev/null | while read file; do
                    local file_size=$(ls -lh "$file" | awk '{print $5}')
                    log_info "BACKUP" "   📄 $(basename "$file") (${file_size})"
                done
            else
                log_warning "BACKUP" "⚠️  Nenhum arquivo de backup encontrado no diretório"
            fi
        else
            log_error "BACKUP" "❌ Diretório de backup não existe: $BACKUP_DIR"
        fi
    else
        log_warning "BACKUP" "⚠️  $((total_count - success_count)) backup(s) falharam"
    fi
    
    end_performance_timer "$timer"
    return 0
}

# Função para testar backup sem executar
test_backup() {
    log_info "TEST" "Testando configuração de backup"
    
    echo ""
    echo "🧪 Teste de Configuração de Backup"
    echo "=================================="
    echo ""
    
    # Validar configuração
    if validate_backup_config; then
        echo "✅ Configuração válida"
    else
        echo "❌ Configuração inválida"
        return 1
    fi
    
    # Listar containers
    echo ""
    echo "📋 Containers Configurados:"
    list_backup_targets
    
    # Verificar Docker
    echo ""
    echo "🐳 Verificação do Docker:"
    if docker info >/dev/null 2>&1; then
        echo "✅ Docker está rodando"
    else
        echo "❌ Docker não está rodando"
    fi
    
    # Verificar espaço em disco
    echo ""
    echo "💾 Verificação de Espaço em Disco:"
    if [ -d "$BACKUP_DIR" ]; then
        local available_space=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
        local required_space=$((BACKUP_MIN_DISK_SPACE_GB * 1024 * 1024))
        echo "  Diretório: $BACKUP_DIR"
        echo "  Disponível: ${available_space}KB"
        echo "  Necessário: ${required_space}KB"
        
        if [ "$available_space" -ge "$required_space" ]; then
            echo "✅ Espaço suficiente"
        else
            echo "❌ Espaço insuficiente"
        fi
    else
        echo "⚠️  Diretório de backup não existe: $BACKUP_DIR"
    fi
    
    echo ""
    echo "✅ Teste concluído"
}

# Função principal
main() {
    local command="${1:-backup}"  # Executa backup por padrão se não há argumentos
    
    case "$command" in
        backup)
            execute_backup
            ;;
        list)
            list_backup_targets
            ;;
        validate)
            validate_backup_config
            ;;
        test)
            test_backup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "MAIN" "Comando desconhecido: $command"
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
