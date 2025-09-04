# 🏗️ Arquitetura do Sistema

Documentação técnica da arquitetura e funcionamento interno do BlueAI Docker Ops simplificado.

## 📋 Visão Geral

O BlueAI Docker Ops é uma solução completa e automatizada para backup de volumes Docker em ambiente macOS, com notificações, logging estruturado e relatórios. O sistema foi redesenhado para ser **simples, intuitivo e eficiente**.

## 🏛️ Arquitetura de Alto Nível

```
┌─────────────────────────────────────────────────────────────┐
│                    BlueAI Docker Ops                        │
├─────────────────────────────────────────────────────────────┤
│  🐳 blueai-docker-ops.sh (Script Principal Simplificado)   │
│  └───┬─── Interface Unificada                              │
│      ├─── Roteamento de Comandos                           │
│      └─── Sistema de Ajuda Inteligente                     │
├─────────────────────────────────────────────────────────────┤
│  📁 Scripts/ (Módulos Funcionais)                          │
│  ├─── 📁 core/ (Scripts Principais)                        │
│  ├─── 📁 backup/ (Sistema de Backup)                       │
│  ├─── 📁 notifications/ (Sistema de Notificações)          │
│  ├─── 📁 logging/ (Sistema de Logs)                        │
│  ├─── 📁 utils/ (Utilitários para Usuários)                │
│  └─── 📁 install/ (Scripts de Instalação)                  │
├─────────────────────────────────────────────────────────────┤
│  📁 Config/ (Configurações Centralizadas)                  │
│  ├─── backup-config.sh                                     │
│  ├─── recovery-config.sh                                   │
│  ├─── notification-config.sh                               │
│  ├─── version-config.sh                                    │
│  └─── 📁 templates/ (Templates Limpos)                     │
├─────────────────────────────────────────────────────────────┤
│  📁 Data/ (Dados Gerados)                                  │
│  ├─── 📁 backups/ (Backups dos Volumes)                    │
│  ├─── 📁 logs/ (Logs Estruturados)                         │
│  ├─── 📁 reports/ (Relatórios Gerados)                     │
│  └─── 📁 docs/ (Documentação)                              │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Componentes Principais

### **1. Script Principal (blueai-docker-ops.sh)**

**Responsabilidade:** Ponto de entrada unificado para todos os comandos
**Funcionalidades:**
- Roteamento de comandos para módulos específicos
- Interface de usuário consistente e intuitiva
- Sistema de ajuda inteligente
- Tratamento de erros centralizado

**Fluxo de Execução:**
```bash
blueai-docker-ops.sh [comando]
    ↓
Verificar comando
    ↓
Rotear para módulo específico
    ↓
Executar funcionalidade
    ↓
Retornar resultado
```

**Comandos Essenciais:**
- `setup` - Configuração inicial completa
- `config` - Configuração interativa
- `schedule` - Configurar agendamento
- `volumes` - Ver volumes configurados
- `backup` - Executar backup
- `recovery` - Executar recovery
- `status` - Status geral do sistema
- `test` - Testar sistema completo

### **2. Sistema de Backup (scripts/backup/)**

**Responsabilidade:** Execução de backups de volumes Docker
**Componentes:**
- `dynamic-backup.sh` - Backup dinâmico configurável

**Fluxo de Backup:**
```
1. Verificar Docker
   ↓
2. Verificar Volumes Configurados
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
- `logging-functions.sh` - Funções de log estruturado
- `log-analyzer.sh` - Analisador de logs
- `report-generator.sh` - Gerador de relatórios HTML

**Estrutura de Logs:**
```
logs/
├── backup.log          # Logs de backup
├── error.log           # Logs de erro
├── performance.log     # Logs de performance
└── system.log          # Logs do sistema
```

### **5. Sistema de Configuração (config/)**

**Responsabilidade:** Gerenciamento centralizado de configurações
**Componentes:**
- `backup-config.sh` - Configuração de backup
- `recovery-config.sh` - Configuração de recuperação
- `notification-config.sh` - Configuração de notificações
- `version-config.sh` - Configuração de versão

**Templates Limpos:**
- `config/templates/` - Configurações limpas para distribuição
- Sem dados locais ou específicos do usuário

## 🔄 Fluxo de Dados

### **Fluxo de Configuração**
```
Usuário executa setup
    ↓
Configuração interativa
    ↓
Criação de arquivos de config
    ↓
Instalação de LaunchAgent
    ↓
Sistema pronto para uso
```

### **Fluxo de Backup**
```
Agendamento automático
    ↓
Verificação de Docker
    ↓
Execução de backup
    ↓
Geração de logs
    ↓
Envio de notificações
    ↓
Geração de relatórios
```

### **Fluxo de Recovery**
```
Usuário executa recovery
    ↓
Verificação de configuração
    ↓
Recuperação de containers
    ↓
Verificação de saúde
    ↓
Logs e notificações
```

