# 🚀 Workflow de Deploy - BlueAI Docker Ops

## 📋 Sequência Completa do Workflow de Deploy

### **1. 🏗️ Desenvolvimento e Preparação**

```bash
# 1.1 - Configuração do ambiente de desenvolvimento
make dev-setup

# 1.2 - Desenvolvimento e testes
make test
make validate
make check

# 1.3 - Preparação para release
make release-validate
make release-notes
```

### **2. 🏷️ Criação de Release**

```bash
# 2.1 - Criar tag de versão
git tag v2.4.0
git push origin v2.4.0

# 2.2 - Ou usar o script de release
./scripts/dev/release-manager.sh create v2.4.0
```

### **3. 🔄 GitHub Actions - Workflow Automático**

#### **3.1 - Build e Testes (`build.yml`)**
**Trigger:** Push/PR para `main` ou branches `release/*`

```
📥 Checkout do código
    ↓
🐳 Configurar Docker
    ↓
🔧 Configurar Bash
    ↓
📋 Verificar estrutura do projeto
    ↓
✅ Validar sintaxe bash
    ↓
🔐 Verificar permissões
    ↓
🧪 Testes básicos do sistema
    ↓
📊 Relatório de qualidade
    ↓
📦 Preparação para Release (se main)
```

#### **3.2 - Release Automático (`release.yml`)**
**Trigger:** Criação de tags `v*`

```
📥 Checkout do código
    ↓
🏷️ Obter informações da tag
    ↓
📋 Gerar release notes do changelog
    ↓
🏷️ Criar Release no GitHub
    ↓
📤 Upload assets
    ↓
🎯 Status final
```

#### **3.3 - Deploy e Distribuição (`deploy.yml`)**
**Trigger:** Release publicado ou manual

```
📥 Checkout do código
    ↓
🏷️ Obter informações da release
    ↓
🔧 Preparar arquivos de distribuição
    ↓
📦 Criar arquivo compactado
    ↓
📤 Upload assets para release
    ↓
📊 Relatório de distribuição
    ↓
🎯 Status final
```

### **4. 📦 Conteúdo do Pacote de Distribuição**

#### **✅ INCLUÍDO no pacote:**
- **Scripts de uso:** `core/`, `backup/`, `notifications/`, `logging/`
- **Utilitários para usuários:** `container-configurator.sh`, `recovery-configurator.sh`, `test-system.sh`
- **Scripts de instalação:** `install-launchagent.sh`
- **Templates de configuração:** `config/templates/` (NÃO configurações locais)
- **Documentação de uso:** `README.md`, `guia-inicio-rapido.md`, `comandos.md`, etc.
- **Scripts de instalação do sistema:** `install/`
- **Script principal:** `blueai-docker-ops.sh`
- **Changelog:** Apenas histórico para usuários

#### **❌ EXCLUÍDO do pacote:**
- **Scripts de desenvolvimento:** `scripts/dev/` (release management, changelog management)
- **Configurações locais:** `backup-config.sh`, `recovery-config.sh`, etc.
- **Documentação técnica:** Desenvolvimento e arquitetura interna
- **Workflows:** `.github/workflows/`
- **Makefile:** Ferramenta de desenvolvimento
- **Templates de issues/PRs:** `.github/ISSUE_TEMPLATE/`

### **5. 🎯 Comandos de Deploy Local**

```bash
# 5.1 - Deploy completo
make deploy

# 5.2 - Deploy passo a passo
make deploy-prepare    # Preparar pacote
make deploy-package    # Criar arquivo compactado
make deploy-test       # Testar pacote localmente

# 5.3 - Verificar resultado
ls -la blueai-docker-ops-*.tar.gz
```

### **6. 📊 Estrutura Final do Pacote**

```
blueai-docker-ops-2.4.0.tar.gz
├── blueai-docker-ops.sh          # Script principal
├── VERSION                        # Versão atual
├── README.md                      # Documentação principal
├── scripts/                       # Scripts organizados
│   ├── core/                      # Scripts principais
│   ├── backup/                    # Sistema de backup
│   ├── notifications/             # Sistema de notificações
│   ├── logging/                   # Sistema de logs
│   ├── utils/                     # Utilitários para usuários
│   └── install/                   # Scripts de instalação
├── config/                        # Templates de configuração
│   └── templates/                 # Templates limpos
├── install/                       # Scripts de instalação do sistema
└── docs/                          # Documentação de uso
    ├── README.md
    ├── guia-inicio-rapido.md
    ├── comandos.md
    ├── arquitetura.md
    ├── solucao-problemas.md
    ├── launchagent.md
    └── changelog/                 # Histórico para usuários
```

### **7. 🚀 Instalação pelo Usuário Final**

```bash
# 7.1 - Download do release
wget https://github.com/blueai-solutions/docker-ops/releases/download/v2.4.0/blueai-docker-ops-2.4.0.tar.gz

# 7.2 - Extrair e instalar
tar -xzf blueai-docker-ops-2.4.0.tar.gz
cd blueai-docker-ops-2.4.0
./blueai-docker-ops.sh setup

# 7.3 - Configurar sistema
./blueai-docker-ops.sh config
./blueai-docker-ops.sh schedule
```

## 🎯 **Resumo do Workflow**

1. **Desenvolvimento** → Testes → Validação
2. **Tag de versão** → GitHub Actions
3. **Build automático** → Testes → Validação
4. **Release automático** → Changelog → GitHub Release
5. **Deploy automático** → Pacote otimizado → Upload
6. **Distribuição** → Download → Instalação pelo usuário

## 🔧 **Comandos Essenciais**

```bash
# Desenvolvimento
make dev-setup test validate

# Release
git tag v2.4.0 && git push origin v2.4.0

# Deploy local
make deploy

# Verificar
make info
```

## 📋 **Separação de Responsabilidades**

- **👨‍💻 Repositório:** Desenvolvimento completo, scripts de release, workflows
- **📦 Pacote:** Apenas funcionalidades para usuários finais, sem código de desenvolvimento
- **🚀 GitHub Actions:** Automação completa do processo de release e deploy
- **👤 Usuário Final:** Download, instalação e uso do sistema
