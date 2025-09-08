#!/bin/bash

# =============================================================================
# BLUEAI DOCKER OPS - INSTALADOR AUTOMÁTICO
# =============================================================================
# Versão: Dinâmica (lida do arquivo VERSION)
# Autor: BlueAI Solutions
# Data: 2025-09-05

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações de instalação
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_DIR="/usr/local/blueai-docker-ops"
BIN_DIR="/usr/local/bin"
REPO_URL="https://github.com/blueai-solutions/docker-ops"
RELEASE_URL="https://api.github.com/repos/blueai-solutions/docker-ops/releases/latest"
CURRENT_USER=$(whoami)

# Obter versão atual do arquivo VERSION
if [[ -f "$PROJECT_ROOT/VERSION" ]]; then
    CURRENT_VERSION=$(cat "$PROJECT_ROOT/VERSION" | tr -d '\n\r' | xargs)
else
    CURRENT_VERSION="2.4.2"  # Fallback se arquivo não existir
fi

# Função para log colorido
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

log_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

# Função para mostrar cabeçalho
show_header() {
    echo ""
    echo -e "${CYAN}🐳 BLUEAI DOCKER OPS - INSTALADOR AUTOMÁTICO${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}Versão: $CURRENT_VERSION${NC}"
    echo -e "${CYAN}Autor: BlueAI Solutions${NC}"
    echo -e "${CYAN}Data: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
}

# Função para verificar se é root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Este script não deve ser executado como root"
        log_info "Execute como usuário normal (sudo será solicitado quando necessário)"
        exit 1
    fi
}

# Função para verificar sistema operacional
check_os() {
    log_step "Verificando sistema operacional..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local macos_version=$(sw_vers -productVersion)
        local major_version=$(echo "$macos_version" | cut -d. -f1)
        local minor_version=$(echo "$macos_version" | cut -d. -f2)
        
        if [[ "$major_version" -lt 10 ]] || [[ "$major_version" -eq 10 && "$minor_version" -lt 15 ]]; then
            log_error "macOS 10.15+ (Catalina) é necessário"
            log_info "Versão atual: $macos_version"
            exit 1
        fi
        
        log_success "Sistema operacional: macOS $macos_version"
    else
        log_error "Sistema operacional não suportado: $OSTYPE"
        log_info "Apenas macOS é suportado atualmente"
        exit 1
    fi
}

# Função para verificar Docker
check_docker() {
    log_step "Verificando instalação do Docker..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker não está instalado"
        log_info "Instale o Docker Desktop para macOS: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    local docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null | cut -d. -f1,2)
    if [[ -z "$docker_version" ]]; then
        log_error "Não foi possível obter a versão do Docker"
        log_info "Verifique se o Docker está rodando"
        exit 1
    fi
    
    # Verificar versão mínima (20.10.0)
    local required_version="20.10"
    if [[ "$docker_version" < "$required_version" ]]; then
        log_error "Docker $required_version+ é necessário"
        log_info "Versão atual: $docker_version"
        exit 1
    fi
    
    log_success "Docker: $docker_version"
    
    # Verificar se Docker está rodando
    if ! docker info &> /dev/null; then
        log_error "Docker não está rodando"
        log_info "Inicie o Docker Desktop e tente novamente"
        exit 1
    fi
    
    log_success "Docker está rodando"
}

# Função para verificar permissões
check_permissions() {
    log_step "Verificando permissões..."
    
    # Verificar se podemos escrever em /usr/local
    if [[ ! -w "/usr/local" ]]; then
        log_warning "Sem permissão de escrita em /usr/local"
        log_info "Solicitando permissões de administrador..."
        
        # Testar se sudo funciona sem senha
        if ! sudo -n true 2>/dev/null; then
            log_info "Digite sua senha de administrador quando solicitado:"
        fi
        
        # Tentar criar diretório temporário para testar permissões
        if sudo mkdir -p "/usr/local/blueai-docker-ops-test" 2>/dev/null; then
            sudo rm -rf "/usr/local/blueai-docker-ops-test"
            log_success "Permissões de administrador OK"
        else
            log_warning "Não foi possível obter permissões de administrador"
            log_info "Tentando instalar em diretório alternativo..."
            INSTALL_DIR="$HOME/.local/blueai-docker-ops"
            BIN_DIR="$HOME/.local/bin"
        fi
    else
        log_success "Permissões de escrita em /usr/local OK"
    fi
}

