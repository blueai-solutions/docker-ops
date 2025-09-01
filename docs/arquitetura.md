# 🏗️ Arquitetura do Sistema

Documentação técnica da arquitetura e funcionamento interno do BlueAI Docker Ops.

## 📋 Visão Geral

O BlueAI Docker Ops é uma solução completa e automatizada para backup de volumes Docker em ambiente macOS, com notificações, logging estruturado e relatórios.

## 🏛️ Arquitetura de Alto Nível

```
┌─────────────────────────────────────────────────────────────┐
│                    BlueAI Docker Ops                        │
├─────────────────────────────────────────────────────────────┤
│  🐳 blueai-docker-ops.sh (Script Principal)                     │
│  └───┬─── Comando Unificado                                 │
│      ├─── Roteamento de Comandos                            │
│      └─── Interface de Usuário                              │
├─────────────────────────────────────────────────────────────┤
│  📁 Scripts/ (Módulos Funcionais)                           │
│  ├─── 📁 core/ (Scripts Principais)                         │
│  ├─── 📁 backup/ (Sistema de Backup)                        │
│  ├─── 📁 notifications/ (Sistema de Notificações)           │
│  ├─── 📁 logging/ (Sistema de Logs)                         │
│  └─── 📁 utils/ (Utilitários)                               │
├─────────────────────────────────────────────────────────────┤
│  📁 Config/ (Configurações)                                 │
│  ├─── notification-config.sh                                │
│  └─── com.user.dockerbackup.plist                           │
├─────────────────────────────────────────────────────────────┤
│  📁 Data/ (Dados Gerados)                                   │
│  ├─── 📁 backups/ (Backups dos Volumes)                     │
│  ├─── 📁 logs/ (Logs Estruturados)                          │
│  ├─── 📁 reports/ (Relatórios Gerados)                      │
│  └─── 📁 docs/ (Documentação)                               │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Componentes Principais

### **1. Script Principal (blueai-docker-ops.sh)**

**Responsabilidade:** Ponto de entrada unificado para todos os comandos
**Funcionalidades:**
- Roteamento de comandos para módulos específicos
- Interface de usuário consistente
- Validação de parâmetros
- Tratamento de erros centralizado

**Fluxo de Execução:**
```bash
blueai-docker-ops.sh [comando] [opções]
    ↓
Verificar comando
    ↓
Rotear para módulo específico
    ↓
Executar funcionalidade
    ↓
Retornar resultado
```

### **2. Sistema de Backup (scripts/backup/)**

**Responsabilidade:** Execução de backups de volumes Docker
**Componentes:**
- `smart-backup.sh` - Backup inteligente com verificações
- `backup-volumes.sh` - Backup direto de volumes

**Fluxo de Backup:**
```
1. Verificar Docker
   ↓
2. Verificar Containers
   ↓
3. Verificar Espaço em Disco
   ↓
4. Executar Backup
   ↓
5. Verificar Integridade
   ↓
6. Limpar Backups Antigos
   ↓
7. Gerar Relatórios
   ↓
8. Enviar Notificações
```

### **3. Sistema de Notificações (scripts/notifications/)**

**Responsabilidade:** Envio de notificações por email e macOS
**Tipos de Notificação:**
- ✅ **Sucesso:** Backup concluído com sucesso
- ⚠️ **Aviso:** Containers parados, espaço baixo
- ❌ **Erro:** Falhas críticas no backup

**Canais de Notificação:**
- **Email:** Via `mail` ou `sendmail`
- **macOS:** Via `osascript` (notificações nativas)

### **4. Sistema de Logs (scripts/logging/)**

**Responsabilidade:** Logging estruturado e análise
**Componentes:**
- `logging-functions.sh` - Funções de logging
- `log-analyzer.sh` - Análise de logs
- `report-generator.sh` - Geração de relatórios

**Níveis de Log:**
- **DEBUG:** Informações detalhadas para debugging
- **INFO:** Informações gerais de operação
- **WARNING:** Avisos que não impedem operação
- **ERROR:** Erros que impedem funcionalidade
- **CRITICAL:** Erros críticos do sistema

**Arquivos de Log:**
- `backup.log` - Logs de backup
- `error.log` - Logs de erro
- `system.log` - Logs do sistema
- `performance.log` - Métricas de performance

### **5. Sistema de Recuperação (scripts/core/)**

**Responsabilidade:** Gerenciamento de containers Docker
**Componentes:**
- `recover.sh` - Recuperação e gerenciamento
- `manage-containers.sh` - Gerenciamento avançado

**Funcionalidades:**
- Iniciar/parar containers
- Verificar status
- Limpeza de containers
- Backup de volumes

### **6. LaunchAgent (config/)**

**Responsabilidade:** Agendamento automático de backups
**Configuração:**
- **Horário padrão:** 02:30 diariamente
- **Logs:** `/tmp/docker-backup-launchagent.log`
- **Erros:** `/tmp/docker-backup-launchagent-error.log`

## 🔄 Fluxos de Dados

### **Fluxo de Backup Automático**
```
LaunchAgent (02:30)
    ↓
