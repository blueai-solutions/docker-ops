# 🚀 Guia de Início Rápido - Sistema de Backup Docker

Este guia irá ajudá-lo a configurar e usar o sistema de backup e recuperação Docker em poucos minutos.

## 📋 Pré-requisitos

- ✅ **Docker** instalado e funcionando
- ✅ **macOS** (para notificações nativas)
- ✅ **Bash** (já incluído no macOS)
- ✅ **Permissões** de escrita no diretório do projeto

## 🎯 Configuração em 5 Passos

### **Passo 1: Verificar o Sistema**

```bash
cd /Users/alexandregomes/Projetos/pessoais/BlueAI\ Solutions/BlueAI\ Docker\ Recover/backend

# Verificar se tudo está funcionando
./blueai-docker-ops.sh --help
```

### **Passo 2: Configurar Containers para Backup**

```bash
# Abrir configurador interativo
./blueai-docker-ops.sh config containers
```

**O que fazer:**
1. ✅ **Selecionar** containers que deseja fazer backup
2. ⚙️ **Configurar** prioridades (1=alta, 2=média, 3=baixa)
3. 🔧 **Definir** comportamento (parar antes do backup ou não)
4. 💾 **Salvar** configuração

### **Passo 3: Configurar Recuperação**

```bash
# Configurar containers para recuperação
./blueai-docker-ops.sh recovery config
```

**O que fazer:**
1. ✅ **Selecionar** containers para recuperação
2. ⏱️ **Definir** timeouts de espera
3. 🏥 **Configurar** health checks
4. 🌐 **Escolher** redes (padrão: bridge)
5. 💾 **Salvar** configuração

### **Passo 4: Configurar Notificações**

```bash
# Editar configurações de notificação
./blueai-docker-ops.sh config edit
```

**Configurações importantes:**
```bash
# Habilitar notificações
NOTIFICATIONS_ENABLED=true

# Notificações macOS
MACOS_NOTIFICATIONS_ENABLED=true

# Email (opcional)
EMAIL_ENABLED=true
EMAIL_TO="seu-email@exemplo.com"  # ⚠️ ALTERE PARA SEU EMAIL!

# Som das notificações
NOTIFICATION_SOUND="Glass"
```

### **Passo 5: Testar o Sistema**

```bash
# Testar notificações
./blueai-docker-ops.sh notify-test

# Validar configurações
./blueai-docker-ops.sh validate

# Teste completo do sistema
./scripts/utils/test-system.sh
```

## 🚀 Primeiro Backup

### **Executar Backup Manual**

```bash
# Fazer backup de todos os containers configurados
./blueai-docker-ops.sh backup

# Ver status dos containers
./blueai-docker-ops.sh status

# Verificar logs
./blueai-docker-ops.sh logs --last-24h
```

### **Verificar Resultados**

```bash
# Listar backups criados
ls -la backups/

# Ver relatório HTML
./blueai-docker-ops.sh report html

# Abrir relatório no navegador
open reports/backup_report_*.html
```

## 🔄 Primeira Recuperação

### **Simular Perda de Containers**

```bash
# Parar containers (simular perda)
docker stop $(docker ps -q)

# Verificar que estão parados
./blueai-docker-ops.sh status
```

### **Recuperar Containers**

```bash
# Recuperar todos os containers configurados
./blueai-docker-ops.sh recover

# Verificar status
./blueai-docker-ops.sh status

# Ver logs de recuperação
./blueai-docker-ops.sh logs --errors
```

## 📊 Monitoramento Diário

### **Comandos Úteis**

```bash
# Ver status atual
./blueai-docker-ops.sh status

# Monitorar logs em tempo real
./blueai-docker-ops.sh monitor

# Análise de performance
./blueai-docker-ops.sh logs --performance

# Ver containers configurados
./blueai-docker-ops.sh recovery list
```

### **Relatórios Automáticos**

```bash
# Gerar relatório HTML
./blueai-docker-ops.sh report html

# Relatório de texto
./blueai-docker-ops.sh report text

# Exportar dados
./blueai-docker-ops.sh report export
```

## 🔄 Automação

### **LaunchAgent (macOS)**