# Função para verificar espaço em disco
check_disk_space() {
    log_step "Verificando espaço em disco..."
    
    # Tentar diferentes diretórios para verificação
    local check_dirs=("$INSTALL_DIR" "/usr/local" "/tmp" ".")
    local available_space=""
    
    for dir in "${check_dirs[@]}"; do
        if [ -d "$dir" ]; then
            available_space=$(df "$dir" 2>/dev/null | awk 'NR==2 {print $4}' 2>/dev/null || echo "")
            if [ -n "$available_space" ] && [ "$available_space" -gt 0 ]; then
                break
            fi
        fi
    done
    
    # Se não conseguiu obter espaço, usar valor padrão
    if [ -z "$available_space" ] || [ "$available_space" -le 0 ]; then
        log_warning "Não foi possível verificar espaço em disco, continuando..."
        return 0
    fi
    
    local required_space=100000  # 100MB em KB
    
    if [[ "$available_space" -lt "$required_space" ]]; then
        log_warning "Espaço em disco pode ser insuficiente"
        log_info "Disponível: ${available_space}KB, Necessário: ${required_space}KB"
        log_info "Continuando com instalação..."
        return 0
    fi
    
    log_success "Espaço em disco OK: ${available_space}KB disponível"
}

# Função para verificar dependências
check_dependencies() {
    log_step "Verificando dependências..."
    
    # Verificar bash/zsh
    if [[ -z "$BASH_VERSION" ]] && [[ -z "$ZSH_VERSION" ]]; then
        log_error "Bash 4.0+ ou Zsh 5.0+ é necessário"
        exit 1
    fi
    
    log_success "Shell: $SHELL"
    
    # Verificar comandos essenciais
    local required_commands=("curl" "tar" "grep" "sed" "awk")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Comando '$cmd' não encontrado"
            exit 1
        fi
    done
    
    log_success "Dependências básicas OK"
}

