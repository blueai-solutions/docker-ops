# 🐳 BlueAI Docker Ops - Sistema de Backup e Recuperação Docker

[![Version](https://img.shields.io/badge/version-2.3.1-blue.svg)](VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-ready-brightgreen.svg)](https://www.docker.com/)

Sistema completo e moderno para backup, recuperação e gerenciamento de containers Docker com configuração dinâmica, notificações avançadas e logging estruturado.

## ✨ Características Principais

- 🔄 **Recuperação Dinâmica** - Detecta e recria containers automaticamente
- 📦 **Backup Inteligente** - Sistema de backup configurável e flexível
- 🔧 **Configuração Interativa** - Interface gráfica para configurar containers
- 📊 **Monitoramento Avançado** - Logs estruturados e relatórios detalhados
- 🔔 **Notificações Multiplataforma** - macOS, email e logs
- 🎯 **Sistema Unificado** - Um comando para todas as operações
- 🛡️ **Backup de Configurações** - Sistema de versionamento de configurações

## 📁 Estrutura do Projeto

```
backend/
├── 🐳 blueai-docker-ops.sh              # Script principal unificado
├── 📁 install/                       # Scripts de instalação
│   ├── install.sh                    # Instalador automático
│   ├── uninstall.sh                  # Desinstalador
│   ├── INSTALL.md                    # Guia de instalação
│   └── README-INSTALL.md             # Instalação rápida
├── 📁 scripts/                       # Scripts do sistema
│   ├── 📁 core/                      # Scripts principais
│   │   ├── recover-containers.sh     # Recuperação dinâmica
│   │   └── manage-containers.sh      # Gerenciamento dinâmico
│   ├── 📁 backup/                    # Sistema de backup
│   │   └── dynamic-backup.sh         # Backup dinâmico configurável
│   ├── 📁 notifications/             # Sistema de notificações
│   │   └── test-notifications.sh     # Teste de notificações
│   ├── 📁 logging/                   # Sistema de logs avançados
│   │   ├── logging-functions.sh      # Funções de log estruturado
│   │   ├── log-analyzer.sh           # Analisador de logs
│   │   └── report-generator.sh       # Gerador de relatórios HTML
│   └── 📁 utils/                     # Utilitários
│       ├── container-configurator.sh # Configurador interativo
│       ├── recovery-configurator.sh  # Configurador de recuperação
│       ├── config-backup-manager.sh  # Gerenciador de backups de config
│       ├── cleanup-deprecated.sh     # Limpeza de código legado
│       ├── test-system.sh            # Teste completo do sistema
│       ├── install-launchagent.sh    # Instalador do LaunchAgent
│       └── version-utils.sh          # Utilitários de versão
├── 📁 config/                        # Configurações
│   ├── backup-config.sh              # Configuração de backup dinâmico
│   ├── recovery-config.sh            # Configuração de recuperação
│   ├── notification-config.sh        # Configurações de notificações
│   ├── version-config.sh             # Configurações de versão
│   └── 📁 backups/                   # Backups de configurações
├── 📁 logs/                          # Logs estruturados
├── 📁 reports/                       # Relatórios gerados
├── 📁 backups/                       # Backups dos volumes
├── 📁 docs/                          # Documentação completa
└── 📄 README.md                      # Esta documentação
```

## 🚀 Início Rápido

### **⚡ Instalação Automática (Recomendado)**
```bash
# Instalação em uma linha
curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install/install.sh | bash

# Após instalação, use os comandos:
blueai-docker-ops --help
blueai-docker-ops config containers
blueai-docker-ops backup
```

### **🔧 Instalação Manual (Desenvolvedores)**
```bash
# 1. Clone do repositório
git clone https://github.com/blueai-solutions/docker-ops.git
cd docker-ops/backend

# 2. Tornar executável
chmod +x blueai-docker-ops.sh
chmod +x scripts/**/*.sh

# 3. Primeira execução
./blueai-docker-ops.sh --help
```

### **2. Configurar Containers para Backup**
```bash
./blueai-docker-ops.sh config containers
```

### **3. Configurar Recuperação**
```bash
./blueai-docker-ops.sh recovery config
```

### **4. Executar Backup**
```bash
./blueai-docker-ops.sh backup
```

### **5. Verificar Status**
```bash
./blueai-docker-ops.sh status
```

## 📋 Comandos Principais

### **🔄 Backup e Recuperação**
```bash
./blueai-docker-ops.sh backup              # Executar backup dinâmico
./blueai-docker-ops.sh dynamic backup      # Backup dinâmico (recomendado)
./blueai-docker-ops.sh recover             # Recuperar containers
./blueai-docker-ops.sh status              # Verificar status dos containers
```

### **⚙️ Configuração**
```bash
./blueai-docker-ops.sh config containers   # Configurar containers para backup
./blueai-docker-ops.sh config backups      # Gerenciar backups de configuração
./blueai-docker-ops.sh recovery config     # Configurar recuperação
./blueai-docker-ops.sh recovery list       # Listar containers configurados
```

### **📊 Monitoramento**
```bash
./blueai-docker-ops.sh logs --last-24h     # Logs das últimas 24 horas
./blueai-docker-ops.sh logs --errors       # Apenas erros
./blueai-docker-ops.sh logs --performance  # Análise de performance
./blueai-docker-ops.sh monitor             # Monitorar logs em tempo real
```

### **📈 Relatórios**
```bash
./blueai-docker-ops.sh report html         # Gerar relatório HTML
./blueai-docker-ops.sh report text         # Gerar relatório de texto
./blueai-docker-ops.sh report export       # Exportar dados
```

### **🧪 Testes e Validação**
```bash
./blueai-docker-ops.sh notify-test         # Testar notificações
./blueai-docker-ops.sh validate            # Validar configurações
./blueai-docker-ops.sh dynamic validate    # Validar configuração dinâmica
```

### **🧹 Manutenção**
```bash
./blueai-docker-ops.sh cleanup             # Limpar logs e backups antigos
./blueai-docker-ops.sh version             # Mostrar informações da versão
./blueai-docker-ops.sh changelog           # Mostrar changelog
```

## 🔧 Funcionalidades Avançadas

### **🔄 Recuperação Dinâmica**
- ✅ **Detecção automática** de configurações de containers
- ✅ **Fallback inteligente** para configurações padrão
- ✅ **Suporte a qualquer nome** de container
- ✅ **Recuperação por prioridade** configurável

### **📦 Backup Dinâmico**
- ✅ **Configuração interativa** de containers
- ✅ **Detecção automática** de volumes
- ✅ **Priorização** de containers
- ✅ **Compressão** e retenção configuráveis

### **🔔 Sistema de Notificações**
- ✅ **Notificações macOS** nativas
- ✅ **Envio de email** configurável
- ✅ **Logs estruturados** com níveis
- ✅ **Relatórios HTML** detalhados

### **📊 Monitoramento**
- ✅ **Logs estruturados** com timestamps
- ✅ **Análise de performance** em tempo real
- ✅ **Relatórios automáticos** de status
- ✅ **Detecção de problemas** proativa

## 🛠️ Configuração

### **Backup de Containers**
```bash
# Configurar containers interativamente
./blueai-docker-ops.sh config containers

# Ver configuração atual
./blueai-docker-ops.sh config preview

# Validar configuração
./blueai-docker-ops.sh config validate
```

### **Recuperação de Containers**
```bash
# Configurar recuperação interativamente
./blueai-docker-ops.sh recovery config

# Ver containers configurados
./blueai-docker-ops.sh recovery list

# Validar configuração
./blueai-docker-ops.sh recovery validate
```

### **Notificações**
```bash
# Editar configurações de notificação
./blueai-docker-ops.sh config edit

# Testar notificações
./blueai-docker-ops.sh notify-test
```

## 📚 Documentação

- 📖 **[Guia de Início Rápido](docs/guia-inicio-rapido.md)** - Primeiros passos
- 🏗️ **[Arquitetura do Sistema](docs/arquitetura.md)** - Visão técnica
- 📋 **[Comandos Detalhados](docs/comandos.md)** - Referência completa
- 🔧 **[Solução de Problemas](docs/solucao-problemas.md)** - Troubleshooting
- 📝 **[Changelog](docs/changelog/)** - Histórico de versões

## 🚨 Situações de Emergência

### **Recuperação Rápida**
```bash
# Recuperar todos os containers configurados
./blueai-docker-ops.sh recover

# Verificar status
./blueai-docker-ops.sh status

# Ver logs de erro
./blueai-docker-ops.sh logs --errors
```

### **Backup de Emergência**
```bash
# Fazer backup imediato
./blueai-docker-ops.sh backup

# Verificar backups disponíveis
./blueai-docker-ops.sh backup list
```

## 🔄 Automação

### **LaunchAgent e Agendamento Automático (macOS)**
```bash
# Instalar LaunchAgent
./scripts/utils/install-launchagent.sh install

# Verificar status
./scripts/utils/install-launchagent.sh status

# Alterar horário do backup
./scripts/utils/install-launchagent.sh schedule

# Testar LaunchAgent (execução em 60s)
./scripts/utils/install-launchagent.sh test-launchagent

# Desinstalar LaunchAgent
./scripts/utils/install-launchagent.sh uninstall
```

**Funcionalidades Avançadas:**
- ✅ **Agendamento inteligente** com sincronização automática
- ✅ **Backup de configurações** antes de alterações
- ✅ **Validação de horários** e descrição inteligente
- ✅ **Teste de funcionamento** com execução imediata

### **Cron Jobs**
```bash
# Adicionar ao crontab para backup automático
0 2 * * * /path/to/backend/blueai-docker-ops.sh backup
```

## 🧪 Testes

### **Teste Completo do Sistema**
```bash
./scripts/utils/test-system.sh
```

### **Teste de Notificações**
```bash
./blueai-docker-ops.sh notify-test
```

### **Validação de Configuração**
```bash
./blueai-docker-ops.sh validate
```

## 📈 Monitoramento

### **Logs em Tempo Real**
```bash
./blueai-docker-ops.sh monitor
```

### **Análise de Performance**
```bash
./blueai-docker-ops.sh logs --performance
```

### **Relatórios Automáticos**
```bash
./blueai-docker-ops.sh report html
```

## 🤝 Contribuição

1. **Fork** o projeto
2. **Crie** uma branch para sua feature
3. **Commit** suas mudanças
4. **Push** para a branch
5. **Abra** um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

- 📖 **Documentação**: [docs/](docs/)
- 🐛 **Issues**: Abra uma issue no GitHub
- 💬 **Discussões**: Use as discussões do GitHub

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
