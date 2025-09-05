# =============================================================================
# CONFIGURAÇÃO DE RECUPERAÇÃO DINÂMICA - TEMPLATE
# =============================================================================
# Este é um template. Copie para config/recovery-config.sh e configure conforme necessário.
# Use: ./blueai-docker-ops.sh config para modificar

# Diretório de backups (configure conforme seu ambiente)
BACKUP_DIR="./backups"

# Configurações de recuperação
RECOVERY_PARALLEL=false
RECOVERY_RETRY_ATTEMPTS=3
RECOVERY_RETRY_DELAY=5

# Containers configurados para recuperação
# Formato: container:volume:priority:timeout:health_check:service_type
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
RECOVERY_TARGETS=(
    # Exemplo: "nome-container:/caminho/volume:prioridade:timeout:verificar_saude:tipo_servico"
    # "postgres:/var/lib/docker/volumes/postgres-data/_data:1:30:true:postgres"
    # "mysql:/var/lib/docker/volumes/mysql-data/_data:1:30:true:mysql"
    # "redis:/var/lib/docker/volumes/redis-data/_data:2:15:false:redis"
)

# Configurações de notificação por container
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
RECOVERY_NOTIFICATIONS=(
    # Exemplo: "nome-container:habilitado"
    # "postgres:true"
    # "mysql:true"
    # "redis:false"
)

# Configurações de log por container
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
RECOVERY_LOG_LEVELS=(
    # Exemplo: "nome-container:nivel_log"
    # "postgres:1"
    # "mysql:1"
    # "redis:2"
)

# Configurações de rede por container
# ⚠️  CONFIGURE CONFORME SEUS CONTAINERS!
RECOVERY_NETWORKS=(
    # Exemplo: "nome-container:rede"
    # "postgres:bridge"
    # "mysql:bridge"
    # "redis:host"
)

# Configurações avançadas
RECOVERY_PRE_CHECK=true
RECOVERY_INTEGRITY_CHECK=true
RECOVERY_SECURITY_CHECK=true
RECOVERY_CLEANUP_OLD_CONTAINERS=false

# =============================================================================
# INSTRUÇÕES DE CONFIGURAÇÃO
# =============================================================================

# 1. Copie este arquivo para config/recovery-config.sh
#    cp config/templates/recovery-config.template.sh config/recovery-config.sh

# 2. Configure o diretório de backups:
#    BACKUP_DIR="/caminho/para/seu/backup"

# 3. Configure seus containers:
#    - Use o comando: ./blueai-docker-ops.sh config
#    - Ou edite manualmente o arquivo

# 4. Para descobrir redes Docker:
#    docker network ls
#    docker network inspect nome-rede

# 5. Para descobrir containers:
#    docker ps -a
#    docker inspect nome-container

# 6. Teste a configuração:
#    ./blueai-docker-ops.sh recovery --dry-run

# 7. Tipos de serviço suportados:
#    - postgres, mysql, mongo, redis, rabbitmq, nginx, apache
#    - ou deixe vazio para detecção automática
