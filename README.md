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
├── 📁 install/                           # Scripts de instalação do sistema
│   ├── install.sh                        # Instalador automático
│   ├── uninstall.sh                      # Desinstalador
│   ├── INSTALL.md                        # Guia de instalação
│   └── README-INSTALL.md                 # Instalação rápida
├── 📁 scripts/                           # Scripts organizados por funcionalidade
│   ├── 📁 core/                          # Scripts principais do sistema
│   │   ├── recover-containers.sh         # Recuperação dinâmica
│   │   ├── manage-containers.sh          # Gerenciamento dinâmico
│   │   ├── recover.sh                    # Recuperação principal
│   │   └── backup-volumes.sh             # Backup de volumes
│   ├── 📁 backup/                        # Sistema de backup
│   │   └── dynamic-backup.sh             # Backup dinâmico configurável
│   ├── 📁 notifications/                 # Sistema de notificações
│   │   └── test-notifications.sh         # Teste de notificações
│   ├── 📁 logging/                       # Sistema de logs avançados
│   │   ├── logging-functions.sh          # Funções de log estruturado
│   │   ├── log-analyzer.sh               # Analisador de logs
│   │   └── report-generator.sh           # Gerador de relatórios HTML
│   ├── 📁 utils/                         # Utilitários para usuários finais
│   │   ├── container-configurator.sh     # Configurador interativo
│   │   ├── recovery-configurator.sh      # Configurador de recuperação
│   │   ├── config-backup-manager.sh      # Gerenciador de backups de config
│   │   ├── cleanup-deprecated.sh         # Limpeza de código legado
│   │   └── test-system.sh                # Teste completo do sistema
│   ├── 📁 install/                       # Scripts de instalação para usuários
│   │   └── install-launchagent.sh        # Instalador do LaunchAgent
│   └── 📁 dev/                           # Scripts de desenvolvimento (NÃO incluídos no release)
│       ├── release-manager.sh            # Gerenciador de releases
│       ├── changelog-manager.sh          # Gerenciador de changelog
│       └── version-utils.sh              # Utilitários de versão
├── 📁 config/                            # Configurações do sistema
│   ├── backup-config.sh                  # Configuração de backup dinâmico
│   ├── recovery-config.sh                # Configuração de recuperação
│   ├── notification-config.sh            # Configurações de notificações
│   ├── version-config.sh                 # Configurações de versão
│   └── 📁 backups/                       # Backups de configurações
├── 📁 logs/                              # Logs estruturados
├── 📁 reports/                           # Relatórios gerados
├── 📁 backups/                           # Backups dos volumes
├── 📁 docs/                              # Documentação completa
└── 📄 README.md                           # Esta documentação
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
```

### **🔧 Utilitários**
```bash
./blueai-docker-ops.sh test system         # Testar sistema completo
./blueai-docker-ops.sh cleanup             # Limpeza e manutenção
./blueai-docker-ops.sh version             # Informações de versão
```

## 🏗️ **Organização dos Scripts**

### **📁 Scripts Organizados por Funcionalidade:**

#### **🎯 Core (Funcionalidades Principais)**
- `recover-containers.sh` - Recuperação automática
- `manage-containers.sh` - Gerenciamento dinâmico
- `backup-volumes.sh` - Sistema de backup

#### **🔧 Utils (Utilitários para Usuários)**
- `container-configurator.sh` - Configuração interativa
- `recovery-configurator.sh` - Configuração de recuperação
- `test-system.sh` - Testes do sistema
- `config-backup-manager.sh` - Gerenciamento de backups

#### **🚀 Install (Instalação para Usuários)**
- `install-launchagent.sh` - Gerenciador do LaunchAgent

#### **🛠️ Dev (Desenvolvimento - NÃO incluído no release)**
- `release-manager.sh` - Gerenciamento de releases
- `changelog-manager.sh` - Gerenciamento de changelog
- `version-utils.sh` - Utilitários de versão

## 🎯 **Separação de Responsabilidades**

### **📦 Para Usuários Finais (Pacote de Release):**
- Scripts de **uso** e **operação** do sistema
- Utilitários de **configuração** e **testes**
- Scripts de **instalação** e **configuração**
- **Documentação de uso** e **suporte**

### **👨‍💻 Para Desenvolvedores (Repositório):**
- **Todos** os scripts disponíveis
- Scripts de **desenvolvimento** e **release management**
- **Workflows** do GitHub Actions
- **Documentação técnica** completa

## 📚 Documentação

- **📖 [Guia de Início Rápido](docs/guia-inicio-rapido.md)** - Primeiros passos
- **🔧 [Comandos](docs/comandos.md)** - Referência completa de comandos
- **🏗️ [Arquitetura](docs/arquitetura.md)** - Visão técnica do sistema
- **🚀 [LaunchAgent](docs/launchagent.md)** - Agendamento automático
- **🆘 [Solução de Problemas](docs/solucao-problemas.md)** - Troubleshooting
- **📦 [Distribuição](docs/distribuicao.md)** - Guia de distribuição GitHub

## 🚀 **Instalação e Configuração**

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

# 2. Configuração automática com Makefile
make dev-setup          # Configurar ambiente
make config-interactive  # Configuração interativa
make test               # Executar testes

# 3. Primeira execução
./blueai-docker-ops.sh --help
```

