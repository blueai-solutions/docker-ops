# 🚀 Guia de Instalação - BlueAI Docker Ops

Este guia irá ajudá-lo a instalar o BlueAI Docker Ops em seu sistema macOS.

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

## 🎯 Métodos de Instalação

### **1. Instalação Automática (Recomendado)**

#### **Via Curl (Recomendado)**
```bash
# Instalação em uma linha
curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install.sh | bash
```

#### **Via Wget**
```bash
# Se você tem wget instalado
wget -qO- https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install.sh | bash
```

#### **Download e Execução Manual**
```bash
# 1. Download do script
curl -O https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install.sh

# 2. Tornar executável
chmod +x install.sh

# 3. Executar instalação
./install.sh
```

### **2. Instalação Manual (Desenvolvedores)**

#### **Clone do Repositório**
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

## 🔧 Processo de Instalação Automática

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
│   ├── 📁 core/               # Scripts principais
│   ├── 📁 backup/             # Sistema de backup
│   ├── 📁 notifications/      # Sistema de notificações
│   ├── 📁 logging/            # Sistema de logs
│   └── 📁 utils/              # Utilitários
├── 📁 docs/                   # Documentação completa
├── 📁 logs/                   # Logs do sistema
├── 📁 backups/                # Backups dos volumes
├── 📁 reports/                # Relatórios gerados
├── 📁 examples/               # Exemplos de uso
└── 📄 VERSION                 # Versão do sistema
```

## 🔗 Comandos Disponíveis

Após a instalação, você terá acesso aos comandos:

```bash
# Comando principal
blueai-docker-ops --help

# Alias alternativo
docker-ops --help

# Verificar versão
blueai-docker-ops --version
```

## ⚙️ Configuração Pós-Instalação

### **1. Configurar Containers para Backup**
```bash
# Configuração interativa
blueai-docker-ops config containers
```

### **2. Configurar Recuperação**
```bash
# Configuração de recuperação
blueai-docker-ops recovery config
```

### **3. Configurar Notificações**
```bash
# Testar notificações
blueai-docker-ops notify-test
```

### **4. Configurar LaunchAgent (Agendamento)**
```bash
# Instalar agendamento automático
blueai-docker-ops automação install
```

## 🧪 Teste da Instalação

### **Teste Completo do Sistema**
```bash
# Executar teste completo
blueai-docker-ops test-system
```

### **Teste de Funcionalidades**
```bash
# Testar backup
blueai-docker-ops backup

# Testar recuperação
blueai-docker-ops recover

# Verificar status
blueai-docker-ops status
```

## 🚨 Solução de Problemas

### **Problemas Comuns**

#### **1. "Permissão Negada"**
```bash
# Verificar permissões
ls -la /usr/local/blueai-docker-ops/

# Corrigir permissões
sudo chown -R $(whoami):staff /usr/local/blueai-docker-ops/
```

#### **2. "Comando não encontrado"**
```bash
# Verificar PATH
echo $PATH

# Recarregar shell
source ~/.zshrc  # ou ~/.bash_profile
```

#### **3. "Docker não está rodando"**
```bash
# Iniciar Docker Desktop
open -a Docker

# Verificar status
docker info
```

#### **4. "Falha na instalação"**
```bash
# Verificar logs
tail -f /tmp/blueai-install.log

# Reinstalar
./install.sh
```

### **Logs de Instalação**
```bash
# Log principal
/usr/local/blueai-docker-ops/logs/install.log

# Log de configuração
/usr/local/blueai-docker-ops/logs/setup.log
```

## 🔄 Atualização do Sistema

### **Verificar Atualizações**
```bash
# Verificar se há atualizações
blueai-docker-ops update-check
```

### **Atualizar Sistema**
```bash
# Desinstalar versão atual
./uninstall.sh

# Instalar nova versão
curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install.sh | bash
```

## 🗑️ Desinstalação

### **Desinstalação Interativa**
```bash
# Executar desinstalador
./uninstall.sh
```

### **Desinstalação Forçada**
```bash
# Desinstalar sem confirmação
./uninstall.sh --force
```

### **O que é Removido**
- ✅ **Sistema completo** em `/usr/local/blueai-docker-ops/`
- ✅ **Comandos** `blueai-docker-ops` e `docker-ops`
- ✅ **LaunchAgent** e agendamentos
- ✅ **Variáveis de ambiente** do shell
- ✅ **Logs temporários**

### **O que NÃO é Removido**
- ❌ **Seus backups** de dados Docker
- ❌ **Configurações personalizadas**
- ❌ **Logs de operações** anteriores

## 📚 Próximos Passos

Após a instalação bem-sucedida:

1. **📖 Leia a documentação**: `/usr/local/blueai-docker-ops/docs/`
2. **🚀 Configure containers**: `blueai-docker-ops config containers`
3. **🧪 Teste o sistema**: `blueai-docker-ops test-system`
4. **⏰ Configure agendamento**: `blueai-docker-ops automação install`
5. **📊 Execute primeiro backup**: `blueai-docker-ops backup`

## 🆘 Suporte

### **Documentação**
- **📖 Guia de Início Rápido**: `/usr/local/blueai-docker-ops/docs/guia-inicio-rapido.md`
- **📋 Comandos**: `/usr/local/blueai-docker-ops/docs/comandos.md`
- **🏗️ Arquitetura**: `/usr/local/blueai-docker-ops/docs/arquitetura.md`
- **🚨 Solução de Problemas**: `/usr/local/blueai-docker-ops/docs/solucao-problemas.md`

### **Comunidade**
- **🐛 Issues**: [GitHub Issues](https://github.com/blueai-solutions/docker-ops/issues)
- **💬 Discussões**: [GitHub Discussions](https://github.com/blueai-solutions/docker-ops/discussions)
- **📧 Email**: docker-ops@blueaisolutions.com.br

### **Recursos Adicionais**
- **🌐 Website**: [blueaisolutions.com.br](https://blueaisolutions.com.br)
- **📱 LinkedIn**: [BlueAI Solutions](https://linkedin.com/company/blueai-solutions)

---

## 🎉 Instalação Concluída!

Parabéns! Você instalou com sucesso o **BlueAI Docker Ops** em seu sistema.

**Para começar a usar:**
```bash
blueai-docker-ops --help
```

**Para configurar containers:**
```bash
blueai-docker-ops config containers
```

**Para executar primeiro backup:**
```bash
blueai-docker-ops backup
```

---

**Desenvolvido com ❤️ pela BlueAI Solutions**

*"Automatizando o backup de containers Docker com inteligência"*
