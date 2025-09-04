#!/bin/bash

# =============================================================================
# GERENCIADOR DE BACKUPS DE CONFIGURAÇÃO
# =============================================================================

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKUP_CONFIG_DIR="$PROJECT_ROOT/config/backups"

# Carregar funções de logging
source "$SCRIPT_DIR/../logging/logging-functions.sh"

# Função para mostrar ajuda
show_help() {
    echo "📁 Gerenciador de Backups de Configuração"
    echo "========================================="
    echo ""
    echo "Uso: $0 [comando] [opções]"
    echo ""
    echo "COMANDOS:"
    echo "  list                    Listar backups disponíveis"
    echo "  restore <arquivo>       Restaurar backup específico"
    echo "  clean [dias]           Limpar backups antigos (padrão: 30 dias)"
    echo "  info <arquivo>         Mostrar informações do backup"
    echo "  diff <arquivo>         Comparar backup com configuração atual"
    echo "  help                   Mostrar esta ajuda"
    echo ""
    echo "EXEMPLOS:"
    echo "  $0 list"
    echo "  $0 restore backup-config.sh.backup.20250829_190021"
    echo "  $0 clean 7"
    echo "  $0 info backup-config.sh.backup.20250829_190021"
}

# Função para listar backups
list_backups() {
    echo "📋 Backups de Configuração Disponíveis"
    echo "====================================="
    echo ""
    
    if [ ! -d "$BACKUP_CONFIG_DIR" ]; then
        echo "❌ Pasta de backups não encontrada: $BACKUP_CONFIG_DIR"
        return 1
    fi
    
    local backups=()
    while IFS= read -r -d '' backup; do
        backups+=("$backup")
    done < <(find "$BACKUP_CONFIG_DIR" -name "*.backup.*" -type f -print0 | sort -z)
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo "📭 Nenhum backup encontrado"
        return 0
    fi
    
    echo "📁 Pasta: $BACKUP_CONFIG_DIR"
    echo ""
    
    for backup in "${backups[@]}"; do
        local filename=$(basename "$backup")
        local size=$(du -h "$backup" 2>/dev/null | awk '{print $1}' || echo "N/A")
        local date=$(stat -f "%Sm" -t "%d/%m/%Y %H:%M" "$backup" 2>/dev/null || stat -c "%y" "$backup" 2>/dev/null | cut -d' ' -f1,2 || echo "N/A")
        
        echo "📄 $filename"
        echo "   📏 Tamanho: $size"
        echo "   📅 Data: $date"
        echo ""
    done
}

# Função para restaurar backup
restore_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        echo "❌ Erro: Especifique o arquivo de backup para restaurar"
        echo "Uso: $0 restore <arquivo>"
        return 1
    fi
    
    local backup_path="$BACKUP_CONFIG_DIR/$backup_file"
    
    if [ ! -f "$backup_path" ]; then
        echo "❌ Erro: Arquivo de backup não encontrado: $backup_path"
        return 1
    fi
    
    # Determinar tipo de configuração
    local config_type=""
    if [[ "$backup_file" == *"backup-config"* ]]; then
        config_type="backup"
        local target_config="$PROJECT_ROOT/config/backup-config.sh"
    elif [[ "$backup_file" == *"recovery-config"* ]]; then
        config_type="recovery"
        local target_config="$PROJECT_ROOT/config/recovery-config.sh"
    else
        echo "❌ Erro: Tipo de configuração não reconhecido"
        return 1
    fi
    
    echo "🔄 Restaurando configuração $config_type..."
    echo "📄 Backup: $backup_file"
    echo "🎯 Destino: $target_config"
    echo ""
    
    # Fazer backup da configuração atual
    if [ -f "$target_config" ]; then
        local current_backup="$BACKUP_CONFIG_DIR/$(basename "$target_config").backup.$(date +%Y%m%d_%H%M%S)"
        cp "$target_config" "$current_backup"
        echo "💾 Backup da configuração atual criado: $(basename "$current_backup")"
    fi
    
    # Restaurar backup
    cp "$backup_path" "$target_config"
    
    if [ $? -eq 0 ]; then
        echo "✅ Configuração $config_type restaurada com sucesso!"
        echo "💡 Use './blueai-docker-ops.sh volumes' para verificar"
    else
        echo "❌ Erro ao restaurar configuração"
        return 1
    fi
}

