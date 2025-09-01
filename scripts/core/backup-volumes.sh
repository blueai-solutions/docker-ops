#!/bin/bash

# Script para fazer backup dos volumes Docker
# Autor: Assistente IA
# Data: $(date)

set -e

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DATE=$(date +%Y%m%d_%H%M%S)

# Carregar configuração dinâmica
RECOVERY_CONFIG="$PROJECT_ROOT/config/recovery-config.sh"
if [ -f "$RECOVERY_CONFIG" ]; then
    source "$RECOVERY_CONFIG"
else
    echo "❌ Arquivo de configuração não encontrado: $RECOVERY_CONFIG"
    exit 1
fi

# Extrair volumes da configuração dinâmica
VOLUMES=()
CONTAINER_VOLUME_MAP=()

for target in "${RECOVERY_TARGETS[@]}"; do
    parts=($(echo "$target" | tr ':' '\n'))
    if [ ${#parts[@]} -ge 2 ]; then
        container_name="${parts[0]}"
        volume_path="${parts[1]}"
        volume_name=$(echo "$volume_path" | sed 's|/var/lib/docker/volumes/||' | sed 's|/_data||')
        
        VOLUMES+=("$volume_name")
        CONTAINER_VOLUME_MAP+=("$container_name:$volume_name")
    fi
done

# Função para mostrar ajuda
show_help() {
    echo "💾 Script de Backup de Volumes Docker"
    echo "====================================="
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  backup    - Faz backup de todos os volumes"
    echo "  restore   - Restaura backup (especificar arquivo)"
    echo "  list      - Lista backups disponíveis"
    echo "  volumes   - Lista volumes de backup (rollback)"
    echo "  rollback  - Reverte para volume anterior"
    echo "  clean     - Remove backups antigos (mais de 7 dias)"
    echo "  help      - Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 backup"
    echo "  $0 restore postgres-local-data_20241201_143022.tar.gz"
    echo "  $0 list"
    echo "  $0 volumes"
    echo "  $0 rollback postgres-local-data"
}

# Função para verificar se volume existe
volume_exists() {
    docker volume ls --format "{{.Name}}" | grep -q "^$1$"
}

# Função para obter container associado a um volume
get_container_for_volume() {
    local volume_name="$1"
    for mapping in "${CONTAINER_VOLUME_MAP[@]}"; do
        local container=$(echo "$mapping" | cut -d: -f1)
        local volume=$(echo "$mapping" | cut -d: -f2)
        if [ "$volume" = "$volume_name" ]; then
            echo "$container"
            return 0
        fi
    done
    echo ""
}

# Função para parar container de um volume
stop_container_for_volume() {
    local volume_name="$1"
    local container=$(get_container_for_volume "$volume_name")
    
    if [ -n "$container" ]; then
        if docker ps --format "{{.Names}}" | grep -q "^$container$"; then
            echo "  ⏸️  Parando $container..."
            docker stop "$container"
            sleep 2
            return 0
        fi
    fi
    return 1
}

# Função para reiniciar container de um volume
start_container_for_volume() {
    local volume_name="$1"
    local container=$(get_container_for_volume "$volume_name")
    
    if [ -n "$container" ]; then
        if docker ps -a --format "{{.Names}}" | grep -q "^$container$"; then
            echo "  ▶️  Reiniciando $container..."
            docker start "$container"
            return 0
        fi
    fi
    return 1
}

# Função para criar diretório de backup
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "📁 Criando diretório de backup: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
}

# Função para fazer backup
do_backup() {
    echo "💾 Iniciando backup dos volumes..."
    echo "=================================="
    
    create_backup_dir
    
    for volume in "${VOLUMES[@]}"; do
        if volume_exists "$volume"; then
            echo ""
            echo "📦 Fazendo backup do volume: $volume"
            backup_file="$BACKUP_DIR/${volume}_${DATE}.tar.gz"
            
            # Parar container associado a este volume (se existir)
            stop_container_for_volume "$volume"
            
            # Fazer backup
            echo "  💾 Criando arquivo: $backup_file"
            docker run --rm \
                -v "$volume":/source \
                -v "$BACKUP_DIR":/backup \
                alpine tar czf "/backup/$(basename "$backup_file")" -C /source .
            
            echo "  ✅ Backup concluído: $(basename "$backup_file")"
            
            # Reiniciar container se estava rodando
            start_container_for_volume "$volume"
        else
            echo "❌ Volume $volume não existe"
        fi
    done
    
    echo ""
    echo "🎉 Backup concluído!"
    echo "📁 Arquivos salvos em: $BACKUP_DIR"
}

# Função para restaurar backup
do_restore() {
    if [ -z "$2" ]; then
        echo "❌ Erro: Especifique o arquivo de backup"
        echo "Exemplo: $0 restore postgres-local-data_20241201_143022.tar.gz"
        exit 1
    fi
    
    backup_file="$2"
    if [ ! -f "$BACKUP_DIR/$backup_file" ]; then
        echo "❌ Erro: Arquivo de backup não encontrado: $BACKUP_DIR/$backup_file"
        exit 1
    fi
    
    # Extrair nome do volume do arquivo
    volume_name=$(echo "$backup_file" | sed 's/_[0-9]\{8\}_[0-9]\{6\}\.tar\.gz$//')
    
    echo "🔄 Restaurando backup: $backup_file"
    echo "📦 Volume: $volume_name"
    echo ""
    
    # Confirmar restauração
    read -p "⚠️  Isso irá sobrescrever o volume $volume_name. Continuar? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Restauração cancelada"
        exit 1
    fi
    
    # Parar container associado a este volume (se existir)
    stop_container_for_volume "$volume_name"
    
    # Preservar volume existente (nunca remover!)
    if volume_exists "$volume_name"; then
        local backup_timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_volume_name="${volume_name}_backup_${backup_timestamp}"
        
        echo "🛡️  Preservando volume existente: $volume_name"
        echo "📦 Renomeando para: $backup_volume_name"
        
        # Renomear volume existente para preservá-lo
        docker run --rm \
            -v "$volume_name":/source \
            -v "$backup_volume_name":/dest \
            alpine sh -c "cp -r /source/* /dest/ 2>/dev/null || true"
        
        echo "✅ Volume original preservado como: $backup_volume_name"
        echo "💡 Para reverter: $0 rollback $volume_name"
    fi
    
    # Criar volume para restauração
    echo "📦 Criando volume para restauração: $volume_name"
    docker volume create "$volume_name" 2>/dev/null || true
    
    # Restaurar dados
    echo "🔄 Restaurando dados..."
    docker run --rm \
        -v "$volume_name":/dest \
        -v "$(pwd)/$BACKUP_DIR":/backup \
        alpine sh -c "cd /dest && tar xzf /backup/$backup_file"
    
    echo "✅ Restauração concluída!"
    
    # Reiniciar container que foi parado
    echo "🔄 Reiniciando container..."
    start_container_for_volume "$volume_name"
    
    echo "✅ Restauração e reinicialização concluídas!"
    echo "💡 Container foi reiniciado automaticamente"
}

# Função para listar volumes de backup
list_backup_volumes() {
    echo "📦 Volumes de Backup (Rollback)"
    echo "==============================="
    echo ""
    
    local found_backups=false
    
    for volume in "${VOLUMES[@]}"; do
        local backup_volumes=$(docker volume ls --format "{{.Name}}" | grep "^${volume}_backup_" | sort -r)
        
        if [ -n "$backup_volumes" ]; then
            found_backups=true
            echo "📦 $volume:"
            echo "$backup_volumes" | while read -r backup_volume; do
                echo "  🔄 $backup_volume"
            done
            echo ""
        fi
    done
    
    if [ "$found_backups" = false ]; then
        echo "Nenhum volume de backup encontrado"
    else
        echo "💡 Use: $0 rollback [volume_name] para reverter"
    fi
}

# Função para fazer rollback
do_rollback() {
    if [ -z "$2" ]; then
        echo "❌ Erro: Especifique o nome do volume"
        echo "Exemplo: $0 rollback postgres-local-data"
        exit 1
    fi
    
    local volume_name="$2"
    local backup_volumes=$(docker volume ls --format "{{.Name}}" | grep "^${volume_name}_backup_" | sort -r)
    
    if [ -z "$backup_volumes" ]; then
        echo "❌ Nenhum volume de backup encontrado para: $volume_name"
        exit 1
    fi
    
    echo "🔄 Rollback para volume: $volume_name"
    echo "📦 Volumes de backup disponíveis:"
    echo "$backup_volumes" | nl
    
    echo ""
    read -p "⚠️  Escolha o número do volume para restaurar (1, 2, etc.): " choice
    
    local selected_backup=$(echo "$backup_volumes" | sed -n "${choice}p")
    
    if [ -z "$selected_backup" ]; then
        echo "❌ Escolha inválida"
        exit 1
    fi
    
    echo "🔄 Restaurando de: $selected_backup"
    echo "📦 Para: $volume_name"
    echo ""
    
    read -p "⚠️  Isso irá sobrescrever o volume atual. Continuar? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Rollback cancelado"
        exit 1
    fi
    
    # Parar container associado
    stop_container_for_volume "$volume_name"
    
    # Fazer backup do volume atual antes do rollback
    local current_timestamp=$(date +%Y%m%d_%H%M%S)
    local current_backup="${volume_name}_current_${current_timestamp}"
    
    echo "🛡️  Fazendo backup do volume atual..."
    docker run --rm \
        -v "$volume_name":/source \
        -v "$current_backup":/dest \
        alpine sh -c "cp -r /source/* /dest/ 2>/dev/null || true"
    
    echo "✅ Volume atual preservado como: $current_backup"
    
    # Restaurar do volume de backup
    echo "🔄 Restaurando dados do volume de backup..."
    docker run --rm \
        -v "$selected_backup":/source \
        -v "$volume_name":/dest \
        alpine sh -c "rm -rf /dest/* && cp -r /source/* /dest/ 2>/dev/null || true"
    
    # Reiniciar container
    echo "🔄 Reiniciando container..."
    start_container_for_volume "$volume_name"
    
    echo "✅ Rollback concluído!"
    echo "💡 Volume atual preservado como: $current_backup"
}

# Função para listar backups
list_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "📁 Diretório de backup não existe: $BACKUP_DIR"
        return
    fi
    
    echo "📋 Backups disponíveis:"
    echo "======================="
    
    local files_in_dir=$(ls -A "$BACKUP_DIR" 2>/dev/null)
    
    if [ -z "$files_in_dir" ]; then
        echo "Nenhum backup encontrado"
        return
    fi
    
    for volume in "${VOLUMES[@]}"; do
        echo ""
        echo "📦 $volume:"
        ls -lh "$BACKUP_DIR" | grep "$volume" | awk '{print "  " $9 " (" $5 ")"}'
    done
}

# Função para limpar backups antigos
clean_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "📁 Diretório de backup não existe: $BACKUP_DIR"
        return
    fi
    
    echo "🧹 Removendo backups antigos (mais de 7 dias)..."
    
    # Encontrar arquivos mais antigos que 7 dias
    old_files=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7)
    
    if [ -z "$old_files" ]; then
        echo "✅ Nenhum backup antigo encontrado"
        return
    fi
    
    echo "🗑️  Arquivos que serão removidos:"
    echo "$old_files"
    echo ""
    
    read -p "⚠️  Continuar com a remoção? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Limpeza cancelada"
        return
    fi
    
    echo "$old_files" | xargs rm -f
    echo "✅ Limpeza concluída!"
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Processar comando
case "$1" in
    backup)
        do_backup
        ;;
    restore)
        do_restore "$@"
        ;;
    list)
        list_backups
        ;;
    volumes)
        list_backup_volumes
        ;;
    rollback)
        do_rollback "$@"
        ;;
    clean)
        clean_backups
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
