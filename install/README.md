# 🚀 Guia de Instalação - BlueAI Docker Ops

Guia completo para instalação e desinstalação do BlueAI Docker Ops em sistemas macOS.

## 📋 Pré-requisitos

### **Sistema Operacional**
- ✅ **macOS 10.15+** (Catalina ou superior)
- ✅ **Bash 4.0+** ou **Zsh 5.0+**
- ✅ **Usuário com permissões de administrador**

### **Docker**
- ✅ **Docker Desktop 20.10.0+** ou **Docker Engine 20.10.0+**
- ✅ **Docker rodando** e acessível
- ✅ **Permissões** para executar comandos Docker

### **Espaço em Disco**
- ✅ **Mínimo: 100MB** para instalação
- ✅ **Recomendado: 1GB+** para operações de backup

## ⚡ Instalação Rápida (Recomendado)

### **Instalação em Uma Linha**
```bash
curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install/install.sh | bash
```

### **Download e Execução Manual**
```bash
# 1. Download do script
curl -O https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install/install.sh

# 2. Tornar executável
chmod +x install.sh

# 3. Executar instalação
./install.sh
```

## 🔧 Instalação Manual (Desenvolvedores)

### **Clone do Repositório**
```bash
# Clone do repositório
git clone https://github.com/blueai-solutions/docker-ops.git
cd docker-ops/backend

# Tornar scripts executáveis
chmod +x blueai-docker-ops.sh
chmod +x scripts/**/*.sh

# Testar instalação
./blueai-docker-ops.sh --help
```

## 📁 Arquivos Disponíveis

### **🔧 Scripts de Instalação**
- **`install.sh`** - Instalador automático do sistema
- **`uninstall.sh`** - Desinstalador do sistema

## 🔄 Processo de Instalação Automática

### **Fase 1: Verificações Automáticas**
O instalador verifica automaticamente:

1. **✅ Sistema Operacional** - macOS 10.15+
2. **✅ Docker** - Instalado e rodando
3. **✅ Permissões** - Acesso de administrador
4. **✅ Espaço em Disco** - Mínimo 100MB
5. **✅ Dependências** - Bash/Zsh, comandos básicos

### **Fase 2: Instalação do Sistema**
1. **📁 Criação de diretórios** em `/usr/local/blueai-docker-ops/`
2. **📥 Download** do sistema do GitHub
3. **🔐 Configuração** de permissões
4. **🔗 Criação** de links simbólicos
5. **⚙️ Configuração** de variáveis de ambiente

### **Fase 3: Configuração e Teste**
1. **🧪 Teste** de funcionamento
2. **📝 Configuração** de ambiente
3. **✅ Validação** da instalação
4. **📚 Documentação** disponível

## 📁 Estrutura de Instalação

Após a instalação, o sistema estará organizado em:

```
/usr/local/blueai-docker-ops/
├── 📁 bin/                    # Scripts executáveis
│   └── blueai-docker-ops.sh   # Script principal
├── 📁 config/                 # Configurações do sistema
│   ├── version-config.sh      # Configuração de versão
│   ├── backup-config.sh       # Configuração de backup
│   ├── recovery-config.sh     # Configuração de recuperação
│   └── notification-config.sh # Configuração de notificações
├── 📁 scripts/                # Scripts do sistema
├── 📁 docs/                   # Documentação completa
├── 📁 logs/                   # Logs do sistema
└── 📁 backups/                # Backups dos volumes
```

## 🎯 Após a Instalação

### **Verificar Instalação**
```bash
# Verificar se está funcionando
blueai-docker-ops --help

# Ver status do sistema
blueai-docker-ops status
```

### **Configuração Inicial**
```bash
# Configuração completa do sistema
blueai-docker-ops setup

# Configurar containers para backup
blueai-docker-ops config

# Configurar agendamento automático
blueai-docker-ops schedule
```

### **Primeiro Backup**
```bash
# Executar backup manual
blueai-docker-ops backup

# Ver status
blueai-docker-ops status
```

## 🗑️ Desinstalação

### **Desinstalação Automática**
```bash
# Download do desinstalador
curl -O https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install/uninstall.sh

# Executar
chmod +x uninstall.sh
./uninstall.sh
```

### **Desinstalação Manual**
```bash
# 1. Parar serviços
sudo launchctl unload ~/Library/LaunchAgents/com.user.dockerbackup.plist

# 2. Remover arquivos
sudo rm -rf /usr/local/blueai-docker-ops
sudo rm -f /usr/local/bin/blueai-docker-ops

# 3. Remover LaunchAgent
rm -f ~/Library/LaunchAgents/com.user.dockerbackup.plist

# 4. Limpar variáveis de ambiente
# Editar ~/.zshrc ou ~/.bash_profile e remover linhas relacionadas
```

## 🚨 Solução de Problemas

### **Problemas Comuns**

#### **"Permissão Negada"**
```bash
# Verificar permissões
ls -la install.sh

# Corrigir permissões
chmod +x install.sh
```

#### **"Docker não encontrado"**
```bash
# Verificar se Docker está rodando
docker --version
docker ps

# Iniciar Docker Desktop se necessário
```

#### **"Espaço insuficiente"**
```bash
# Verificar espaço em disco
df -h

# Limpar arquivos temporários
./blueai-docker-ops.sh clean-data
```

#### **"Comando não encontrado" após instalação**
```bash
# Reiniciar terminal
# OU recarregar perfil
source ~/.zshrc
# OU
source ~/.bash_profile
```

### **Reset Completo (Emergência)**
```bash
# Se nada funcionar, reset completo
./blueai-docker-ops.sh factory-reset

# Reinstalar
./install.sh
```

## 📚 Documentação Completa

- **📋 [Comandos Detalhados](../docs/comandos.md)** - Referência completa de comandos
- **🚀 [Guia de Início Rápido](../docs/guia-inicio-rapido.md)** - Primeiros passos
- **🏗️ [Arquitetura do Sistema](../docs/arquitetura.md)** - Como funciona internamente
- **🔧 [Configurações Avançadas](../docs/configuracao.md)** - Personalizações
- **🆘 [Solução de Problemas](../docs/solucao-problemas.md)** - Troubleshooting
- **🚨 [Reset e Limpeza](../docs/reset-e-limpeza.md)** - Comandos de emergência

## 🆘 Suporte

- **🐛 Issues**: [GitHub Issues](https://github.com/blueai-solutions/docker-ops/issues)
- **📧 Email**: docker-ops@blueaisolutions.com.br
- **📖 Documentação**: [docs/](../docs/)

## 🔄 Atualizações

### **Atualização Automática**
```bash
# Atualizar sistema
blueai-docker-ops update

# Verificar versão
blueai-docker-ops version
```

### **Atualização Manual**
```bash
# Baixar nova versão
git pull origin main

# Reinstalar
./install.sh
```

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
