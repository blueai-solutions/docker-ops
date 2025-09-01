# =============================================================================
# CONFIGURAÇÃO DE BACKUP DINÂMICO - GERADA AUTOMATICAMENTE
# =============================================================================
# Data de geração: Sex 29 Ago 2025 20:25:00 -03
# Use: ./blueai-docker-ops.sh config containers para modificar

# Diretório de backup
BACKUP_DIR="/Users/alexandregomes/Projetos/pessoais/BlueAI Solutions/BlueAI Docker Ops/backend/backups"

# Configurações de retenção
BACKUP_RETENTION_DAYS=7
BACKUP_MAX_SIZE_GB=10
BACKUP_COMPRESSION=true
BACKUP_PARALLEL=false

# Containers configurados para backup
# Formato: container:volume:priority:stop_before_backup
BACKUP_TARGETS=(
    "postgres-local:/var/lib/docker/volumes/postgres-local-data/_data:1:true"
    "mongo-local:/var/lib/docker/volumes/mongo-local-data/_data:1:true"
    "rabbit-local:/var/lib/docker/volumes/rabbit-local-data/_data:2:true"
    "redis-local:/var/lib/docker/volumes/redis-local-data/_data:2:true"
    "mysql:/var/lib/docker/volumes/rd-adobe-commerce_mysql_data/_data:1:true"
)

# Configurações de notificação por container
BACKUP_NOTIFICATIONS=(
    "postgres-local:true"
    "mongo-local:true"
    "rabbit-local:true"
    "redis-local:true"
    "mysql:true"
)

# Configurações de log por container
BACKUP_LOG_LEVELS=(
    "postgres-local:1"
    "mongo-local:1"
    "rabbit-local:1"
    "redis-local:1"
    "mysql:1"
)

# Configurações de timeout por container
BACKUP_TIMEOUTS=(
    "postgres-local:300"
    "mongo-local:300"
    "rabbit-local:300"
    "redis-local:300"
    "mysql:300"
)

# Configurações de compressão por container
BACKUP_COMPRESSION_LEVELS=(
    "postgres-local:6"
    "mongo-local:6"
    "rabbit-local:6"
    "redis-local:6"
    "mysql:6"
)

# Configurações avançadas
BACKUP_PRE_CHECK=true
BACKUP_INTEGRITY_CHECK=true
BACKUP_SECURITY_CHECK=true