## 🏗️ Estrutura de Diretórios

### **Estrutura Simplificada**
```
blueai-docker-ops/
├── 🐳 blueai-docker-ops.sh              # Script principal
├── 📁 config/                            # Configurações
│   ├── 📁 templates/                     # Templates limpos (versionados)
│   └── 📁 backups/                       # Backups automáticos de configuração
├── 📁 scripts/                           # Scripts organizados
│   ├── 📁 core/                          # Scripts principais
│   ├── 📁 backup/                        # Sistema de backup
│   ├── 📁 notifications/                 # Sistema de notificações
│   ├── 📁 logging/                       # Sistema de logs
│   ├── 📁 utils/                         # Utilitários para usuários
│   └── 📁 install/                       # Scripts de instalação
├── 📁 install/                            # Scripts de instalação do sistema
├── 📁 logs/                               # Logs estruturados
├── 📁 reports/                            # Relatórios gerados
├── 📁 backups/                            # Backups dos volumes
└── 📁 docs/                               # Documentação completa
```

## 🔧 Configuração do Sistema

### **Configuração Inicial (setup)**
```bash
./blueai-docker-ops.sh setup
```
**O que acontece:**
1. **Configuração interativa** - Email e horário do backup
2. **Criação de configurações** usando templates limpos
3. **Instalação de LaunchAgent** para agendamento automático
4. **Instalação do sistema** com comandos no PATH

### **Configuração Interativa (config)**
```bash
./blueai-docker-ops.sh config
```
**O que acontece:**
1. **Solicitação de email** para notificações
2. **Configuração de horário** para backup automático
3. **Criação de configurações** personalizadas

### **Agendamento (schedule)**
```bash
./blueai-docker-ops.sh schedule
```
**O que acontece:**
1. **Configuração de horário** para backup automático
2. **Instalação de LaunchAgent** com horário configurado
3. **Sincronização** entre configuração e agendamento

## 📊 Monitoramento e Logs

### **Sistema de Logs**
- **Logs estruturados** com timestamps e níveis
- **Rotação automática** de logs antigos
- **Análise inteligente** de logs
- **Relatórios HTML** detalhados

### **Monitoramento em Tempo Real**
- **Status geral** do sistema
- **Verificação de volumes** configurados
- **Status de serviços** de recovery
- **Informações de agendamento**

## 🔄 Automação

### **LaunchAgent (macOS)**
- **Agendamento automático** de backups
- **Sincronização** com configurações
- **Notificações** sobre status
- **Relatórios** periódicos

### **Configuração Automática**
- **Templates limpos** para distribuição
- **Configuração interativa** para usuários
- **Backup automático** de configurações
- **Validação** de configurações

## 🚀 Performance e Escalabilidade

### **Otimizações Implementadas**
- **Sistema simplificado** com menos comandos
- **Roteamento eficiente** de comandos
- **Logs estruturados** para análise rápida
- **Configurações centralizadas** para manutenção

### **Escalabilidade**
- **Módulos independentes** para funcionalidades
- **Configurações flexíveis** para diferentes ambientes
- **Templates limpos** para distribuição
- **Sistema de plugins** para extensões futuras

## 🔒 Segurança

### **Medidas de Segurança**
- **Verificação de permissões** antes de execução
- **Validação de configurações** antes de uso
- **Backup automático** de configurações
- **Logs de auditoria** para todas as operações

### **Isolamento**
- **Containers Docker** isolados
- **Volumes separados** para dados
- **Configurações independentes** por usuário
- **Logs separados** por funcionalidade

## 🧪 Testes e Validação

### **Sistema de Testes**
- **Teste completo** do sistema
- **Validação de configurações**
- **Teste de notificações**
- **Teste de backup e recovery**

### **Validação Automática**
- **Verificação de dependências**
- **Validação de configurações**
- **Teste de conectividade**
- **Verificação de permissões**

## 📚 Documentação

### **Estrutura de Documentação**
- **Guia de início rápido** para novos usuários
- **Documentação de comandos** completa
- **Arquitetura técnica** detalhada
- **Solução de problemas** comum
- **Exemplos práticos** de uso

### **Manutenção**
- **Documentação atualizada** com código
- **Exemplos funcionais** testados
- **Changelog** detalhado por versão
- **Guia de contribuição** para desenvolvedores

## 🔮 Roadmap e Futuro

### **Funcionalidades Planejadas**
- **Backup incremental** para melhor performance
- **Backup remoto** para servidores externos
- **Criptografia** para backups sensíveis
- **Interface web** para monitoramento
- **App móvel** para notificações

### **Melhorias Técnicas**
- **Sistema de plugins** para extensões
- **API REST** para integração
- **Métricas avançadas** de performance
- **Machine learning** para otimização

---

**🎯 Sistema arquitetado para ser simples, eficiente e escalável!**
