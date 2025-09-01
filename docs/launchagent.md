# 🚀 LaunchAgent e Sistema de Agendamento - BlueAI Docker Ops

Este documento descreve o sistema de agendamento automático usando macOS LaunchAgent, incluindo todas as funcionalidades avançadas implementadas.

## 📋 Visão Geral

O sistema de agendamento do BlueAI Docker Ops utiliza macOS LaunchAgent para executar backups automáticos no horário configurado, com sincronização inteligente entre arquivos de configuração e o próprio LaunchAgent.

## 🎯 Funcionalidades Principais

### **✅ Agendamento Automático**
- **Execução diária** no horário configurado
- **Horários personalizáveis** (0-23h, 0-59min)
- **Validação inteligente** de entrada de dados
- **Descrição automática** de horários em português

### **✅ Sincronização Inteligente**
- **Sincronização automática** entre `config/version-config.sh` e arquivo `.plist`
- **Recarregamento automático** de configurações após alterações
- **Geração dinâmica** do arquivo `.plist` com horário correto
- **Consistência total** entre todos os arquivos

### **✅ Backup de Segurança**
- **Backup automático** de configurações antes de alterações
- **Histórico preservado** com timestamps únicos
- **Restauração fácil** de configurações anteriores
- **Formato:** `config/version-config.sh.backup.YYYYMMDD_HHMMSS`

### **✅ Teste e Validação**
- **Teste de funcionamento** com execução em 60 segundos
- **Validação de configuração** antes de instalar
- **Verificação de status** em tempo real
- **Logs detalhados** para troubleshooting

## 🛠️ Comandos Disponíveis

### **Instalação e Gerenciamento**

```bash
# Instalar LaunchAgent
./scripts/utils/install-launchagent.sh install

# Verificar status
./scripts/utils/install-launchagent.sh status

# Desinstalar LaunchAgent
./scripts/utils/install-launchagent.sh uninstall

# Iniciar LaunchAgent
./scripts/utils/install-launchagent.sh start

# Parar LaunchAgent
./scripts/utils/install-launchagent.sh stop
```

### **Configuração de Horário**

```bash
# Alterar horário do backup
./scripts/utils/install-launchagent.sh schedule

# Opções disponíveis:
# 1) 01:00 da manhã
# 2) 02:00 da manhã
# 3) 03:00 da manhã
# 4) 04:00 da manhã
# 5) Personalizado (hora e minuto específicos)
```

### **Teste e Validação**

```bash
# Testar LaunchAgent (execução em 60s)
./scripts/utils/install-launchagent.sh test-launchagent

# Testar script de backup
./scripts/utils/install-launchagent.sh test

# Ver logs do LaunchAgent
./scripts/utils/install-launchagent.sh logs

# Ajuda completa
./scripts/utils/install-launchagent.sh help
```

## ⚙️ Configuração

### **Arquivo de Configuração Principal**

```bash
# config/version-config.sh
SCHEDULE_HOUR=17          # Hora (0-23)
SCHEDULE_MINUTE=30        # Minuto (0-59)
SCHEDULE_DESCRIPTION="5:30 da tarde"  # Descrição automática
```

### **Arquivo LaunchAgent (.plist)**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.blueai.dockerbackup</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/scripts/backup/dynamic-backup.sh</string>
    </array>
    
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Hour</key>
            <integer>17</integer>
            <key>Minute</key>
            <integer>30</integer>
        </dict>
    </array>
    
    <key>StandardOutPath</key>
    <string>/tmp/docker-backup-launchagent.log</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/docker-backup-launchagent-error.log</string>
    
    <key>WorkingDirectory</key>
    <string>/path/to/project</string>
    
    <key>RunAtLoad</key>
    <false/>
    
    <key>KeepAlive</key>
    <false/>
    
    <key>ProcessType</key>
    <string>Background</string>
    
    <key>ThrottleInterval</key>
    <integer>3600</integer>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
```

## 🔄 Fluxo de Funcionamento

### **1. Instalação Inicial**
```
Usuário executa: install
    ↓
Verificação de dependências
    ↓
Geração do arquivo .plist
    ↓
Instalação do LaunchAgent
    ↓
Carregamento automático
    ↓
Status de confirmação
```

### **2. Alteração de Horário**
```
Usuário executa: schedule
    ↓
Seleção de novo horário
    ↓
Validação de entrada
    ↓
update_config_file() (atualiza config)
    ↓
source "$VERSION_CONFIG" (recarrega variáveis)
    ↓
generate_plist() (gera novo .plist)
    ↓
launchctl load (recarrega LaunchAgent)
    ↓
Confirmação de alteração
```

### **3. Execução Automática**
```
LaunchAgent (horário configurado)
    ↓
Execução do script de backup
    ↓
