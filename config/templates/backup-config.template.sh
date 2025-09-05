# =============================================================================
# CONFIGURAÇÃO DE BACKUP DINÂMICO - TEMPLATE
# =============================================================================
# Este é um template. Copie para config/backup-config.sh e configure conforme necessário.
# Use: ./blueai-docker-ops.sh config para modificar

# Diretório de backup (configure conforme seu ambiente)
BACKUP_DIR="$HOME/BlueAI-Docker-Backups"

# Configurações de retenção
BACKUP_RETENTION_DAYS=7
BACKUP_MAX_SIZE_GB=10
BACKUP_COMPRESSION=true
BACKUP_PARALLEL=false

# Containers configurados para backup
# Formato: container:volume:priority:stop_before_backup
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
BACKUP_TARGETS=(
    # Exemplo: "nome-container:/caminho/volume:prioridade:parar_antes_backup"
    # "postgres:/var/lib/docker/volumes/postgres-data/_data:1:true"
    # "mysql:/var/lib/docker/volumes/mysql-data/_data:1:true"
    # "redis:/var/lib/docker/volumes/redis-data/_data:2:false"
)

# Configurações de notificação por container
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
BACKUP_NOTIFICATIONS=(
    # Exemplo: "nome-container:habilitado"
    # "postgres:true"
    # "mysql:true"
    # "redis:false"
)

# Configurações de log por container
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
BACKUP_LOG_LEVELS=(
    # Exemplo: "nome-container:nivel_log"
    # "postgres:1"
    # "mysql:1"
    # "redis:2"
)

# Configurações de timeout por container (em segundos)
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
BACKUP_TIMEOUTS=(
    # Exemplo: "nome-container:timeout_segundos"
    # "postgres:300"
    # "mysql:300"
    # "redis:120"
)

# Configurações de compressão por container (1-9, 9=maior compressão)
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
BACKUP_COMPRESSION_LEVELS=(
    # Exemplo: "nome-container:nivel_compressao"
    # "postgres:6"
    # "mysql:6"
    # "redis:4"
)

# Configurações avançadas
BACKUP_PRE_CHECK=true
BACKUP_INTEGRITY_CHECK=true
BACKUP_SECURITY_CHECK=true
BACKUP_CHECK_DOCKER=true
BACKUP_CHECK_DISK_SPACE=true
BACKUP_MIN_DISK_SPACE_GB=5
BACKUP_VERIFY_INTEGRITY=true

# =============================================================================
# INSTRUÇÕES DE CONFIGURAÇÃO
# =============================================================================

# 1. Copie este arquivo para config/backup-config.sh
#    cp config/templates/backup-config.template.sh config/backup-config.sh

# 2. Configure o diretório de backup:
#    BACKUP_DIR="/caminho/para/seu/backup"

# 3. Configure seus containers:
#    - Use o comando: ./blueai-docker-ops.sh config
#    - Ou edite manualmente o arquivo

# 4. Para descobrir volumes Docker:
#    docker volume ls
#    docker volume inspect nome-volume

# 5. Para descobrir containers:
#    docker ps -a
#    docker inspect nome-container

# 6. Teste a configuração:
#    ./blueai-docker-ops.sh backup --dry-run
