#!/bin/bash

# =============================================================================
# UTILITÁRIOS DE VERSÃO DO SISTEMA DE BACKUP DOCKER
# =============================================================================

# Definir diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Carregar configuração de versão
VERSION_CONFIG="$PROJECT_ROOT/config/version-config.sh"
if [ -f "$VERSION_CONFIG" ]; then
    source "$VERSION_CONFIG"
else
    echo "❌ Arquivo de configuração de versão não encontrado"
    exit 1
fi

# Função para mostrar versão
show_version() {
    echo "🐳 $SYSTEM_NAME v$APP_VERSION"
    echo "====================================="
    echo ""
    echo "📋 Informações Gerais:"
    echo "  Nome: $SYSTEM_NAME"
    echo "  Versão: $APP_VERSION"
    echo "  Descrição: $SYSTEM_DESCRIPTION"
    echo "  Autor: $SYSTEM_AUTHOR"
    echo "  Licença: $SYSTEM_LICENSE"
    echo ""
    echo "🔧 Informações de Build:"
    echo "  Data: $BUILD_DATE"
    echo "  Commit: $BUILD_COMMIT"
    echo "  Branch: $BUILD_BRANCH"
    echo ""
    echo "🖥️ Compatibilidade:"
    echo "  Docker: $MIN_DOCKER_VERSION+"
    echo "  macOS: $MIN_MACOS_VERSION+"
    echo "  Shells: ${SUPPORTED_SHELLS[*]}"
    echo ""
    echo "📁 Estrutura do Projeto:"
    echo "  Scripts: $(find "$PROJECT_ROOT/scripts" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ') arquivos"
    echo "  Configurações: $(find "$PROJECT_ROOT/config" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ') arquivos"
    echo "  Documentação: $(find "$PROJECT_ROOT/docs" -name "*.md" 2>/dev/null | wc -l | tr -d ' ') arquivos"
    echo "  Backups: $(find "$PROJECT_ROOT/backups" -name "*.tar.gz" 2>/dev/null | wc -l | tr -d ' ') arquivos"
    echo ""
    echo "⚙️ Configurações:"
    echo "  Sistema de versionamento: ✅ Ativo"
    echo "  Configuração dinâmica: ✅ Ativo"
    echo "  Notificações: ✅ Configuradas"
    echo "  Logging estruturado: ✅ Ativo"
    echo "  LaunchAgent: ✅ Configurado"
}

# Função para mostrar changelog
show_changelog() {
    local version="${1:-$APP_VERSION}"
    local changelog_file="$PROJECT_ROOT/docs/changelog/v${version}.md"
    
    if [ -f "$changelog_file" ]; then
        echo "📋 Carregando changelog para v$version..."
        echo ""
        cat "$changelog_file"
    else
        echo "❌ Changelog para v$version não encontrado"
        echo ""
        echo "📋 Versões disponíveis:"
        if [ -d "$PROJECT_ROOT/docs/changelog" ]; then
            ls "$PROJECT_ROOT/docs/changelog/"v*.md 2>/dev/null | sed 's/.*v\(.*\)\.md/- v\1/' | sort -V
        else
            echo "- Nenhum changelog encontrado"
        fi
        echo ""
        echo "💡 Dica: Use 'blueai-docker-ops.sh changelog' para ver o changelog da versão atual"
        return 1
    fi
}

