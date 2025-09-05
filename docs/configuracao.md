# 🔧 Configuração - BlueAI Docker Ops

Guia completo de configuração do sistema simplificado.

## ⚠️ IMPORTANTE

**Este é um pacote de distribuição limpo que NÃO contém configurações específicas do ambiente local.**

## 📋 Configuração Inicial

### **1. Configuração Automática (Recomendado)**
```bash
# Configuração completa em uma linha
make setup

# OU usar o script diretamente
./blueai-docker-ops.sh setup
```

**O que acontece automaticamente:**
1. ✅ **Configuração interativa** - Email e horário do backup
2. 🕐 **Agendamento automático** - LaunchAgent instalado
3. 🔧 **Instalação do sistema** - Comandos disponíveis no PATH

### **2. Configuração Interativa**
```bash
# Configuração interativa
./blueai-docker-ops.sh config

# Configurar agendamento
./blueai-docker-ops.sh schedule
```

### **3. Configuração Manual (Avançado)**
```bash
# Copiar templates para configurações
cp config/templates/version-config.template.sh config/version-config.sh
cp config/templates/notification-config.template.sh config/notification-config.sh
cp config/templates/backup-config.template.sh config/backup-config.sh
cp config/templates/recovery-config.template.sh config/recovery-config.sh

# Editar configurações conforme necessário
nano config/version-config.sh
nano config/notification-config.sh
nano config/backup-config.sh
nano config/recovery-config.sh
```

## 📁 Estrutura de Configuração

### **Templates de Configuração** ✅
> **Nota:** Estes arquivos são versionados no Git e servem como base para configuração inicial.

```
config/
├── templates/                    # Templates limpos (versionados)
│   ├── version-config.template.sh
│   ├── notification-config.template.sh
│   ├── backup-config.template.sh
│   └── recovery-config.template.sh
└── backups/                      # Backups automáticos
```

### **Arquivos de Configuração Local** ⚠️
> **Nota:** Estes arquivos contêm configurações específicas da máquina local e **NÃO são versionados** no Git.

```
config/
├── version-config.sh             # Configuração de versão (local)
├── notification-config.sh        # Configuração de notificações (local)
├── backup-config.sh              # Configuração de backup (local)
└── recovery-config.sh            # Configuração de recovery (local)
```

## 🎯 O que o sistema de configuração faz

### **Setup Automático (`make setup`)**
- ✅ **Configuração interativa** completa
- ✅ **Criação automática** de configurações usando templates
- ✅ **Backup automático** das configurações existentes
- ✅ **Configuração de email** para notificações
- ✅ **Configuração de horário** para backup automático
- ✅ **Instalação de LaunchAgent** com agendamento
- ✅ **Instalação do sistema** com comandos no PATH

### **Configuração Interativa (`./blueai-docker-ops.sh config`)**
- ✅ **Solicitação de email** para notificações
- ✅ **Configuração de horário** para backup automático
- ✅ **Criação de configurações** personalizadas
- ✅ **Validação automática** de parâmetros
- ✅ **Backup de configurações** existentes

### **Agendamento (`./blueai-docker-ops.sh schedule`)**
- ✅ **Configuração de horário** para backup automático
- ✅ **Instalação de LaunchAgent** com horário configurado
- ✅ **Sincronização** entre configuração e agendamento
- ✅ **Validação** de horários (0-23h, 0-59min)

## 📧 Configurações Disponíveis

### **Versão e Sistema (`version-config.sh`)**
```bash
# Informações do sistema
SYSTEM_NAME="BlueAI Docker Ops"
SYSTEM_VERSION="2.4.0"
SYSTEM_AUTHOR="BlueAI Solutions"
SYSTEM_DESCRIPTION="Sistema de backup e recuperação Docker"

# Configurações de agendamento
SCHEDULE_HOUR=2          # Hora do backup (0-23)
SCHEDULE_MINUTE=30       # Minuto do backup (0-59)
SCHEDULE_DESCRIPTION="2:30 da manhã"

# URLs de atualização
GITHUB_REPO="https://github.com/blueai-solutions/docker-ops"
UPDATE_URL="https://api.github.com/repos/blueai-solutions/docker-ops/releases/latest"
```

### **Notificações (`notification-config.sh`)**
```bash
# Configurações gerais
NOTIFICATIONS_ENABLED=true
LOG_LEVEL=1              # 0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR

# Email
EMAIL_ENABLED=true
EMAIL_TO="seu-email@exemplo.com"
EMAIL_FROM="docker-ops@blueaisolutions.com.br"
EMAIL_SUBJECT_PREFIX="[Docker Backup]"

# macOS
MACOS_NOTIFICATIONS_ENABLED=true
NOTIFICATION_TITLE="Docker Backup"
NOTIFICATION_SOUND="Glass"
NOTIFICATION_TIMEOUT=10
```

### **Backup (`backup-config.sh`)**
```bash
# Configurações gerais
BACKUP_ENABLED=true
BACKUP_DIR="backups"
BACKUP_RETENTION_DAYS=30

# Containers para backup
CONTAINERS_TO_BACKUP=(
    "mongo-local-data"
    "postgres-local-data"
    "redis-local-data"
)

# Configurações por container
CONTAINER_CONFIGS=(
    "mongo-local-data:1:true"      # nome:prioridade:parar_antes
    "postgres-local-data:2:false"
    "redis-local-data:3:false"
)
```

