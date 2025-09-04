# 🚀 LaunchAgent e Sistema de Agendamento - BlueAI Docker Ops

Este documento descreve o sistema de agendamento automático usando macOS LaunchAgent no sistema simplificado.

## 📋 Visão Geral

O sistema de agendamento do BlueAI Docker Ops utiliza macOS LaunchAgent para executar backups automáticos no horário configurado. No sistema simplificado, o agendamento é configurado automaticamente durante o setup inicial.

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

## 🚀 Comandos Simplificados

### **Configuração Inicial (Automática)**
```bash
# Configuração completa incluindo agendamento
make setup

# OU usar o script diretamente
./blueai-docker-ops.sh setup
```

**O que acontece automaticamente:**
1. ✅ **Configuração interativa** - Email e horário do backup
2. 🕐 **Agendamento automático** - LaunchAgent instalado
3. 🔧 **Instalação do sistema** - Comandos disponíveis no PATH

### **Gerenciamento de Agendamento**
```bash
# Ver status do agendamento
./blueai-docker-ops.sh status

# Configurar agendamento
./blueai-docker-ops.sh schedule

# Ver comandos avançados disponíveis
./blueai-docker-ops.sh advanced
```

### **Comandos Avançados (via `advanced`)**
```bash
# Acessar comandos avançados
./blueai-docker-ops.sh advanced

# Comandos de automação disponíveis:
automation install     # Instalar LaunchAgent
automation status      # Verificar status
automation test        # Testar automação
```

## ⚙️ Configuração

### **Arquivo de Configuração Principal**

```bash
# config/version-config.sh
SCHEDULE_HOUR=2          # Hora (0-23)
SCHEDULE_MINUTE=30       # Minuto (0-59)
SCHEDULE_DESCRIPTION="2:30 da manhã"  # Descrição automática
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
        <string>/usr/local/blueai-docker-ops/blueai-docker-ops.sh</string>
        <string>backup</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>30</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/docker-backup-launchagent.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/docker-backup-launchagent-error.log</string>
</dict>
</plist>
```

## 🔧 Como Funciona

### **Fluxo de Configuração**
```
Usuário executa setup
    ↓
Configuração interativa (email + horário)
    ↓
Criação de arquivos de configuração
    ↓
Geração do arquivo .plist
    ↓
Instalação do LaunchAgent
    ↓
Sistema agendado automaticamente
```

### **Fluxo de Execução**
```
LaunchAgent (Horário Configurado)
    ↓
Execução automática do backup
    ↓
Geração de logs
    ↓
Envio de notificações
    ↓
Geração de relatórios
```

### **Sincronização de Configurações**
```
Usuário altera horário
    ↓
Atualização de version-config.sh
    ↓
Geração automática de novo .plist
    ↓
Reinstalação do LaunchAgent
    ↓
Sincronização completa
```

## 📊 Monitoramento

### **Ver Status do Agendamento**
```bash
# Status geral do sistema
./blueai-docker-ops.sh status

# Ver configuração de horário
cat config/version-config.sh | grep SCHEDULE

# Ver status do LaunchAgent
launchctl list | grep docker
```

### **Logs do LaunchAgent**
```bash
# Ver logs do sistema
./blueai-docker-ops.sh logs

# Ver logs específicos do LaunchAgent
tail -f /tmp/docker-backup-launchagent.log
tail -f /tmp/docker-backup-launchagent-error.log
```

## 🎯 Exemplos de Uso

### **Configuração Inicial**
```bash
# 1. Executar setup completo
make setup

# 2. O sistema irá solicitar:
#    - Email para notificações
#    - Horário para backup automático

# 3. Verificar se está funcionando
./blueai-docker-ops.sh status
```

### **Alterar Horário do Backup**
```bash
# 1. Ver horário atual
./blueai-docker-ops.sh status

# 2. Alterar horário
./blueai-docker-ops.sh schedule

# 3. O sistema irá:
#    - Solicitar novo horário
#    - Atualizar configuração
#    - Reinstalar LaunchAgent
#    - Confirmar alteração

# 4. Verificar alteração
./blueai-docker-ops.sh status
```

### **Verificar Funcionamento**
```bash
# 1. Ver status geral
./blueai-docker-ops.sh status

# 2. Ver logs recentes
./blueai-docker-ops.sh logs

# 3. Ver configuração atual
cat config/version-config.sh | grep SCHEDULE
```

## 🚨 Solução de Problemas

### **"Backup automático não executa"**

#### **Sintomas:**
- Backup não executa no horário configurado
- LaunchAgent não está funcionando

#### **Soluções:**
```bash
# 1. Verificar status do agendamento
./blueai-docker-ops.sh status

# 2. Verificar LaunchAgent
launchctl list | grep docker

# 3. Reconfigurar agendamento
./blueai-docker-ops.sh schedule

# 4. Testar agendamento
./blueai-docker-ops.sh advanced
```

#### **Prevenção:**
- Configure agendamento durante setup inicial
- Teste agendamento após configuração
- Monitore logs do LaunchAgent

### **"Horário incorreto"**

#### **Sintomas:**
- Backup executa em horário diferente do configurado
- Configuração de horário não é respeitada

#### **Soluções:**
```bash
# 1. Verificar configuração atual
cat config/version-config.sh | grep SCHEDULE

# 2. Reconfigurar horário
./blueai-docker-ops.sh schedule

# 3. Verificar LaunchAgent
launchctl list | grep docker
```

### **"LaunchAgent não carrega"**

#### **Sintomas:**
- Erro: "Could not find specified service"
- LaunchAgent não aparece em `launchctl list`
- Arquivo .plist corrompido

#### **Soluções:**
```bash
# 1. Verificar arquivo do LaunchAgent
cat ~/Library/LaunchAgents/com.user.blueai.dockerbackup.plist

# 2. Verificar permissões
ls -la ~/Library/LaunchAgents/

# 3. Reconfigurar agendamento
./blueai-docker-ops.sh schedule

# 4. Se persistir, reconfigurar tudo
./blueai-docker-ops.sh setup
```

## 📚 Recursos Adicionais

### **Documentação Relacionada**
- **Guia de Início Rápido:** [guia-inicio-rapido.md](guia-inicio-rapido.md)
- **Comandos Detalhados:** [comandos.md](comandos.md)
- **Configuração:** [configuracao.md](configuracao.md)
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

## 🔮 Funcionalidades Futuras

### **Planejado para v2.5.0**
- **Interface web** para configuração de agendamento
- **Dashboard** de status dos backups agendados
- **Notificações push** para dispositivos móveis
- **API REST** para integração com outros sistemas

### **Roadmap de Longo Prazo**
- **Agendamento múltiplo** para diferentes tipos de backup
- **Agendamento inteligente** baseado em uso do sistema
- **Integração** com calendários e feriados
- **Machine learning** para otimização de horários

---

**🚀 Sistema de agendamento automático integrado ao setup simplificado!**
