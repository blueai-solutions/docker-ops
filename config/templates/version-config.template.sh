# =============================================================================
# CONFIGURAÇÃO DE VERSÃO DO BLUEAI DOCKER OPS - TEMPLATE
# =============================================================================
# Este é um template. Copie para config/version-config.sh e configure conforme necessário.

# Versão principal da aplicação
APP_VERSION="2.4.0"

# Informações de build (preenchidas automaticamente)
BUILD_DATE="$(date +%Y-%m-%d)"
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

# Configurações de atualização
UPDATE_CHECK_ENABLED=true
UPDATE_CHECK_URL="https://api.github.com/repos/blueai-solutions/docker-ops/releases/latest"
UPDATE_CHECK_INTERVAL=86400  # 24 horas

# Configurações de compatibilidade
BACKWARD_COMPATIBILITY=true
CONFIG_MIGRATION_ENABLED=true

# Configurações de agendamento (LaunchAgent)
# Configure conforme seu horário preferido
SCHEDULE_HOUR=2
SCHEDULE_MINUTE=0
SCHEDULE_DESCRIPTION="2:00 da manhã"

# =============================================================================
# INSTRUÇÕES DE CONFIGURAÇÃO
# =============================================================================

# 1. Copie este arquivo para config/version-config.sh
#    cp config/templates/version-config.template.sh config/version-config.sh

# 2. Configure o horário do backup conforme sua preferência:
#    SCHEDULE_HOUR=2    # 0-23 (hora)
#    SCHEDULE_MINUTE=0  # 0-59 (minuto)

# 3. O sistema preencherá automaticamente:
#    - BUILD_DATE: Data atual
#    - BUILD_COMMIT: Hash do commit atual
#    - BUILD_BRANCH: Branch atual

# 4. Para personalizar mais configurações, edite o arquivo config/version-config.sh
