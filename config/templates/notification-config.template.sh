#!/bin/bash

# =============================================================================
# CONFIGURAÇÃO DE NOTIFICAÇÕES - TEMPLATE
# =============================================================================
# Este é um template. Copie para config/notification-config.sh e configure conforme necessário.

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
# ⚠️  ALTERE PARA SEU EMAIL!
EMAIL_TO="seu-email@exemplo.com"

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

# =============================================================================
# INSTRUÇÕES DE CONFIGURAÇÃO
# =============================================================================

# 1. Copie este arquivo para config/notification-config.sh
#    cp config/templates/notification-config.template.sh config/notification-config.sh

# 2. Configure seu email:
#    EMAIL_TO="seu-email@exemplo.com"

# 3. Para receber emails:
#    - Certifique-se de que o sistema tem acesso a um servidor SMTP
#    - Teste com: echo "teste" | mail -s "teste" seu-email@exemplo.com

# 4. Para notificações macOS:
#    - Certifique-se de que as notificações estão habilitadas no Sistema
#    - Vá em Preferências do Sistema > Notificações > Terminal (ou iTerm2)

# 5. Para personalizar sons:
#    - Glass: Som suave de vidro
#    - Ping: Som de notificação padrão
#    - Sosumi: Som de alerta
#    - Deixe vazio para sem som

# 6. Para testar as notificações:
#    - Execute: ./blueai-docker-ops.sh backup
#    - Ou teste individualmente:
#      osascript -e 'display notification "Teste" with title "Docker Backup"'
