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

# Função para notificação macOS com múltiplos métodos
notify_macos() {
    local message="$1"
    local subtitle="$2"
    local sound="$3"
    
    if [ "$MACOS_NOTIFICATIONS_ENABLED" = true ]; then
        echo "📱 Enviando notificação macOS: $message"
        
        # Método 1: display notification (padrão)
        osascript -e "display notification \"$message\" with title \"$NOTIFICATION_TITLE\" subtitle \"$subtitle\" sound name \"$sound\"" 2>/dev/null
        local result1=$?
        
        # Método 2: System Events (alternativo)
        osascript -e "tell application \"System Events\" to display notification \"$message\" with title \"$NOTIFICATION_TITLE\" subtitle \"$subtitle\" sound name \"$sound\"" 2>/dev/null
        local result2=$?
        
        # Método 3: Terminal bell (som apenas)
        if [ -n "$sound" ]; then
            echo -e "\a"  # Terminal bell
        fi
        
        # Feedback visual
        if [ $result1 -eq 0 ] || [ $result2 -eq 0 ]; then
            echo "  ✅ Notificação macOS enviada com sucesso"
            echo "  🔊 Som reproduzido (se habilitado)"
        else
            echo "  ❌ Falha ao enviar notificação macOS"
            echo "  💡 Dica: Verifique configurações de notificação do macOS"
            echo "     - Preferências do Sistema > Notificações > Terminal/iTerm2"
            echo "     - Desative modo 'Não Perturbe' se ativo"
        fi
        
        # Feedback visual adicional
        echo "  👀 Verifique se a notificação apareceu na tela"
        echo "  📍 Localização: Canto superior direito da tela"
        
    else
        echo "  ⚠️  Notificações macOS desabilitadas"
    fi
}

# Função para enviar email com verificação
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
        
        local email_sent=false
        
        # Método 1: mail
        if command -v mail >/dev/null 2>&1; then
            echo "$email_body" | mail -s "$full_subject" "$EMAIL_TO" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "  ✅ Email enviado com sucesso via 'mail'"
                email_sent=true
            else
                echo "  ❌ Falha ao enviar email via 'mail'"
            fi
        fi
        
        # Método 2: sendmail (se mail falhou)
        if [ "$email_sent" = false ] && command -v sendmail >/dev/null 2>&1; then
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
                email_sent=true
            else
                echo "  ❌ Falha ao enviar email via 'sendmail'"
            fi
        fi
        
        if [ "$email_sent" = false ]; then
            echo "  ❌ Nenhum método de email funcionou"
            echo "  💡 Dica: Configure uma conta de email no macOS"
            echo "     - Preferências do Sistema > Internet Accounts"
        else
            echo "  📬 Verifique sua caixa de entrada (e spam)"
            echo "  🔍 Assunto: $full_subject"
        fi
        
    else
        echo "  ⚠️  Email desabilitado ou não configurado"
    fi
}

# Função para notificação visual no terminal
notify_terminal() {
    local message="$1"
    local type="$2"
    
    case "$type" in
        "success")
            echo -e "\n🎉 \033[32m$message\033[0m 🎉\n"
            ;;
        "warning")
            echo -e "\n⚠️  \033[33m$message\033[0m ⚠️\n"
            ;;
        "error")
            echo -e "\n❌ \033[31m$message\033[0m ❌\n"
            ;;
        *)
            echo -e "\n📢 $message\n"
            ;;
    esac
}

# Teste 1: Notificação de sucesso
echo "🔵 Teste 1: Notificação de Sucesso"
echo "----------------------------------"
notify_macos "Teste de sucesso" "Sistema funcionando corretamente" "$NOTIFICATION_SOUND"
send_email "TESTE: Sucesso" "✅ Sistema de notificações funcionando corretamente"
notify_terminal "Teste de sucesso concluído!" "success"
echo ""

# Aguardar 3 segundos
sleep 3

# Teste 2: Notificação de aviso
echo "🟡 Teste 2: Notificação de Aviso"
echo "--------------------------------"
notify_macos "Teste de aviso" "Atenção necessária" "Ping"
send_email "TESTE: Aviso" "⚠️  Este é um teste de aviso do sistema"
notify_terminal "Teste de aviso concluído!" "warning"
echo ""

# Aguardar 3 segundos
sleep 3

# Teste 3: Notificação de erro
echo "🔴 Teste 3: Notificação de Erro"
echo "-------------------------------"
notify_macos "Teste de erro" "Problema detectado" "Sosumi"
send_email "TESTE: Erro" "❌ Este é um teste de erro do sistema"
notify_terminal "Teste de erro concluído!" "error"
echo ""

# Aguardar 3 segundos
sleep 3

# Resumo dos testes
echo "⚙️  Configurações Atuais"
echo "-----------------------"
echo "Notificações habilitadas: $NOTIFICATIONS_ENABLED"
echo "Email habilitado: $EMAIL_ENABLED"
echo "Email de destino: $EMAIL_TO"
echo "Notificações macOS habilitadas: $MACOS_NOTIFICATIONS_ENABLED"
echo "Som das notificações: $NOTIFICATION_SOUND"
echo ""

# Verificação de dependências
echo "🔧 Verificação de Dependências"
echo "----------------------------"
if command -v osascript >/dev/null 2>&1; then
    echo "✅ osascript disponível (notificações macOS)"
else
    echo "❌ osascript não encontrado"
fi

if command -v mail >/dev/null 2>&1; then
    echo "✅ mail disponível (cliente de email)"
else
    echo "❌ mail não encontrado"
fi

if command -v sendmail >/dev/null 2>&1; then
    echo "✅ sendmail disponível (cliente de email)"
else
    echo "❌ sendmail não encontrado"
fi
echo ""

# Instruções de solução de problemas
echo "🎉 Teste de notificações concluído!"
echo "==================================="
echo ""
echo "📋 Se você NÃO recebeu as notificações:"
echo ""
echo "📱 Para notificações macOS:"
echo "   1. Vá em Preferências do Sistema > Notificações"
echo "   2. Procure por 'Terminal' ou 'iTerm2'"
echo "   3. Habilite as notificações"
echo "   4. Desative modo 'Não Perturbe' se ativo"
echo "   5. Verifique se o som do sistema não está mudo"
echo ""
echo "📧 Para emails:"
echo "   1. Configure uma conta de email no macOS"
echo "   2. Vá em Preferências do Sistema > Internet Accounts"
echo "   3. Adicione sua conta de email"
echo "   4. Verifique a pasta de spam"
echo ""
echo "🔧 Para testar o sistema completo:"
echo "   ./blueai-docker-ops.sh backup"
echo ""
echo "💡 Dica: As notificações visuais no terminal sempre funcionam!"