### **Recovery (`recovery-config.sh`)**
```bash
# Configurações gerais
RECOVERY_ENABLED=true
RECOVERY_TIMEOUT=300               # 5 minutos
RECOVERY_HEALTH_CHECK=true

# Containers para recovery
CONTAINERS_TO_RECOVER=(
    "mongo-local-data"
    "postgres-local-data"
    "redis-local-data"
)

# Configurações por container
RECOVERY_CONFIGS=(
    "mongo-local-data:27017:bridge:mongodb:latest"
    "postgres-local-data:5432:bridge:postgres:13"
    "redis-local-data:6379:bridge:redis:6"
)
```

## 🚀 Exemplos de Uso

### **Configuração Rápida**
```bash
# Configuração completa em uma linha
make setup

# O sistema irá solicitar:
# 1. Email para notificações
# 2. Horário para backup automático
# 3. Confirmar configurações
```

### **Configuração Personalizada**
```bash
# 1. Configuração inicial
./blueai-docker-ops.sh setup

# 2. Personalizar configurações
nano config/backup-config.sh
nano config/recovery-config.sh

# 3. Reconfigurar se necessário
./blueai-docker-ops.sh config
```

### **Alterar Agendamento**
```bash
# Ver status atual
./blueai-docker-ops.sh status

# Alterar horário
./blueai-docker-ops.sh schedule

# O sistema irá:
# 1. Solicitar novo horário
# 2. Atualizar configuração
# 3. Reinstalar LaunchAgent
# 4. Confirmar alteração
```

## 🔧 Configuração Avançada

### **Editar Configurações Manualmente**
```bash
# Editar configuração de versão
nano config/version-config.sh

# Editar configuração de notificações
nano config/notification-config.sh

# Editar configuração de backup
nano config/backup-config.sh

# Editar configuração de recovery
nano config/recovery-config.sh
```

### **Backup de Configurações**
```bash
# Ver backups disponíveis
ls -la config/backups/

# Restaurar configuração anterior
cp config/backups/backup-config.sh.backup.20250104_120000 config/backup-config.sh

# Reconfigurar sistema
./blueai-docker-ops.sh config
```

### **Validação de Configurações**
```bash
# Testar sistema completo
./blueai-docker-ops.sh test

# Ver status das configurações
./blueai-docker-ops.sh status

# Ver volumes configurados
./blueai-docker-ops.sh volumes
```

## 📊 Monitoramento de Configurações

### **Ver Status das Configurações**
```bash
# Status geral
./blueai-docker-ops.sh status

# Ver configurações atuais
cat config/version-config.sh | grep SCHEDULE
cat config/notification-config.sh | grep EMAIL
cat config/backup-config.sh | grep CONTAINERS
cat config/recovery-config.sh | grep CONTAINERS
```

### **Logs de Configuração**
```bash
# Ver logs do sistema
./blueai-docker-ops.sh logs

# Ver logs específicos
tail -f logs/system.log
tail -f logs/error.log
```

## 🚨 Solução de Problemas

### **Configuração Corrompida**
```bash
# 1. Fazer backup da configuração atual
cp -r config config.backup.$(date +%Y%m%d_%H%M%S)

# 2. Restaurar configuração padrão
./blueai-docker-ops.sh config

# 3. Se não funcionar, reconfigurar tudo
./blueai-docker-ops.sh setup
```

### **Configuração Duplicada**
```bash
# Se sistema pedir horário duas vezes:
# 1. Use apenas: make setup (para primeira configuração)
# 2. Use apenas: ./blueai-docker-ops.sh schedule (para alterar horário)
# 3. Use apenas: ./blueai-docker-ops.sh config (para reconfigurar)
```

### **Permissões de Arquivo**
```bash
# Verificar permissões
ls -la config/*.sh

# Corrigir permissões se necessário
chmod 644 config/*.sh
chmod +x blueai-docker-ops.sh
```

### **Reset e Limpeza de Configurações**

#### **Limpeza Seletiva (Segura)**
```bash
# Limpar apenas dados temporários
./blueai-docker-ops.sh clean-data

# O que é preservado:
# - Configurações de containers
# - Configurações de notificações
# - Configurações de agendamento
# - Estrutura do sistema
```

#### **Reset Completo (PERIGOSO!)**
```bash
# Reset completo de fábrica
./blueai-docker-ops.sh factory-reset

# ⚠️ ATENÇÃO: Apaga TUDO!
# - Todas as configurações
# - Todos os backups
# - Todos os logs
# - Todos os relatórios
```

**📚 Para detalhes completos, consulte [Reset e Limpeza](reset-e-limpeza.md)**

## 📚 Recursos Adicionais

### **Documentação Relacionada**
- **Guia de Início Rápido:** [guia-inicio-rapido.md](guia-inicio-rapido.md)
- **Comandos Detalhados:** [comandos.md](comandos.md)
- **Solução de Problemas:** [solucao-problemas.md](solucao-problemas.md)

### **Comandos de Ajuda**
```bash
# Ajuda principal
./blueai-docker-ops.sh --help

# Comandos avançados
./blueai-docker-ops.sh advanced

# Status detalhado
./blueai-docker-ops.sh status
```

---

**🔧 Sistema de configuração simples e intuitivo para máxima usabilidade!**
