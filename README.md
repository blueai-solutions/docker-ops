# 🐳 BlueAI Docker Ops - Sistema de Backup e Recuperação Docker

[![Version](https://img.shields.io/badge/version-2.4.0-blue.svg)](VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-ready-brightgreen.svg)](https://www.docker.com/)
[![macOS](https://img.shields.io/badge/macOS-10.15+-lightgrey.svg)](https://www.apple.com/macos/)

Sistema **simplificado e intuitivo** para backup, recuperação e gerenciamento de containers Docker com configuração dinâmica, notificações avançadas e logging estruturado.

## ✨ Características Principais

- 🚀 **Configuração em 3 Passos** - Setup completo e automático
- 🔄 **Recuperação Inteligente** - Detecta e recria containers automaticamente
- 📦 **Backup Automatizado** - Sistema de backup configurável e flexível
- 🔧 **Configuração Interativa** - Interface simples para configurar o sistema
- 📊 **Monitoramento Avançado** - Logs estruturados e relatórios detalhados
- 🔔 **Notificações Multiplataforma** - macOS, email e logs
- 🎯 **Sistema Unificado** - Apenas 8 comandos essenciais
- 🛡️ **Backup de Configurações** - Sistema de versionamento automático

## 🎯 **Por que Simplificado?**

- ✅ **Menos confusão** - Apenas comandos essenciais
- ✅ **Mais intuitivo** - Interface clara e direta
- ✅ **Configuração automática** - Setup em uma linha
- ✅ **Manutenção fácil** - Estrutura organizada e limpa

## 📁 Estrutura do Projeto

```
blueai-docker-ops/
├── 🐳 blueai-docker-ops.sh              # Script principal simplificado
├── 📁 config/                            # Configurações do sistema
│   ├── 📁 templates/                     # Templates limpos para distribuição (versionados)
│   └── 📁 backups/                       # Backups automáticos de configuração
├── 📁 scripts/                           # Scripts organizados por funcionalidade
│   ├── 📁 core/                          # Scripts principais do sistema
│   ├── 📁 backup/                        # Sistema de backup
│   ├── 📁 notifications/                 # Sistema de notificações
│   ├── 📁 logging/                       # Sistema de logs avançados
│   ├── 📁 utils/                         # Utilitários para usuários finais
│   └── 📁 install/                       # Scripts de instalação
├── 📁 install/                            # Scripts de instalação do sistema
├── 📁 logs/                               # Logs estruturados
├── 📁 reports/                            # Relatórios gerados
├── 📁 backups/                            # Backups dos volumes
└── 📁 docs/                               # Documentação completa
```

> **⚠️ Nota:** Os arquivos de configuração local (`backup-config.sh`, `recovery-config.sh`, etc.) **NÃO são versionados** no Git, pois contêm configurações específicas da máquina local. Eles são criados automaticamente a partir dos templates durante a instalação.

## 🚀 Início Rápido

### **⚡ Configuração em Uma Linha (Recomendado)**

```bash
# Configuração completa do sistema
make setup

# OU usar o script diretamente
./blueai-docker-ops.sh setup
```

**O que acontece automaticamente:**
1. ✅ **Configuração interativa** - Email e horário do backup
2. 🕐 **Agendamento automático** - LaunchAgent instalado
3. 🔧 **Instalação do sistema** - Comandos disponíveis no PATH

### **🔧 Instalação Manual (Desenvolvedores)**

```bash
# 1. Clone do repositório
git clone https://github.com/blueai-solutions/docker-ops.git
cd docker-ops/backend

# 2. Tornar executável
chmod +x blueai-docker-ops.sh
chmod +x scripts/**/*.sh

# 3. Primeira execução
./blueai-docker-ops.sh setup
```

## 📋 Comandos Essenciais

### **🚀 Setup e Configuração**
```bash
./blueai-docker-ops.sh setup            # Configuração inicial completa
./blueai-docker-ops.sh config           # Configuração interativa
./blueai-docker-ops.sh schedule         # Configurar agendamento
./blueai-docker-ops.sh volumes          # Ver volumes configurados
./blueai-docker-ops.sh services         # Ver serviços configurados
```

### **📦 Backup e Recovery**
```bash
./blueai-docker-ops.sh backup           # Executar backup
./blueai-docker-ops.sh recovery         # Executar recovery
```

### **📊 Monitoramento e Gestão**
```bash
./blueai-docker-ops.sh status           # Status geral do sistema
./blueai-docker-ops.sh test             # Testar sistema completo
./blueai-docker-ops.sh logs             # Ver logs do sistema
./blueai-docker-ops.sh report           # Gerar relatórios
```

### **🔧 Instalação e Gestão**
```bash
./blueai-docker-ops.sh install          # Instalar sistema
./blueai-docker-ops.sh uninstall        # Desinstalar sistema
./blueai-docker-ops.sh advanced         # Comandos avançados
```
```bash
./blueai-docker-ops.sh status           # Status geral do sistema
./blueai-docker-ops.sh logs             # Ver logs do sistema
./blueai-docker-ops.sh report           # Gerar relatórios
```

### **🔧 Gestão**
```bash
./blueai-docker-ops.sh test             # Testar sistema completo
./blueai-docker-ops.sh install          # Instalar sistema
./blueai-docker-ops.sh uninstall        # Desinstalar sistema
```

### **🔍 Comandos Avançados**
```bash
./blueai-docker-ops.sh advanced         # Acesso a funcionalidades avançadas
```

## 🎯 Fluxo de Uso Típico

### **1. Configuração Inicial**
```bash
# Configuração completa
make setup

# Verificar status
./blueai-docker-ops.sh status
```

### **2. Operação Diária**
```bash
# Ver status
./blueai-docker-ops.sh status

# Executar backup
./blueai-docker-ops.sh backup

# Ver logs
./blueai-docker-ops.sh logs
```

### **3. Recuperação (se necessário)**
```bash
# Executar recovery
./blueai-docker-ops.sh recovery

# Verificar status
./blueai-docker-ops.sh status
```

## 🔧 Configuração Avançada

### **Personalizar Configurações**
```bash
# Editar configurações
nano config/backup-config.sh
nano config/recovery-config.sh
nano config/notification-config.sh

# Reconfigurar sistema
./blueai-docker-ops.sh config
```

### **Agendamento Personalizado**
```bash
# Ver status do agendamento
./blueai-docker-ops.sh status

# Configurar agendamento
./blueai-docker-ops.sh schedule
```

## 📊 Monitoramento e Relatórios

### **Logs Estruturados**
- **Logs de backup** - Todas as operações de backup
- **Logs de erro** - Erros e avisos do sistema
- **Logs de performance** - Métricas de execução
- **Logs do sistema** - Operações gerais

### **Relatórios HTML**
- **Relatórios de backup** - Status e resultados
- **Análise de logs** - Insights e tendências
- **Métricas de performance** - Tempo e recursos

## 🚨 Solução de Problemas

### **Comandos de Diagnóstico**
```bash
# Testar sistema completo
./blueai-docker-ops.sh test

# Ver logs de erro
./blueai-docker-ops.sh advanced

# Verificar configurações
./blueai-docker-ops.sh status
```

### **Problemas Comuns**
- **Docker não está rodando** - Iniciar Docker Desktop
- **Permissões negadas** - Verificar permissões de arquivos
- **Configuração incorreta** - Executar `./blueai-docker-ops.sh config`

## 📚 Documentação

### **Guias Disponíveis**
- 🚀 **[Guia de Início Rápido](docs/guia-inicio-rapido.md)** - Primeiros passos
- 📋 **[Comandos Detalhados](docs/comandos.md)** - Referência completa
- 🏗️ **[Arquitetura do Sistema](docs/arquitetura.md)** - Como funciona
- 🔧 **[Configuração Avançada](docs/configuracao.md)** - Personalizações
- 🆘 **[Solução de Problemas](docs/solucao-problemas.md)** - Troubleshooting

## 🚀 Distribuição e Instalação

### **Instalação Automática**
```bash
# Instalação em uma linha
curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install/install.sh | bash
```

### **Pacotes de Distribuição**
- **Releases automáticos** via GitHub Actions
- **Pacotes compactados** com versão
- **Templates limpos** sem dados locais
- **Instalador robusto** com verificações

## 🔮 Roadmap

### **Funcionalidades Futuras**
- 📈 **Backup incremental** para melhor performance
- 🌐 **Backup remoto** para servidores externos
- 🔐 **Criptografia** para backups sensíveis
- 📱 **Interface web** para monitoramento
- 📱 **App móvel** para notificações

## 🤝 Contribuindo

### **Como Contribuir**
1. **Fork** o repositório
2. **Crie** uma branch para sua feature
3. **Commit** suas mudanças
4. **Push** para a branch
5. **Abra** um Pull Request

### **Desenvolvimento**
```bash
# Setup de desenvolvimento
make dev-setup

# Testes
make test

# Validação
make validate

# Build
make build
```

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

### **Recursos de Ajuda**
- 📖 **Documentação completa:** [docs/](docs/)
- 🆘 **Solução de problemas:** [solucao-problemas.md](docs/solucao-problemas.md)
- 🐛 **Reportar bugs:** [Issues](https://github.com/blueai-solutions/docker-ops/issues)
- 💡 **Sugestões:** [Discussions](https://github.com/blueai-solutions/docker-ops/discussions)

### **Contato**
- **Email:** suporte@blueaisolutions.com.br
- **Website:** [blueaisolutions.com.br](https://blueaisolutions.com.br)
- **GitHub:** [blueai-solutions/docker-ops](https://github.com/blueai-solutions/docker-ops)

---

**🎉 BlueAI Docker Ops - Simples, Intuitivo e Eficiente!**

*Desenvolvido com ❤️ pela BlueAI Solutions*