# Função para criar diretórios
create_directories() {
    log_step "Criando diretórios de instalação..."
    
    local dirs=(
        "$INSTALL_DIR"
        "$INSTALL_DIR/bin"
        "$INSTALL_DIR/config"
        "$INSTALL_DIR/scripts"
        "$INSTALL_DIR/docs"
        "$HOME/BlueAI-Docker-Logs"
        "$HOME/BlueAI-Docker-Backups"
        "$INSTALL_DIR/reports"
        "$INSTALL_DIR/examples"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            sudo mkdir -p "$dir"
            log_info "Criado: $dir"
        fi
    done
    
    # Definir permissões
    sudo chown -R "$CURRENT_USER:staff" "$INSTALL_DIR"
    sudo chmod -R 755 "$INSTALL_DIR"
    
    log_success "Diretórios criados com sucesso"
}

# Função para verificar se arquivos locais existem
check_local_files() {
    local required_files=(
        "$PROJECT_ROOT/scripts"
        "$PROJECT_ROOT/config"
        "$PROJECT_ROOT/docs"
        "$PROJECT_ROOT/blueai-docker-ops.sh"
        "$PROJECT_ROOT/VERSION"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            return 1
        fi
    done
    return 0
}

# Função para baixar release do GitHub
download_from_github() {
    log_step "Baixando sistema BlueAI Docker Ops do GitHub..."
    
    # Criar diretório temporário
    local temp_dir=$(mktemp -d)
    local download_url=""
    local tarball_name=""
    
    # Tentar obter URL da última release
    log_info "Obtendo informações da última release..."
    if command -v curl &> /dev/null; then
        local release_info=$(curl -s "$RELEASE_URL" 2>/dev/null)
        if [[ $? -eq 0 ]] && [[ -n "$release_info" ]]; then
            # Extrair URL do tarball
            download_url=$(echo "$release_info" | grep -o '"tarball_url":"[^"]*"' | cut -d'"' -f4)
            tarball_name="blueai-docker-ops-$(echo "$release_info" | grep -o '"tag_name":"[^"]*"' | cut -d'"' -f4).tar.gz"
        fi
    fi
    
    # Se não conseguiu obter release, usar branch main
    if [[ -z "$download_url" ]]; then
        log_warning "Não foi possível obter release, usando branch main..."
        download_url="$REPO_URL/archive/refs/heads/main.tar.gz"
        tarball_name="blueai-docker-ops-main.tar.gz"
    fi
    
    # Download do tarball
    log_info "Baixando: $download_url"
    if command -v curl &> /dev/null; then
        curl -L -o "$temp_dir/$tarball_name" "$download_url"
    elif command -v wget &> /dev/null; then
        wget -O "$temp_dir/$tarball_name" "$download_url"
    else
        log_error "curl ou wget é necessário para download"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    if [[ $? -ne 0 ]] || [[ ! -f "$temp_dir/$tarball_name" ]]; then
        log_error "Falha no download do sistema"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Extrair tarball
    log_info "Extraindo arquivos..."
    cd "$temp_dir"
    tar -xzf "$tarball_name"
    
    # Encontrar diretório extraído
    local extracted_dir=$(find . -maxdepth 1 -type d -name "docker-ops*" | head -1)
    if [[ -z "$extracted_dir" ]]; then
        log_error "Não foi possível encontrar diretório extraído"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Copiar arquivos para diretório de instalação
    log_info "Copiando arquivos baixados..."
    
    # Scripts
    if [[ -d "$extracted_dir/scripts" ]]; then
        sudo cp -r "$extracted_dir/scripts/." "$INSTALL_DIR/scripts/"
    fi
    
    # Configurações
    if [[ -d "$extracted_dir/config" ]]; then
        sudo cp -r "$extracted_dir/config/." "$INSTALL_DIR/config/"
    fi
    
    # Documentação
    if [[ -d "$extracted_dir/docs" ]]; then
        sudo cp -r "$extracted_dir/docs/." "$INSTALL_DIR/docs/"
    fi
    
    # Arquivo principal
    if [[ -f "$extracted_dir/blueai-docker-ops.sh" ]]; then
        sudo cp "$extracted_dir/blueai-docker-ops.sh" "$INSTALL_DIR/bin/"
    fi
    
    # Versão
    if [[ -f "$extracted_dir/VERSION" ]]; then
        sudo cp "$extracted_dir/VERSION" "$INSTALL_DIR/"
    fi
    
    # README
    if [[ -f "$extracted_dir/README.md" ]]; then
        sudo cp "$extracted_dir/README.md" "$INSTALL_DIR/examples/"
    fi
    
    # Limpeza
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    log_success "Sistema baixado e copiado com sucesso"
}

# Função para copiar sistema local
copy_local_system() {
    log_step "Copiando sistema BlueAI Docker Ops (instalação local)..."
    
    log_info "Copiando arquivos do diretório local..."
    log_info "PROJECT_ROOT: $PROJECT_ROOT"
    log_info "INSTALL_DIR: $INSTALL_DIR"
    
    # Scripts principais
    sudo cp -r "$PROJECT_ROOT/scripts/." "$INSTALL_DIR/scripts/"
    sudo cp "$PROJECT_ROOT/blueai-docker-ops.sh" "$INSTALL_DIR/bin/"
    
    # Configurações
    sudo cp -r "$PROJECT_ROOT/config/." "$INSTALL_DIR/config/"
    
    # Documentação
    sudo cp -r "$PROJECT_ROOT/docs/." "$INSTALL_DIR/docs/"
    
    # Arquivos de versão
    sudo cp "$PROJECT_ROOT/VERSION" "$INSTALL_DIR/"
    
    # Exemplos
    sudo cp "$PROJECT_ROOT/README.md" "$INSTALL_DIR/examples/"
    
    log_success "Sistema copiado com sucesso"
}

# Função principal para obter sistema
download_system() {
    log_step "Obtendo sistema BlueAI Docker Ops..."
    
    # Verificar se arquivos locais existem
    if check_local_files; then
        log_info "Arquivos locais encontrados, usando instalação local"
        copy_local_system
    else
        log_info "Arquivos locais não encontrados, baixando do GitHub"
        download_from_github
    fi
}

# Função para configurar permissões
setup_permissions() {
    log_step "Configurando permissões..."
    
    # Tornar scripts executáveis
    sudo find "$INSTALL_DIR/scripts" -name "*.sh" -exec chmod +x {} \;
    sudo chmod +x "$INSTALL_DIR/bin/blueai-docker-ops.sh"
    
    # Definir proprietário correto
    sudo chown -R "$CURRENT_USER:staff" "$INSTALL_DIR"
    
    # Permissões específicas para logs e backups
    # sudo chmod 755 "$INSTALL_DIR/logs"
    sudo chmod 755 "$HOME/BlueAI-Docker-Logs"
    # sudo chmod 755 "$INSTALL_DIR/backups"
    sudo chmod 755 "$HOME/BlueAI-Docker-Backups"
    
    log_success "Permissões configuradas com sucesso"
}

# Função para criar links simbólicos
create_symlinks() {
    log_step "Criando links simbólicos..."
    
    # Link principal
    if [[ -L "$BIN_DIR/blueai-docker-ops" ]]; then
        sudo rm "$BIN_DIR/blueai-docker-ops"
    fi
    sudo ln -sf "$INSTALL_DIR/bin/blueai-docker-ops.sh" "$BIN_DIR/blueai-docker-ops"
    
    # Alias alternativo
    if [[ -L "$BIN_DIR/docker-ops" ]]; then
        sudo rm "$BIN_DIR/docker-ops"
    fi
    sudo ln -sf "$INSTALL_DIR/bin/blueai-docker-ops.sh" "$BIN_DIR/docker-ops"
    
    log_success "Links simbólicos criados com sucesso"
}

# Função para configurar sistema
configure_system() {
    log_step "Configurando sistema..."
    
    # Criar arquivo de configuração de ambiente
    local env_file="$INSTALL_DIR/config/install.env"
    cat > "$env_file" << EOF
# Configuração de instalação do BlueAI Docker Ops
INSTALL_DIR="$INSTALL_DIR"
INSTALL_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
INSTALL_USER="$CURRENT_USER"
SYSTEM_VERSION="$CURRENT_VERSION"
EOF
    
    # Configurar variáveis de ambiente no shell do usuário
    SHELL_RC=""
    if [[ "$SHELL" == *"zsh" ]]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.bash_profile"
    fi
    
    # Adicionar PATH se não existir
    if ! grep -q "blueai-docker-ops" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# BlueAI Docker Ops" >> "$SHELL_RC"
        echo "export BLUEAI_DOCKER_OPS_HOME=\"$INSTALL_DIR\"" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:$INSTALL_DIR/bin\"" >> "$SHELL_RC"
        log_info "Variáveis de ambiente adicionadas ao $SHELL_RC"
    fi
    
    log_success "Sistema configurado com sucesso"
}

# Função para testar instalação
test_installation() {
    log_step "Testando instalação..."
    
    # Verificar se comandos estão disponíveis
    if ! command -v blueai-docker-ops &> /dev/null; then
        log_error "Comando 'blueai-docker-ops' não encontrado no PATH"
        exit 1
    fi
    
    if ! command -v docker-ops &> /dev/null; then
        log_error "Comando 'docker-ops' não encontrado no PATH"
        exit 1
    fi
    
    log_success "Comandos disponíveis no PATH"
    
    # Testar versão
    local version_output=$(blueai-docker-ops --version 2>/dev/null || echo "ERRO")
    if [[ "$version_output" == "ERRO" ]]; then
        log_warning "Não foi possível verificar a versão (normal para instalação inicial)"
    else
        log_success "Versão: $version_output"
    fi
    
    # Testar ajuda
    if blueai-docker-ops --help &> /dev/null; then
        log_success "Sistema funcionando corretamente"
    else
        log_warning "Sistema instalado mas pode precisar de configuração adicional"
        log_info "Execute: blueai-docker-ops config"
    fi
}

# Função para mostrar informações pós-instalação
show_post_install_info() {
    echo ""
    echo -e "${GREEN}🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
    echo ""
    echo -e "${CYAN}📁 Diretório de instalação:${NC} $INSTALL_DIR"
    echo -e "${CYAN}🔧 Comandos disponíveis:${NC}"
    echo -e "   • blueai-docker-ops (comando principal)"
    echo -e "   • docker-ops (alias alternativo)"
    echo ""
    echo -e "${CYAN}📚 Documentação:${NC} $INSTALL_DIR/docs/"
    echo -e "${CYAN}⚙️  Configurações:${NC} $INSTALL_DIR/config/"
    echo -e "${CYAN}📝 Logs:${NC} $HOME/BlueAI-Docker-Logs/"
    echo ""
    echo -e "${CYAN}🚀 Para começar:${NC}"
    echo -e "   • blueai-docker-ops --help"
    echo -e "   • blueai-docker-ops config containers"
    echo -e "   • blueai-docker-ops backup"
    echo ""
    echo -e "${CYAN}📖 Guia completo:${NC} $INSTALL_DIR/docs/guia-inicio-rapido.md"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANTE:${NC} Reinicie seu terminal ou execute:"
echo -e "   source $SHELL_RC"
    echo ""
}

# Função para limpeza em caso de erro
cleanup_on_error() {
    log_error "Instalação falhou. Limpando arquivos..."
    
    if [[ -d "$INSTALL_DIR" ]]; then
        sudo rm -rf "$INSTALL_DIR"
    fi
    
    # Remover links simbólicos
    sudo rm -f "$BIN_DIR/blueai-docker-ops"
    sudo rm -f "$BIN_DIR/docker-ops"
    
    log_info "Limpeza concluída"
}

# Função principal
main() {
    # Configurar trap para limpeza em caso de erro
    trap cleanup_on_error ERR
    
    show_header
    
    log_info "Iniciando instalação do BlueAI Docker Ops..."
    log_info "Versão: $CURRENT_VERSION"
    log_info "Usuário: $CURRENT_USER"
    log_info "Diretório: $INSTALL_DIR"
    echo ""
    
    # Verificações
    check_root
    check_os
    check_docker
    check_permissions
    check_disk_space
    check_dependencies
    
    echo ""
    log_info "Todas as verificações passaram. Iniciando instalação..."
    echo ""
    
    # Instalação
    create_directories
    download_system
    setup_permissions
    create_symlinks
    configure_system
    
    echo ""
    log_info "Instalação concluída. Testando sistema..."
    echo ""
    
    # Teste
    test_installation
    
    # Informações finais
    show_post_install_info
    
    # Remover trap
    trap - ERR
}

# Verificar argumentos
case "${1:-}" in
    --help|-h)
        echo "Uso: $0 [OPÇÕES]"
        echo ""
        echo "OPÇÕES:"
        echo "  --help, -h     Mostrar esta ajuda"
        echo "  --version, -v  Mostrar versão"
        echo ""
        echo "EXEMPLO:"
        echo "  $0              # Instalação normal"
        echo "  curl -sSL $REPO_URL/raw/main/install.sh | bash"
        exit 0
        ;;
    --version|-v)
        echo "BlueAI Docker Ops - Instalador v$CURRENT_VERSION"
        exit 0
        ;;
    "")
        # Instalação normal
        ;;
    *)
        log_error "Opção desconhecida: $1"
        log_info "Use --help para ver as opções disponíveis"
        exit 1
        ;;
esac

# Executar instalação
main "$@"
