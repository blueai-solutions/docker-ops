# 🚀 Guia de Início Rápido - BlueAI Docker Ops

Este guia irá ajudá-lo a configurar e usar o BlueAI Docker Ops em poucos minutos.

## 📋 Pré-requisitos

- ✅ **Docker** instalado e funcionando
- ✅ **macOS** (para notificações nativas)
- ✅ **Bash** (já incluído no macOS)
- ✅ **Permissões** de escrita no diretório do projeto

## ⚡ Instalação Rápida

### **Download e Instalação em Uma Linha**

```bash
# Instalação automática da última versão
curl -sSL https://github.com/blueai-solutions/docker-ops/releases/latest/download/blueai-docker-ops-$(curl -s https://api.github.com/repos/blueai-solutions/docker-ops/releases/latest | grep -o '"tag_name": "[^"]*' | grep -o '[^"]*$' | sed 's/v//').tar.gz | tar -xz && cd blueai-docker-ops-* && ./blueai-docker-ops.sh setup
```

### **Download Manual (Mais Simples)**

```bash
# 1. Download da última versão
wget https://github.com/blueai-solutions/docker-ops/releases/latest/download/blueai-docker-ops-2.4.0.tar.gz

# 2. Extrair e instalar
tar -xzf blueai-docker-ops-2.4.0.tar.gz
cd blueai-docker-ops-2.4.0
./blueai-docker-ops.sh setup
```

### **Download via curl (Alternativo)**

```bash
# 1. Download via curl
curl -L -O https://github.com/blueai-solutions/docker-ops/releases/latest/download/blueai-docker-ops-2.4.0.tar.gz

# 2. Extrair e instalar
tar -xzf blueai-docker-ops-2.4.0.tar.gz
cd blueai-docker-ops-2.4.0
./blueai-docker-ops.sh setup
```

## 🎯 Configuração em 3 Passos

### **Passo 1: Configuração Inicial (Setup Completo)**

```bash
# Executar configuração completa do sistema
make setup

# OU usar o script diretamente
./blueai-docker-ops.sh setup
```

**O que acontece:**
1. ✅ **Configuração interativa** - Email e horário do backup
2. 🕐 **Agendamento automático** - LaunchAgent instalado
3. 🔧 **Instalação do sistema** - Comandos disponíveis no PATH

### **Passo 2: Verificar Volumes Configurados**

```bash
# Ver volumes configurados para backup
./blueai-docker-ops.sh volumes

# Ver status geral do sistema
./blueai-docker-ops.sh status
```

**O que fazer:**
1. ✅ **Verificar** se volumes estão configurados
2. ⚙️ **Configurar** se necessário: `./blueai-docker-ops.sh config`
3. 🔍 **Monitorar** status dos serviços

### **Passo 3: Executar Primeiro Backup**

```bash
# Executar backup manual
./blueai-docker-ops.sh backup

# Ver status do sistema
./blueai-docker-ops.sh status

# Ver logs do sistema
./blueai-docker-ops.sh logs
```

## 🚀 Comandos Essenciais

### **📋 Comandos Principais**
```bash
./blueai-docker-ops.sh --help           # Ver todos os comandos
./blueai-docker-ops.sh setup            # Configuração inicial
./blueai-docker-ops.sh config           # Configuração interativa
./blueai-docker-ops.sh schedule         # Configurar agendamento
./blueai-docker-ops.sh volumes          # Ver volumes configurados
./blueai-docker-ops.sh services         # Ver serviços configurados
./blueai-docker-ops.sh backup           # Executar backup
./blueai-docker-ops.sh recovery         # Executar recovery
./blueai-docker-ops.sh status           # Status geral do sistema
./blueai-docker-ops.sh test             # Testar sistema completo
```

### **📦 Comandos de Backup**
```bash
./blueai-docker-ops.sh backup           # Executar backup
```

### **📊 Monitoramento**
```bash
./blueai-docker-ops.sh logs             # Ver logs do sistema
./blueai-docker-ops.sh report           # Gerar relatórios
./blueai-docker-ops.sh advanced         # Comandos avançados
```

## 🔧 Configuração Avançada

### **Configurar Containers para Backup**

```bash
# Configuração interativa
./blueai-docker-ops.sh config

# O sistema irá:
# 1. Solicitar email para notificações
# 2. Configurar horário do backup automático
# 3. Criar configurações limpas usando templates
```

### **Configurar Agendamento**

```bash
# Ver status do agendamento
./blueai-docker-ops.sh status

# Configurar agendamento manual (se necessário)
./blueai-docker-ops.sh schedule
```

### **Testar Sistema**

```bash
# Teste completo do sistema
./blueai-docker-ops.sh test

# Testar notificações
./blueai-docker-ops.sh advanced
```

## 📁 Estrutura do Sistema

```
blueai-docker-ops/
├── 🐳 blueai-docker-ops.sh              # Script principal simplificado
├── 📁 config/                            # Configurações do sistema
│   ├── 📁 templates/                     # Templates limpos para distribuição (versionados)
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

## 🎯 Próximos Passos

### **1. Configuração Inicial**
- ✅ Execute `make setup` para configuração completa
- ✅ Configure email e horário do backup
- ✅ Verifique se o sistema está funcionando

### **2. Primeiro Uso**
- ✅ Execute `./blueai-docker-ops.sh backup` para primeiro backup
- ✅ Verifique logs com `./blueai-docker-ops.sh logs`
- ✅ Monitore status com `./blueai-docker-ops.sh status`

### **3. Configuração Avançada**
- ✅ Personalize configurações conforme necessário
- ✅ Configure containers específicos para backup
- ✅ Ajuste agendamento e notificações

## 🆘 Precisa de Ajuda?

- 📖 **Documentação completa:** [docs/](docs/)
- 🔧 **Solução de problemas:** [solucao-problemas.md](solucao-problemas.md)
- 📋 **Comandos detalhados:** [comandos.md](comandos.md)
- 🏗️ **Arquitetura:** [arquitetura.md](arquitetura.md)

---

**🎉 Parabéns! Você configurou o BlueAI Docker Ops com sucesso!**