smart-backup.sh
    ↓
Verificações (Docker, Containers, Disco)
    ↓
backup-volumes.sh
    ↓
Docker Volume Backup
    ↓
Verificação de Integridade
    ↓
Limpeza de Backups Antigos
    ↓
Geração de Relatórios
    ↓
Envio de Notificações
    ↓
Logging de Resultados
```

### **Fluxo de Notificações**
```
Evento (Sucesso/Aviso/Erro)
    ↓
notification-config.sh (Configurações)
    ↓
Verificar Canais Habilitados
    ↓
Email (se habilitado)
    ↓
macOS Notification (se habilitado)
    ↓
Logging da Notificação
```

### **Fluxo de Logging**
```
Evento do Sistema
    ↓
logging-functions.sh
    ↓
Determinar Nível de Log
    ↓
Formatação da Mensagem
    ↓
Escrita no Arquivo Apropriado
    ↓
Output no Terminal (se aplicável)
```

## 📊 Estrutura de Dados

### **Configurações (config/notification-config.sh)**
```bash
# Notificações
NOTIFICATIONS_ENABLED=true
EMAIL_ENABLED=true
MACOS_NOTIFICATIONS_ENABLED=true

# Email
EMAIL_TO="usuario@exemplo.com"
EMAIL_FROM="docker-ops@blueaisolutions.com.br"
EMAIL_SUBJECT_PREFIX="[Docker Backup]"

# macOS
NOTIFICATION_TITLE="Docker Backup"
NOTIFICATION_SOUND="Glass"
NOTIFICATION_TIMEOUT=10

# Logging
LOG_LEVEL=1  # 0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=CRITICAL
```

### **Estrutura de Logs**
```
logs/
├── backup.log      # Logs de operações de backup
├── error.log       # Logs de erros
├── system.log      # Logs do sistema
└── performance.log # Métricas de performance
```

### **Estrutura de Backups**
```
backups/
├── mongo-local-data_20250829_025644.tar.gz
├── postgres-local-data_20250829_025644.tar.gz
└── rabbit-local-data_20250829_025644.tar.gz
```

## 🔒 Segurança

### **Permissões de Arquivos**
- **Scripts:** `755` (executável para todos)
- **Configurações:** `644` (leitura para todos, escrita para proprietário)
- **Logs:** `644` (leitura para todos, escrita para proprietário)
- **Backups:** `644` (leitura para todos, escrita para proprietário)

### **Validações de Segurança**
- Verificação de permissões antes da execução
- Validação de caminhos para evitar path traversal
- Sanitização de inputs de usuário
- Verificação de integridade de backups

## ⚡ Performance

### **Otimizações Implementadas**
- **Backup incremental:** (futuro)
- **Compressão:** Gzip para reduzir tamanho
- **Paralelização:** Backups simultâneos (futuro)
- **Cache:** Informações de containers em cache

### **Métricas de Performance**
- **Tempo de backup:** Medido e logado
- **Uso de recursos:** CPU, memória, disco
- **Tamanho de backups:** Monitorado
- **Frequência de execução:** Configurável

## 🔧 Manutenibilidade

### **Padrões de Código**
- **Bash:** Scripts em bash puro para compatibilidade
- **Modularidade:** Cada funcionalidade em módulo separado
- **Configuração:** Configurações centralizadas
- **Logging:** Sistema de logs estruturado

### **Extensibilidade**
- **Plugins:** Estrutura preparada para plugins (futuro)
- **Configurações:** Fácil adição de novas configurações
- **Notificações:** Novos canais podem ser adicionados
- **Relatórios:** Novos formatos podem ser implementados

## 🚀 Escalabilidade

### **Limitações Atuais**
- **Backup único:** Um backup por execução
- **Local:** Apenas backup local
- **Síncrono:** Execução sequencial

### **Melhorias Futuras**
- **Backup distribuído:** Múltiplos servidores
- **Cloud storage:** Backup na nuvem
- **Paralelização:** Backups simultâneos
- **Incremental:** Backup apenas de mudanças

## 📈 Monitoramento

### **Métricas Coletadas**
- **Tempo de execução:** Por operação
- **Taxa de sucesso:** Backups bem-sucedidos
- **Uso de recursos:** CPU, memória, disco
- **Erros:** Frequência e tipos de erro

### **Alertas**
- **Falha de backup:** Notificação imediata
- **Espaço baixo:** Aviso preventivo
- **Performance:** Alertas de degradação
- **Integridade:** Falhas de verificação

---

**📝 Nota:** Esta arquitetura é evolutiva e pode ser expandida conforme necessário.
