#!/bin/bash

# Configuração de Notificações para Docker Backup
# ================================================
# Este arquivo pode ser editado para personalizar as notificações

# ================================================
# CONFIGURAÇÕES GERAIS
# ================================================

# Habilitar/desabilitar notificações
NOTIFICATIONS_ENABLED=true

# ================================================
# CONFIGURAÇÕES DE EMAIL
# ================================================

# Habilitar/desabilitar envio de email
EMAIL_ENABLED=true

# Email de destino (OBRIGATÓRIO se EMAIL_ENABLED=true)
EMAIL_TO="argomes.dev@gmail.com"  # ⚠️  ALTERE PARA SEU EMAIL!

# Email de origem
EMAIL_FROM="docker-ops@blueaisolutions.com.br"

# Prefixo do assunto dos emails
EMAIL_SUBJECT_PREFIX="[Docker Backup]"

# ================================================
# CONFIGURAÇÕES DE NOTIFICAÇÃO macOS
# ================================================

# Habilitar/desabilitar notificações do macOS
MACOS_NOTIFICATIONS_ENABLED=true

# Título das notificações
NOTIFICATION_TITLE="Docker Backup"

# Som das notificações (opções: Glass, Ping, Sosumi, etc.)
# Para desabilitar som, deixe vazio: NOTIFICATION_SOUND=""
NOTIFICATION_SOUND="Glass"

# ================================================
# CONFIGURAÇÕES AVANÇADAS
# ================================================

# Nível de detalhamento dos logs
LOG_LEVEL="INFO"  # DEBUG, INFO, WARNING, ERROR

# Tempo máximo de espera para notificações (em segundos)
NOTIFICATION_TIMEOUT=10

# ================================================
# INSTRUÇÕES DE CONFIGURAÇÃO
# ================================================

# 1. Para receber emails:
#    - Configure EMAIL_TO com seu email
#    - Certifique-se de que o sistema tem acesso a um servidor SMTP
#    - Teste com: echo "teste" | mail -s "teste" seu-email@exemplo.com

# 2. Para notificações macOS:
#    - Certifique-se de que as notificações estão habilitadas no Sistema
#    - Vá em Preferências do Sistema > Notificações > Terminal (ou iTerm2)

# 3. Para personalizar sons:
#    - Glass: Som suave de vidro
#    - Ping: Som de notificação padrão
#    - Sosumi: Som de alerta
#    - Deixe vazio para sem som

# 4. Para testar as notificações:
#    - Execute: ./blueai-docker-ops.sh backup
#    - Ou teste individualmente:
#      osascript -e 'display notification "Teste" with title "Docker Backup"'