# Função para limpar backups antigos
clean_old_backups() {
    local days="${1:-30}"
    
    echo "🧹 Limpando backups mais antigos que $days dias..."
    echo ""
    
    if [ ! -d "$BACKUP_CONFIG_DIR" ]; then
        echo "❌ Pasta de backups não encontrada"
        return 1
    fi
    
    local deleted_count=0
    
    # Encontrar e remover backups antigos
    while IFS= read -r -d '' backup; do
        local filename=$(basename "$backup")
        echo "🗑️  Removendo: $filename"
        rm "$backup"
        ((deleted_count++))
    done < <(find "$BACKUP_CONFIG_DIR" -name "*.backup.*" -type f -mtime +$days -print0)
    
    if [ $deleted_count -eq 0 ]; then
        echo "✅ Nenhum backup antigo encontrado"
    else
        echo "✅ $deleted_count backup(s) removido(s)"
    fi
}

# Função para mostrar informações do backup
show_backup_info() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        echo "❌ Erro: Especifique o arquivo de backup"
        echo "Uso: $0 info <arquivo>"
        return 1
    fi
    
    local backup_path="$BACKUP_CONFIG_DIR/$backup_file"
    
    if [ ! -f "$backup_path" ]; then
        echo "❌ Erro: Arquivo de backup não encontrado: $backup_path"
        return 1
    fi
    
    echo "📄 Informações do Backup"
    echo "======================="
    echo ""
    echo "📁 Arquivo: $backup_file"
    echo "📏 Tamanho: $(du -h "$backup_path" | awk '{print $1}')"
    echo "📅 Data: $(stat -f "%Sm" -t "%d/%m/%Y %H:%M:%S" "$backup_path" 2>/dev/null || stat -c "%y" "$backup_path" 2>/dev/null)"
    echo ""
    
    # Mostrar primeiras linhas do arquivo
    echo "📋 Conteúdo (primeiras 20 linhas):"
    echo "-----------------------------------"
    head -20 "$backup_path"
}

# Função para comparar backup com configuração atual
compare_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        echo "❌ Erro: Especifique o arquivo de backup"
        echo "Uso: $0 diff <arquivo>"
        return 1
    fi
    
    local backup_path="$BACKUP_CONFIG_DIR/$backup_file"
    
    if [ ! -f "$backup_path" ]; then
        echo "❌ Erro: Arquivo de backup não encontrado: $backup_path"
        return 1
    fi
    
    # Determinar configuração atual
    local config_type=""
    local current_config=""
    
    if [[ "$backup_file" == *"backup-config"* ]]; then
        config_type="backup"
        current_config="$PROJECT_ROOT/config/backup-config.sh"
    elif [[ "$backup_file" == *"recovery-config"* ]]; then
        config_type="recovery"
        current_config="$PROJECT_ROOT/config/recovery-config.sh"
    else
        echo "❌ Erro: Tipo de configuração não reconhecido"
        return 1
    fi
    
    if [ ! -f "$current_config" ]; then
        echo "❌ Erro: Configuração atual não encontrada: $current_config"
        return 1
    fi
    
    echo "🔍 Comparando configuração $config_type"
    echo "====================================="
    echo ""
    echo "📄 Backup: $backup_file"
    echo "📄 Atual: $(basename "$current_config")"
    echo ""
    
    # Verificar se diff está disponível
    if command -v diff >/dev/null 2>&1; then
        diff "$backup_path" "$current_config" || echo "✅ Arquivos são idênticos"
    else
        echo "⚠️  Comando 'diff' não disponível"
        echo "💡 Instale diffutils para comparar arquivos"
    fi
}

# Função principal
main() {
    local command="$1"
    shift
    
    case "$command" in
        list)
            list_backups
            ;;
        restore)
            restore_backup "$1"
            ;;
        clean)
            clean_old_backups "$1"
            ;;
        info)
            show_backup_info "$1"
            ;;
        diff)
            compare_backup "$1"
            ;;
        help|--help|-h|"")
            show_help
            ;;
        *)
            echo "❌ Comando inválido: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
