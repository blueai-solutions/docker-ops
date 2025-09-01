# =============================================================================
# CONFIGURAÇÃO DE RECUPERAÇÃO DINÂMICA - GERADA AUTOMATICAMENTE
# =============================================================================
# Data de geração: Sex 29 Ago 2025 13:20:13 -03
# Use: ./blueai-docker-ops.sh recovery config para modificar

# Diretório de backups
BACKUP_DIR="/Users/alexandregomes/Projetos/pessoais/BlueAI Solutions/BlueAI Docker Ops/backend/backups"

# Configurações de recuperação
RECOVERY_PARALLEL=false
RECOVERY_RETRY_ATTEMPTS=3
RECOVERY_RETRY_DELAY=5

# Containers configurados para recuperação
# Formato: container:volume:priority:timeout:health_check:service_type
RECOVERY_TARGETS=(
    "postgres-local:/var/lib/docker/volumes/postgres-local-data/_data:1:30:true:postgres"
    "mongo-local:/var/lib/docker/volumes/mongo-local-data/_data:1:30:true:mongo"
    "rabbit-local:/var/lib/docker/volumes/rabbit-local-data/_data:1:30:true:rabbitmq"
    "redis-local:/var/lib/docker/volumes/redis-local-data/_data:1:30:true:redis"
)

# Configurações de notificação por container
RECOVERY_NOTIFICATIONS=(
    "postgres-local:true"
    "mongo-local:true"
    "rabbit-local:true"
)

# Configurações de log por container
RECOVERY_LOG_LEVELS=(
    "postgres-local:1"
    "mongo-local:1"
    "rabbit-local:1"
)

# Configurações de rede por container
RECOVERY_NETWORKS=(
    "postgres-local:bridge"
    "mongo-local:bridge"
    "rabbit-local:bridge"
)

# Configurações avançadas
RECOVERY_PRE_CHECK=true
RECOVERY_INTEGRITY_CHECK=true
RECOVERY_SECURITY_CHECK=true
RECOVERY_CLEANUP_OLD_CONTAINERS=false
