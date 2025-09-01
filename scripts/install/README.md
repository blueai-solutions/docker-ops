# 🚀 Scripts de Instalação - BlueAI Docker Ops

Esta pasta contém scripts relacionados à instalação e configuração do sistema.

## 📋 Scripts Disponíveis

### **🔧 Instalação do LaunchAgent**
- **`install-launchagent.sh`** - Gerenciador do LaunchAgent para macOS
  - Instalar LaunchAgent
  - Configurar agendamento
  - Alterar horários
  - Testar funcionamento
  - Desinstalar

## 🚀 Como Usar

### **Instalar LaunchAgent**
```bash
# Ver ajuda
./scripts/install/install-launchagent.sh --help

# Instalar LaunchAgent
./scripts/install/install-launchagent.sh install

# Configurar horário
./scripts/install/install-launchagent.sh schedule

# Testar funcionamento
./scripts/install/install-launchagent.sh test-launchagent

# Ver status
./scripts/install/install-launchagent.sh status

# Desinstalar
./scripts/install/install-launchagent.sh uninstall
```

## 🎯 Funcionalidades

### **Sistema de Agendamento Inteligente**
- Configuração automática de horários
- Sincronização com arquivo de configuração
- Backup automático de configurações
- Testes de funcionamento
- Logs detalhados

### **Configuração Dinâmica**
- Geração automática de arquivos `.plist`
- Atualização de configurações
- Backup de arquivos modificados
- Validação de parâmetros

## 📚 Documentação Relacionada

- [LaunchAgent e Agendamento](../../docs/launchagent.md)
- [Guia de Início Rápido](../../docs/guia-inicio-rapido.md)
- [Comandos](../../docs/comandos.md)
- [Solução de Problemas](../../docs/solucao-problemas.md)

## 🆘 Suporte

- **📧 Email:** docker-ops@blueaisolutions.com.br
- **🐛 Issues:** https://github.com/blueai-solutions/docker-ops/issues
- **📖 Documentação:** https://github.com/blueai-solutions/docker-ops/tree/main/docs

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
