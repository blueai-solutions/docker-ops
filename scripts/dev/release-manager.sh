#!/bin/bash

# =============================================================================
# Gerenciador de Releases - BlueAI Docker Ops
# =============================================================================
# Autor: BlueAI Solutions
# Versão: 1.0.0
# Descrição: Script para gerenciar releases e tags do projeto
# =============================================================================

# Sourcing de configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSION_CONFIG="$PROJECT_ROOT/config/version-config.sh"

# Carregar configurações
if [ -f "$VERSION_CONFIG" ]; then
    source "$VERSION_CONFIG"
else
    echo "❌ Arquivo de configuração não encontrado: $VERSION_CONFIG"
    exit 1
fi

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de log
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Função para mostrar ajuda
show_help() {
    cat << EOF
Uso: $0 [COMANDO] [OPÇÕES]

COMANDOS:
  create-release [versão]  Criar nova release com tag
  list-releases            Listar todas as releases
  show-current            Mostrar versão atual
  bump-version [tipo]     Incrementar versão (major|minor|patch)
  check-status            Verificar status do repositório
  help                    Mostrar esta ajuda

OPÇÕES:
  --force, -f             Forçar operação sem confirmação
  --dry-run, -d           Simular operação sem executar
  --message, -m           Mensagem personalizada para commit

EXEMPLOS:
  $0 create-release 2.4.0
  $0 bump-version minor
  $0 list-releases
  $0 check-status

TIPOS DE VERSÃO:
  major    - Incrementa versão principal (2.3.1 -> 3.0.0)
  minor    - Incrementa versão menor (2.3.1 -> 2.4.0)
  patch    - Incrementa versão de patch (2.3.1 -> 2.3.2)
EOF
}

# Função para verificar se estamos em um repositório git
check_git_repo() {
    if [ ! -d ".git" ]; then
        log_error "Este diretório não é um repositório git"
        exit 1
    fi
    
    if ! git status > /dev/null 2>&1; then
        log_error "Erro ao acessar repositório git"
        exit 1
    fi
}

# Função para obter versão atual
get_current_version() {
    if [ -f "VERSION" ]; then
        cat VERSION
    else
        log_error "Arquivo VERSION não encontrado"
        exit 1
    fi
}

# Função para validar formato de versão
validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Formato de versão inválido: $version"
        log_error "Use o formato: MAJOR.MINOR.PATCH (ex: 2.3.1)"
        exit 1
    fi
}

# Função para incrementar versão
bump_version() {
    local bump_type="$1"
    local current_version=$(get_current_version)
    local major minor patch
    
    IFS='.' read -r major minor patch <<< "$current_version"
    
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            log_error "Tipo de bump inválido: $bump_type"
            log_error "Use: major, minor ou patch"
            exit 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Função para criar release
create_release() {
    local version="$1"
    local message="${2:-"Release v$version"}"
    
    log_info "Criando release v$version..."
    
    # Verificar se a versão já existe
    if git tag -l "v$version" | grep -q "v$version"; then
        log_error "Tag v$version já existe"
        exit 1
    fi
    
    # Verificar se há mudanças não commitadas
    if [ -n "$(git status --porcelain)" ]; then
        log_warning "Há mudanças não commitadas no repositório"
        git status --short
        
        if [ "$FORCE" != "true" ]; then
            read -p "Deseja continuar? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Operação cancelada"
                exit 0
            fi
        fi
    fi
    
    # Atualizar arquivo VERSION
    echo "$version" > VERSION
    
    # Commit das mudanças
    git add VERSION
    git commit -m "chore: bump version to $version"
    
    # Criar tag
    git tag -a "v$version" -m "$message"
    
    # Push das mudanças e tag
    git push origin main
    git push origin "v$version"
    
    log_success "Release v$version criada com sucesso!"
    log_info "Tag: v$version"
    log_info "Commit: $(git rev-parse HEAD)"
}

# Função para listar releases
list_releases() {
    log_info "Listando releases disponíveis..."
    
    local tags=$(git tag -l "v*" --sort=-version:refname)
    
    if [ -z "$tags" ]; then
        log_warning "Nenhuma release encontrada"
        return
    fi
    
    echo
    echo "🏷️  RELEASES DISPONÍVEIS"
    echo "========================="
    
    for tag in $tags; do
        local commit_hash=$(git rev-list -n 1 "$tag")
        local commit_date=$(git log -1 --format=%cd --date=short "$tag")
        local commit_message=$(git log -1 --format=%s "$tag")
        
        echo "📋 $tag ($commit_date)"
        echo "   Commit: $commit_hash"
        echo "   Mensagem: $commit_message"
        echo
    done
}

# Função para mostrar versão atual
show_current() {
    local current_version=$(get_current_version)
    local latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "Nenhuma")
    
    echo "📋 INFORMAÇÕES DA VERSÃO"
    echo "=========================="
    echo "📄 Arquivo VERSION: $current_version"
    echo "🏷️  Última tag: $latest_tag"
    echo "📅 Último commit: $(git log -1 --format=%cd --date=short)"
    echo "🔗 Branch atual: $(git branch --show-current)"
}

# Função para verificar status do repositório
check_status() {
    log_info "Verificando status do repositório..."
    
    echo
    echo "📊 STATUS DO REPOSITÓRIO"
    echo "========================="
    
    # Status do git
    echo "🔍 Status Git:"
    git status --short
    
    echo
    echo "📋 Branches:"
    git branch -a
    
    echo
    echo "🏷️  Tags:"
    git tag -l "v*" | tail -5
    
    echo
    echo "📅 Últimos commits:"
    git log --oneline -5
}

# Função principal
main() {
    local command="${1:-help}"
    local arg1="$2"
    local arg2="$3"
    
    # Verificar se estamos em um repositório git
    check_git_repo
    
    case "$command" in
        create-release)
            if [ -z "$arg1" ]; then
                log_error "Versão não especificada"
                show_help
                exit 1
            fi
            validate_version "$arg1"
            create_release "$arg1" "$arg2"
            ;;
        list-releases)
            list_releases
            ;;
        show-current)
            show_current
            ;;
        bump-version)
            if [ -z "$arg1" ]; then
                log_error "Tipo de bump não especificado"
                show_help
                exit 1
            fi
            local new_version=$(bump_version "$arg1")
            log_info "Nova versão: $new_version"
            create_release "$new_version" "Release v$new_version"
            ;;
        check-status)
            check_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Comando desconhecido: $command"
            show_help
            exit 1
            ;;
    esac
}

# Processar argumentos
FORCE="false"
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE="true"
            shift
            ;;
        --dry-run|-d)
            DRY_RUN="true"
            shift
            ;;
        --message|-m)
            RELEASE_MESSAGE="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Executar função principal
main "$@"
