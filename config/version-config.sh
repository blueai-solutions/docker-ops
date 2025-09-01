# =============================================================================
# CONFIGURAÇÃO DE VERSÃO DO BLUEAI DOCKER OPS
# =============================================================================

# Versão principal da aplicação
APP_VERSION="2.3.1"

# Informações de build
BUILD_DATE="2025-08-29"
BUILD_COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
BUILD_BRANCH="$(git branch --show-current 2>/dev/null || echo 'unknown')"

# Informações do sistema
SYSTEM_NAME="BlueAI Docker Ops"
SYSTEM_DESCRIPTION="Sistema automatizado de backup para containers Docker"
SYSTEM_AUTHOR="BlueAI Solutions"
SYSTEM_LICENSE="MIT"

# Compatibilidade
MIN_DOCKER_VERSION="20.10.0"
MIN_MACOS_VERSION="10.15.0"
SUPPORTED_SHELLS=("bash" "zsh")

# Nota: Changelogs agora são gerenciados em arquivos separados em docs/changelog/
# Use: ./blueai-docker-ops.sh changelog-manager para gerenciar changelogs

# Configurações de atualização
UPDATE_CHECK_ENABLED=true
UPDATE_CHECK_URL="https://api.github.com/repos/user/docker-backup/releases/latest"
UPDATE_CHECK_INTERVAL=86400  # 24 horas

# Configurações de compatibilidade
BACKWARD_COMPATIBILITY=true
CONFIG_MIGRATION_ENABLED=true