Processamento dos containers
    ↓
Geração de logs
    ↓
Envio de notificações
    ↓
Verificação de status
```

## 📊 Logs e Monitoramento

### **Arquivos de Log**

```bash
# Log principal
/tmp/docker-backup-launchagent.log

# Log de erros
/tmp/docker-backup-launchagent-error.log

# Logs do projeto
logs/backup.log
logs/system.log
logs/error.log
```

### **Verificação de Status**

```bash
# Status completo
./scripts/utils/install-launchagent.sh status

# Verificar se está carregado
launchctl list | grep blueai

# Verificar arquivo .plist
cat ~/Library/LaunchAgents/com.user.blueai.dockerbackup.plist

# Verificar configuração
cat config/version-config.sh | grep SCHEDULE
```

## 🚨 Troubleshooting

### **Problemas Comuns**

#### **1. LaunchAgent não executa backup**
```bash
# Verificar status
./scripts/utils/install-launchagent.sh status

# Testar funcionamento
./scripts/utils/install-launchagent.sh test-launchagent

# Verificar logs
tail -f /tmp/docker-backup-launchagent.log
```

#### **2. Horário não é alterado**
```bash
# Verificar sincronização
cat config/version-config.sh | grep SCHEDULE
cat ~/Library/LaunchAgents/com.user.blueai.dockerbackup.plist | grep -A 5 "StartCalendarInterval"

# Se inconsistente, reinstalar
./scripts/utils/install-launchagent.sh uninstall
./scripts/utils/install-launchagent.sh install
```

#### **3. LaunchAgent não carrega**
```bash
# Verificar arquivo
cat ~/Library/LaunchAgents/com.user.blueai.dockerbackup.plist

# Recarregar manualmente
launchctl unload ~/Library/LaunchAgents/com.user.blueai.dockerbackup.plist
launchctl load ~/Library/LaunchAgents/com.user.blueai.dockerbackup.plist
```

### **Comandos de Diagnóstico**

```bash
# Verificar todos os LaunchAgents
launchctl list

# Verificar arquivos do sistema
ls -la ~/Library/LaunchAgents/

# Verificar permissões
ls -la ~/Library/LaunchAgents/com.user.blueai.dockerbackup.plist

# Verificar logs do sistema
log show --predicate 'process == "launchd"' --last 1h
```

## 🔧 Configurações Avançadas

### **Personalização de Horários**

```bash
# Editar diretamente o arquivo de configuração
nano config/version-config.sh

# Alterar valores
SCHEDULE_HOUR=18
SCHEDULE_MINUTE=45
SCHEDULE_DESCRIPTION="6:45 da tarde"

# Reinstalar para aplicar mudanças
./scripts/utils/install-launchagent.sh uninstall
./scripts/utils/install-launchagent.sh install
```

### **Múltiplos Horários**

Para configurar múltiplos horários, edite manualmente o arquivo `.plist`:

```xml
<key>StartCalendarInterval</key>
<array>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>30</integer>
    </dict>
    <dict>
        <key>Hour</key>
        <integer>14</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</array>
```

## 📈 Métricas e Performance

### **Monitoramento de Execução**

```bash
# Verificar tempo de execução
grep "Backup dinâmico concluído" /tmp/docker-backup-launchagent.log

# Verificar containers processados
grep "containers" /tmp/docker-backup-launchagent.log

# Verificar erros
grep "ERROR\|CRITICAL" /tmp/docker-backup-launchagent-error.log
```

### **Otimizações Recomendadas**

1. **Horário de baixo uso**: Configure para horários de menor atividade
2. **Priorização de containers**: Configure prioridades adequadas
3. **Monitoramento de logs**: Verifique logs regularmente
4. **Backup de configurações**: Mantenha backups das configurações

## 🔮 Funcionalidades Futuras

### **Planejadas para Próximas Versões**

- ✅ **Agendamento semanal** (dias específicos da semana)
- ✅ **Múltiplos horários** via interface gráfica
- ✅ **Notificações push** para dispositivos móveis
- ✅ **Integração com calendário** do macOS
- ✅ **Backup incremental** com agendamento inteligente
- ✅ **Monitoramento de recursos** do sistema

## 📚 Referências

### **Documentação Relacionada**

- [Guia de Início Rápido](guia-inicio-rapido.md)
- [Comandos Disponíveis](comandos.md)
- [Arquitetura do Sistema](arquitetura.md)
- [Solução de Problemas](solucao-problemas.md)

### **Recursos Externos**

- [macOS LaunchAgent Documentation](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
- [Property List Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html)
- [launchctl Command Reference](https://ss64.com/osx/launchctl.html)

---

**Última atualização:** $(date +%Y-%m-%d)  
**Versão:** 2.3.1  
**Autor:** BlueAI Solutions
