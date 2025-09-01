#!/bin/bash

# =============================================================================
# SCRIPT DE LIMPEZA DE FUNCIONALIDADES DEPRECIADAS
# =============================================================================

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Função para mostrar ajuda
show_help() {
    echo "🧹 Limpeza de Funcionalidades Depreciadas"
    echo "========================================="
    echo ""
    echo "Uso: $0 [opção]"
    echo ""
    echo "OPÇÕES:"
    echo "  --check         Verificar funcionalidades depreciadas"
    echo "  --remove        Remover funcionalidades depreciadas"
    echo "  --help, -h      Mostrar esta ajuda"
    echo ""
    echo "EXEMPLOS:"
    echo "  $0 --check"
    echo "  $0 --remove"
}

# Função para verificar funcionalidades depreciadas
check_deprecated() {
    echo "🔍 Verificando funcionalidades depreciadas..."
    echo "============================================="
    echo ""
    
    local deprecated_items=()
    
    # Verificar smart-backup.sh
    if [ -f "$PROJECT_ROOT/scripts/backup/smart-backup.sh" ]; then
        deprecated_items+=("smart-backup.sh")
        echo "❌ smart-backup.sh - Script de backup antigo (substituído por dynamic-backup.sh)"
    fi
    
    # Verificar outros arquivos depreciados
    if [ -f "$PROJECT_ROOT/scripts/backup/legacy-backup.sh" ]; then
        deprecated_items+=("legacy-backup.sh")
        echo "❌ legacy-backup.sh - Script de backup legado"
    fi
    
    # Verificar configurações antigas
    if [ -f "$PROJECT_ROOT/config/old-backup-config.sh" ]; then
        deprecated_items+=("old-backup-config.sh")
        echo "❌ old-backup-config.sh - Configuração de backup antiga"
    fi
    
    if [ ${#deprecated_items[@]} -eq 0 ]; then
        echo "✅ Nenhuma funcionalidade depreciada encontrada"
        return 0
    else
        echo ""
        echo "📋 Total de itens depreciados: ${#deprecated_items[@]}"
        echo ""
        echo "💡 Use '$0 --remove' para remover estes itens"
        return 1
    fi
}

# Função para remover funcionalidades depreciadas
remove_deprecated() {
    echo "🗑️  Removendo funcionalidades depreciadas..."
    echo "==========================================="
    echo ""
    
    local removed_items=()
    
    # Remover smart-backup.sh
    if [ -f "$PROJECT_ROOT/scripts/backup/smart-backup.sh" ]; then
        echo "🗑️  Removendo smart-backup.sh..."
        rm "$PROJECT_ROOT/scripts/backup/smart-backup.sh"
        removed_items+=("smart-backup.sh")
    fi
    
    # Remover outros arquivos depreciados
    if [ -f "$PROJECT_ROOT/scripts/backup/legacy-backup.sh" ]; then
        echo "🗑️  Removendo legacy-backup.sh..."
        rm "$PROJECT_ROOT/scripts/backup/legacy-backup.sh"
        removed_items+=("legacy-backup.sh")
    fi
    
    if [ -f "$PROJECT_ROOT/config/old-backup-config.sh" ]; then
        echo "🗑️  Removendo old-backup-config.sh..."
        rm "$PROJECT_ROOT/config/old-backup-config.sh"
        removed_items+=("old-backup-config.sh")
    fi
    
    if [ ${#removed_items[@]} -eq 0 ]; then
        echo "✅ Nenhum item depreciado encontrado para remoção"
    else
        echo ""
        echo "✅ Itens removidos:"
        for item in "${removed_items[@]}"; do
            echo "   - $item"
        done
        echo ""
        echo "🎉 Limpeza concluída com sucesso!"
    fi
}

# Função principal
main() {
    case "$1" in
        --check)
            check_deprecated
            ;;
        --remove)
            echo "⚠️  ATENÇÃO: Esta operação irá remover permanentemente arquivos depreciados!"
            echo "💡 Recomendamos fazer backup antes de continuar."
            echo ""
            read -p "Deseja continuar? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                remove_deprecated
            else
                echo "❌ Operação cancelada"
                exit 0
            fi
            ;;
        --help|-h|"")
            show_help
            ;;
        *)
            echo "❌ Opção inválida: $1"
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
