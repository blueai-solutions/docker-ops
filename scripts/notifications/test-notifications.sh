#!/bin/bash

# Script de teste para notificações do Docker Backup
# =================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Carregar configurações
NOTIFICATION_CONFIG="$SCRIPT_DIR/../../config/notification-config.sh"
VERSION_CONFIG="$SCRIPT_DIR/../../config/version-config.sh"

if [ -f "$NOTIFICATION_CONFIG" ]; then
    source "$NOTIFICATION_CONFIG"
else
    echo "❌ Arquivo de configuração não encontrado: $NOTIFICATION_CONFIG"
    exit 1
fi

if [ -f "$VERSION_CONFIG" ]; then
    source "$VERSION_CONFIG"
else
    echo "❌ Arquivo de configuração de versão não encontrado"
    exit 1
fi

echo "🧪 Testando sistema de notificações..."
echo "====================================="
echo "Data: $DATE"
echo ""

# Função para notificação macOS
notify_macos() {
    local message="$1"
    local subtitle="$2"
    local sound="$3"
    
    if [ "$MACOS_NOTIFICATIONS_ENABLED" = true ]; then
        echo "📱 Enviando notificação macOS: $message"
        osascript -e "display notification \"$message\" with title \"$NOTIFICATION_TITLE\" subtitle \"$subtitle\" sound name \"$sound\"" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "  ✅ Notificação macOS enviada com sucesso"
        else
            echo "  ❌ Falha ao enviar notificação macOS"
        fi
    else
        echo "  ⚠️  Notificações macOS desabilitadas"
    fi
}

# Função para enviar email
send_email() {
    local subject="$1"
    local body="$2"
    
    if [ "$EMAIL_ENABLED" = true ] && [ -n "$EMAIL_TO" ]; then
        echo "📧 Enviando email para: $EMAIL_TO"
        local full_subject="$EMAIL_SUBJECT_PREFIX $subject"
        local email_body="
Teste de notificação - Data: $DATE
Script: $SCRIPT_DIR/test-notifications.sh

$body

---
Este é um email de teste do $SYSTEM_NAME.
"
        
        if command -v mail >/dev/null 2>&1; then
            echo "$email_body" | mail -s "$full_subject" "$EMAIL_TO" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "  ✅ Email enviado com sucesso via 'mail'"
            else
                echo "  ❌ Falha ao enviar email via 'mail'"
            fi
        elif command -v sendmail >/dev/null 2>&1; then
            {
                echo "To: $EMAIL_TO"
                echo "From: $EMAIL_FROM"
                echo "Subject: $full_subject"
                echo "Content-Type: text/plain; charset=UTF-8"
                echo ""
                echo "$email_body"
            } | sendmail "$EMAIL_TO" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "  ✅ Email enviado com sucesso via 'sendmail'"
            else
                echo "  ❌ Falha ao enviar email via 'sendmail'"
            fi
        else
            echo "  ❌ Nenhum cliente de email encontrado (mail ou sendmail)"
        fi
    else
        echo "  ⚠️  Email desabilitado ou não configurado"
    fi
}

# Teste 1: Notificação de sucesso
echo "🔵 Teste 1: Notificação de Sucesso"
echo "----------------------------------"
notify_macos "Teste de sucesso" "Sistema funcionando corretamente" "$NOTIFICATION_SOUND"
send_email "TESTE: Sucesso" "✅ Sistema de notificações funcionando corretamente"
echo ""

# Aguardar 2 segundos
sleep 2

# Teste 2: Notificação de aviso
echo "🟡 Teste 2: Notificação de Aviso"
echo "--------------------------------"
notify_macos "Teste de aviso" "Atenção necessária" "Ping"
send_email "TESTE: Aviso" "⚠️  Este é um teste de aviso do sistema"
echo ""

# Aguardar 2 segundos
sleep 2

# Teste 3: Notificação de erro
echo "🔴 Teste 3: Notificação de Erro"
echo "-------------------------------"
notify_macos "Teste de erro" "Problema detectado" "Sosumi"
send_email "TESTE: Erro" "❌ Este é um teste de erro do sistema"
echo ""

# Teste 4: Verificar configurações
echo "⚙️  Configurações Atuais"
echo "-----------------------"
echo "Notificações habilitadas: $NOTIFICATIONS_ENABLED"
echo "Email habilitado: $EMAIL_ENABLED"
echo "Email de destino: $EMAIL_TO"
echo "Notificações macOS habilitadas: $MACOS_NOTIFICATIONS_ENABLED"
echo "Som das notificações: $NOTIFICATION_SOUND"
echo ""

# Teste 5: Verificar dependências
echo "🔧 Verificação de Dependências"
echo "-----------------------------"
if command -v osascript >/dev/null 2>&1; then
    echo "✅ osascript disponível (notificações macOS)"
else
    echo "❌ osascript não encontrado"
fi

if command -v mail >/dev/null 2>&1; then
    echo "✅ mail disponível (cliente de email)"
else
    echo "⚠️  mail não encontrado"
fi

if command -v sendmail >/dev/null 2>&1; then
    echo "✅ sendmail disponível (cliente de email)"
else
    echo "⚠️  sendmail não encontrado"
fi
echo ""

echo "🎉 Teste de notificações concluído!"
echo "==================================="
echo ""
echo "📋 Próximos passos:"
echo "1. Verifique se recebeu as notificações do macOS"
echo "2. Verifique se recebeu os emails de teste"
echo "3. Configure seu email em config/notification-config.sh se necessário"
echo "4. Execute ./blueai-docker-ops.sh backup para testar o sistema completo"