## 🛠️ **Automação com Makefile**

### **🚀 Comandos Principais:**
```bash
# Ajuda e informações
make help               # Todos os comandos disponíveis
make info               # Informações do projeto
make status             # Status completo

# Desenvolvimento
make dev-setup          # Configurar ambiente
make test               # Executar testes
make validate           # Validar sintaxe
make check              # Verificação completa

# Configuração
make config-clean       # Limpar configurações
make config-interactive # Configuração interativa
make config-email       # Configurar email
make config-schedule    # Configurar horário

# LaunchAgent
make launchagent-install   # Instalar LaunchAgent
make launchagent-status    # Verificar status
make launchagent-test      # Testar funcionamento

# Releases
make version-bump       # Incrementar versão
make release-create     # Criar release
make changelog-create   # Criar changelog

# Deploy
make deploy-prep        # Preparar para deploy
make package            # Criar pacote de distribuição
```

### **🎯 Comandos Especiais:**
```bash
make quick-start        # Configuração completa em uma linha
make check-all          # Verificação completa com configurações limpas
make all                # Configuração completa do projeto
```

**📖 Para documentação completa do Makefile:** [docs/makefile.md](docs/makefile.md)

## 🔔 **Sistema de Notificações**

- **📧 Email** - Notificações por email
- **🍎 macOS** - Notificações nativas do sistema
- **📊 Logs** - Logs estruturados e relatórios

## 🧪 **Testes e Validação**

```bash
# Teste completo do sistema
./blueai-docker-ops.sh test system

# Teste específico de componente
./blueai-docker-ops.sh test --component backup

# Validação de configurações
./blueai-docker-ops.sh validate
```

## 🆘 **Suporte e Contribuição**

- **📧 Email:** docker-ops@blueaisolutions.com.br
- **🐛 Issues:** [GitHub Issues](https://github.com/blueai-solutions/docker-ops/issues)
- **📖 Documentação:** [Documentação Completa](docs/)
- **🚀 Releases:** [GitHub Releases](https://github.com/blueai-solutions/docker-ops/releases)

## 📄 **Licença**

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 **Contribuição**

Contribuições são bem-vindas! Por favor, leia o [Guia de Contribuição](CONTRIBUTING.md) antes de submeter pull requests.

---

**Desenvolvido com ❤️ pela BlueAI Solutions**

**🌐 Website:** https://blueaisolutions.com.br  
**📧 Email:** docker-ops@blueaisolutions.com.br  
**🐛 Issues:** https://github.com/blueai-solutions/docker-ops/issues