```bash
# Instalar automação
./blueai-docker-ops.sh automação install

# Verificar status
./blueai-docker-ops.sh automação status

# Desinstalar automação
./blueai-docker-ops.sh automação uninstall

# Testar automação
./blueai-docker-ops.sh automação test
```

**O LaunchAgent irá:**
- 🔄 **Executar backups** automaticamente
- 🔔 **Enviar notificações** sobre o status
- 📊 **Gerar relatórios** periódicos
- 🧹 **Limpar logs** antigos

### **Cron Jobs (Alternativa)**

```bash
# Adicionar ao crontab
crontab -e

# Backup diário às 2h da manhã
0 2 * * * /Users/alexandregomes/Projetos/pessoais/BlueAI\ Solutions/BlueAI\ Docker\ Recover/backend/blueai-docker-ops.sh backup

# Verificação de status a cada 6 horas
0 */6 * * * /Users/alexandregomes/Projetos/pessoais/BlueAI\ Solutions/BlueAI\ Docker\ Recover/backend/blueai-docker-ops.sh status
```

## 🛠️ Configuração Avançada

### **Gerenciar Backups de Configuração**

```bash
# Listar backups de configuração
./blueai-docker-ops.sh config backups list

# Restaurar configuração anterior
./blueai-docker-ops.sh config backups restore backup-config.sh.backup.20250829_190021

# Limpar backups antigos
./scripts/utils/cleanup-deprecated.sh --remove
```

### **Personalizar Configurações**

```bash
# Editar configuração de backup
nano config/backup-config.sh

# Editar configuração de recuperação
nano config/recovery-config.sh

# Editar notificações
nano config/notification-config.sh
```

## 🚨 Situações de Emergência

### **Recuperação Rápida**

```bash
# 1. Recuperar containers
./blueai-docker-ops.sh recover

# 2. Verificar status
./blueai-docker-ops.sh status

# 3. Ver logs de erro
./blueai-docker-ops.sh logs --errors

# 4. Se necessário, restaurar de backup
./blueai-docker-ops.sh backup list
./blueai-docker-ops.sh backup restore [arquivo]
```

### **Backup de Emergência**

```bash
# Fazer backup imediato
./blueai-docker-ops.sh backup

# Verificar se foi criado
ls -la backups/

# Gerar relatório
./blueai-docker-ops.sh report html
```

## 🧪 Testes e Validação

### **Teste Completo**

```bash
# Executar todos os testes
./scripts/utils/test-system.sh
```

### **Testes Específicos**

```bash
# Testar notificações
./blueai-docker-ops.sh notify-test

# Validar configurações
./blueai-docker-ops.sh validate

# Testar backup dinâmico
./blueai-docker-ops.sh dynamic validate
```

## 📚 Próximos Passos

### **Documentação Completa**

- 📖 **[Comandos Detalhados](comandos.md)** - Referência completa
- 🏗️ **[Arquitetura do Sistema](arquitetura.md)** - Visão técnica
- 🔧 **[Solução de Problemas](solucao-problemas.md)** - Troubleshooting

### **Funcionalidades Avançadas**

- 🔄 **Backup incremental** - Em desenvolvimento
- 🌐 **Backup remoto** - Para servidores externos
- 🔐 **Criptografia** - Para backups sensíveis
- 📱 **App móvel** - Para monitoramento remoto

## 🆘 Suporte

### **Problemas Comuns**

1. **Docker não está rodando**
   ```bash
   docker info
   # Iniciar Docker Desktop se necessário
   ```

2. **Permissões negadas**
   ```bash
   chmod +x blueai-docker-ops.sh
   chmod +x scripts/*/*.sh
   ```

3. **Containers não aparecem**
   ```bash
   ./blueai-docker-ops.sh config containers
   # Reconfigurar containers
   ```

### **Logs e Debug**

```bash
# Ver logs detalhados
./blueai-docker-ops.sh logs --last-24h

# Apenas erros
./blueai-docker-ops.sh logs --errors

# Performance
./blueai-docker-ops.sh logs --performance
```

---

**🎉 Parabéns! Seu sistema está configurado e pronto para uso!**

Para mais informações, consulte a [documentação completa](../README.md).