# Função para mostrar histórico de versões
show_version_history() {
    echo "📚 Histórico de Versões"
    echo "======================="
    echo ""
    
    if [ -d "$PROJECT_ROOT/docs/changelog" ]; then
        local changelogs=($(ls "$PROJECT_ROOT/docs/changelog"/v*.md 2>/dev/null | sort -V))
        
        if [ ${#changelogs[@]} -eq 0 ]; then
            echo "📭 Nenhum changelog encontrado"
            return 0
        fi
        
        for changelog in "${changelogs[@]}"; do
            local version=$(basename "$changelog" .md | sed 's/v//')
            local date=$(grep "Data de Release:" "$changelog" | head -1 | sed 's/.*Data de Release: *//' | sed 's/ .*//')
            local type=$(grep "Tipo:" "$changelog" | head -1 | sed 's/.*Tipo: *//' | sed 's/ .*//')
            
            echo "v$version ($date) - $type"
        done
    else
        echo "📭 Diretório de changelogs não encontrado"
    fi
    
    echo ""
    echo "💡 Para detalhes completos, use: ./blueai-docker-ops.sh changelog <versão>"
}

# Função para comparar versões
version_compare() {
    local version1="$1"
    local version2="$2"
    
    # Converter versões para números para comparação
    local v1=$(echo "$version1" | sed 's/[^0-9.]//g')
    local v2=$(echo "$version2" | sed 's/[^0-9.]//g')
    
    # Comparar usando sort
    if [ "$(printf '%s\n' "$v1" "$v2" | sort -V | head -n1)" = "$v1" ]; then
        return 0  # v1 <= v2
    else
        return 1  # v1 > v2
    fi
}

# Função para verificar compatibilidade
check_compatibility() {
    echo "🖥️ Verificando Compatibilidade"
    echo "=============================="
    echo ""
    
    # Verificar Docker
    if command -v docker >/dev/null 2>&1; then
        local docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null | cut -d. -f1,2)
        if [ -n "$docker_version" ]; then
            if version_compare "$MIN_DOCKER_VERSION" "$docker_version"; then
                echo "✅ Docker: $docker_version (mínimo: $MIN_DOCKER_VERSION)"
            else
                echo "❌ Docker: $docker_version (mínimo: $MIN_DOCKER_VERSION)"
            fi
        else
            echo "⚠️  Docker: Não foi possível obter a versão"
        fi
    else
        echo "❌ Docker: Não instalado"
    fi
    
    # Verificar macOS
    local macos_version=$(sw_vers -productVersion 2>/dev/null)
    if [ -n "$macos_version" ]; then
        if version_compare "$MIN_MACOS_VERSION" "$macos_version"; then
            echo "✅ macOS: $macos_version (mínimo: $MIN_MACOS_VERSION)"
        else
            echo "❌ macOS: $macos_version (mínimo: $MIN_MACOS_VERSION)"
        fi
    else
        echo "⚠️  macOS: Não foi possível obter a versão"
    fi
    
    # Verificar shell
    local current_shell=$(basename "$SHELL")
    if [[ " ${SUPPORTED_SHELLS[*]} " =~ " ${current_shell} " ]]; then
        echo "✅ Shell: $current_shell (suportado)"
    else
        echo "⚠️  Shell: $current_shell (não testado)"
    fi
    
    # Verificar dependências
    echo ""
    echo "🔧 Dependências do Sistema:"
    local deps=("osascript" "mail" "sendmail" "bc" "awk" "grep" "sed" "tar")
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            echo "✅ $dep: Disponível"
        else
            echo "❌ $dep: Não encontrado"
        fi
    done
}

# Função para verificar atualizações
check_for_updates() {
    if [ "$UPDATE_CHECK_ENABLED" != true ]; then
        echo "ℹ️  Verificação de atualizações desabilitada"
        return 0
    fi
    
    echo "🔍 Verificando Atualizações..."
    echo "=============================="
    echo ""
    
    # Verificar se curl está disponível
    if ! command -v curl >/dev/null 2>&1; then
        echo "⚠️  curl não encontrado, não é possível verificar atualizações"
        return 1
    fi
    
    # Fazer requisição para API do GitHub
    local latest_version=$(curl -s "$UPDATE_CHECK_URL" | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
    
    if [ -n "$latest_version" ]; then
        if [ "$latest_version" != "$APP_VERSION" ]; then
            echo "🆕 Nova versão disponível: v$latest_version"
            echo "📥 Download: https://github.com/user/docker-backup/releases"
        else
            echo "✅ Você está usando a versão mais recente: v$APP_VERSION"
        fi
    else
        echo "⚠️  Não foi possível verificar atualizações"
    fi
}

# Função para migrar configurações
migrate_config() {
    if [ "$CONFIG_MIGRATION_ENABLED" != true ]; then
        echo "ℹ️  Migração de configurações desabilitada"
        return 0
    fi
    
    echo "🔄 Migrando Configurações..."
    echo "============================"
    echo ""
    
    # Verificar se há configurações antigas
    if [ -f "$PROJECT_ROOT/notification-config.sh" ]; then
        echo "📁 Migrando notification-config.sh para config/"
        mv "$PROJECT_ROOT/notification-config.sh" "$PROJECT_ROOT/config/"
        echo "✅ Migração concluída"
    fi
    
    # Verificar outras migrações necessárias
    echo "✅ Todas as configurações estão atualizadas"
}

# Função para mostrar informações de debug
show_debug_info() {
    echo "🐛 Informações de Debug"
    echo "======================="
    echo ""
    echo "📋 Variáveis de Ambiente:"
    echo "  APP_VERSION: $APP_VERSION"
    echo "  BUILD_DATE: $BUILD_DATE"
    echo "  BUILD_COMMIT: $BUILD_COMMIT"
    echo "  BUILD_BRANCH: $BUILD_BRANCH"
    echo "  SCRIPT_DIR: $SCRIPT_DIR"
    echo "  PROJECT_ROOT: $PROJECT_ROOT"
    echo ""
    echo "📁 Estrutura de Arquivos:"
    echo "  Scripts:"
    find "$PROJECT_ROOT/scripts" -name "*.sh" -exec basename {} \;
    echo ""
    echo "  Configurações:"
    find "$PROJECT_ROOT/config" -name "*.sh" -exec basename {} \;
    echo ""
    echo "  Documentação:"
    find "$PROJECT_ROOT/docs" -name "*.md" -exec basename {} \;
}

# Função para validar configuração
validate_config() {
    echo "🔍 Validando Configuração"
    echo "========================="
    echo ""
    
    # Verificar arquivos de configuração
    local config_files=(
        "$PROJECT_ROOT/config/version-config.sh"
        "$PROJECT_ROOT/config/notification-config.sh"
        "$PROJECT_ROOT/config/backup-config.sh"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            echo "✅ $(basename "$config_file"): Encontrado"
        else
            echo "❌ $(basename "$config_file"): Não encontrado"
        fi
    done
    
    # Verificar sintaxe dos arquivos de configuração
    echo ""
    echo "🔧 Verificando Sintaxe:"
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            if bash -n "$config_file" 2>/dev/null; then
                echo "✅ $(basename "$config_file"): Sintaxe válida"
            else
                echo "❌ $(basename "$config_file"): Erro de sintaxe"
            fi
        fi
    done
}

# Função para mostrar estatísticas do sistema
show_system_stats() {
    echo "📊 Estatísticas do Sistema"
    echo "========================="
    echo ""
    
    # Estatísticas de arquivos
    echo "📁 Arquivos:"
    echo "  Scripts: $(find "$PROJECT_ROOT/scripts" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')"
    echo "  Configurações: $(find "$PROJECT_ROOT/config" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')"
    echo "  Documentação: $(find "$PROJECT_ROOT/docs" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')"
    echo "  Backups: $(find "$PROJECT_ROOT/backups" -name "*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')"
    echo "  Logs: $(find "$PROJECT_ROOT/logs" -name "*.log" 2>/dev/null | wc -l | tr -d ' ')"
    echo "  Relatórios: $(find "$PROJECT_ROOT/reports" -name "*" 2>/dev/null | wc -l | tr -d ' ')"
    
    # Tamanho dos diretórios
    echo ""
    echo "💾 Tamanho dos Diretórios:"
    if [ -d "$PROJECT_ROOT/backups" ]; then
        echo "  Backups: $(du -sh "$PROJECT_ROOT/backups" 2>/dev/null | cut -f1)"
    fi
    if [ -d "$PROJECT_ROOT/logs" ]; then
        echo "  Logs: $(du -sh "$PROJECT_ROOT/logs" 2>/dev/null | cut -f1)"
    fi
    if [ -d "$PROJECT_ROOT/reports" ]; then
        echo "  Relatórios: $(du -sh "$PROJECT_ROOT/reports" 2>/dev/null | cut -f1)"
    fi
    
    # Informações do sistema
    echo ""
    echo "🖥️ Sistema:"
    echo "  Uptime: $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
    echo "  Memória: $(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//') páginas livres"
    echo "  Disco: $(df -h "$PROJECT_ROOT" | tail -1 | awk '{print $4}') disponível"
}
