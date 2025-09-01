# 🛠️ Makefile - BlueAI Docker Ops

## 📋 Visão Geral

O Makefile do BlueAI Docker Ops automatiza todas as operações de desenvolvimento, teste, configuração e deploy, proporcionando uma experiência de desenvolvimento profissional e eficiente.

## 🚀 **Comandos Principais**

### **📖 Ajuda Geral**
```bash
make help              # Mostrar todos os comandos disponíveis
make info              # Informações do projeto
make status            # Status completo do projeto
```

### **🛠️ Desenvolvimento**
```bash
make dev-setup         # Configurar ambiente de desenvolvimento
make test              # Executar testes do sistema
make validate          # Validar sintaxe dos scripts
make check             # Verificação completa (validate + test)
make check-all         # Verificação com configurações limpas
```

### **🔧 Configuração**
```bash
make config-clean      # Limpar configurações usando templates
make config-interactive # Configuração interativa
make config-email      # Configurar email
make config-schedule   # Configurar horário
make backup-configs    # Backup das configurações atuais
```

### **🚀 LaunchAgent**
```bash
make launchagent-install   # Instalar LaunchAgent
make launchagent-status    # Verificar status
make launchagent-schedule  # Configurar horário
make launchagent-test      # Testar funcionamento
make launchagent-uninstall # Desinstalar
```

### **🏷️ Releases e Desenvolvimento**
```bash
make dev-tools         # Mostrar ferramentas disponíveis
make changelog-create  # Criar entrada de changelog
make release-create    # Criar nova release
make version-bump      # Incrementar versão
make release-status    # Verificar status do repositório
```

### **🧹 Limpeza e Manutenção**
```bash
make clean             # Limpar arquivos temporários
make clean-configs     # Limpar configurações
make backup-configs    # Backup das configurações
```

### **📦 Instalação e Distribuição**
```bash
make install-local     # Instalar localmente
make uninstall-local   # Desinstalar localmente
make package           # Criar pacote de distribuição
```

## 🎯 **Comandos Especiais**

### **🚀 Início Rápido**
```bash
make quick-start       # Configuração completa em uma linha
```

### **🔍 Verificação Completa**
```bash
make check-all         # Validação + testes + configurações limpas
```

### **📦 Preparação para Deploy**
```bash
make deploy-prep       # Verificação completa + pacote
```

### **⚠️ Emergência**
```bash
make emergency-clean   # Limpeza de emergência (CUIDADO!)
```

## 📋 **Exemplos de Uso**

### **🔧 Configuração Rápida**
```bash
# Configurar email
make config-email EMAIL=admin@empresa.com

# Configurar horário do backup
make config-schedule HOUR=2 MIN=30

# Configuração interativa completa
make config-interactive
```

### **🏷️ Gerenciamento de Versões**
```bash
# Incrementar versão minor
make version-bump TYPE=minor

# Criar release específica
make release-create VERSION=2.4.0

# Verificar status
make release-status
```

### **🚀 Configuração Completa**
```bash
# Configuração completa do projeto
make all

# Início rápido para desenvolvimento
make quick-start

# Preparar para deploy
make deploy-prep
```

## 🏗️ **Estrutura do Makefile**

### **📁 Seções Organizadas:**
```
1. DESENVOLVIMENTO      - Setup, testes, validação
2. CONFIGURAÇÃO         - Templates, configurações limpas
3. LAUNCHAGENT         - Instalação e gerenciamento
4. DESENVOLVIMENTO     - Releases, changelog, versões
5. LIMPEZA             - Manutenção e limpeza
6. INSTALAÇÃO          - Instalação local e distribuição
7. VERIFICAÇÃO         - Validação e testes
8. AJUDA               - Comandos de ajuda específicos
9. TARGETS ESPECIAIS   - Comandos compostos
10. INFORMAÇÕES        - Status e informações do projeto
11. EMERGÊNCIA         - Comandos de emergência
```

### **🎨 Recursos Visuais:**
- **Cores** para diferentes tipos de mensagens
- **Emojis** para identificação visual
- **Logs estruturados** com timestamps
- **Validação de parâmetros** com mensagens claras

## 🔧 **Funcionalidades Avançadas**

### **✅ Validação Automática:**
- Verificação de sintaxe de todos os scripts
- Validação de parâmetros obrigatórios
- Verificação de dependências
- Testes automáticos do sistema

### **🔄 Configuração Inteligente:**
- Uso automático de templates
- Backup automático de configurações existentes
- Validação de parâmetros de entrada
- Configuração interativa e automática

### **📦 Empacotamento Inteligente:**
- Exclusão automática de arquivos de desenvolvimento
- Exclusão de configurações locais
- Inclusão apenas de templates limpos
- Criação de pacotes otimizados para usuários

### **🚀 Automação Completa:**
- Setup automático do ambiente
- Configuração automática de todos os componentes
- Testes automáticos de funcionalidade
- Preparação automática para deploy

## 🆘 **Troubleshooting**

### **❌ Problemas Comuns:**

#### **1. Comando não encontrado**
```bash
# Verificar se make está instalado
which make

# Verificar se está no diretório correto
pwd
ls -la Makefile
```

#### **2. Permissões negadas**
```bash
# Verificar permissões
ls -la scripts/**/*.sh

# Corrigir permissões
make dev-setup
```

#### **3. Configuração falhou**
```bash
# Verificar templates
ls -la config/templates/

# Fazer backup e limpar
make backup-configs
make config-clean
```

#### **4. Testes falharam**
```bash
# Verificar sintaxe primeiro
make validate

# Executar testes específicos
make test-notifications
```

### **🔍 Debug e Logs:**
```bash
# Ver status completo
make status

# Ver informações do projeto
make info

# Verificar configurações
make help-config
```

## 📚 **Integração com Outras Ferramentas**

### **🔗 GitHub Actions:**
- O Makefile complementa os workflows do GitHub
- Comandos `make deploy-prep` preparam para CI/CD
- Validação local antes do push

### **🐳 Docker:**
- Comandos de configuração funcionam com containers
- Templates são compatíveis com ambientes Docker
- Validação de configurações Docker

### **📝 Scripts:**
- Todos os comandos do Makefile usam scripts existentes
- Integração perfeita com a arquitetura atual
- Extensibilidade para novos comandos

## 🚀 **Fluxo de Trabalho Recomendado**

### **👨‍💻 Para Desenvolvedores:**
```bash
# 1. Setup inicial
make dev-setup

# 2. Desenvolvimento
# ... trabalhar no código ...

# 3. Validação
make check

# 4. Testes
make test

# 5. Preparar para commit
make check-all
```

### **🏷️ Para Releases:**
```bash
# 1. Verificar status
make release-status

# 2. Incrementar versão
make version-bump TYPE=minor

# 3. Criar changelog
make changelog-create

# 4. Criar release
make release-create VERSION=2.4.0

# 5. Preparar deploy
make deploy-prep
```

### **🔧 Para Configuração:**
```bash
# 1. Backup das configurações atuais
make backup-configs

# 2. Configuração limpa
make config-clean

# 3. Configuração personalizada
make config-email EMAIL=admin@empresa.com
make config-schedule HOUR=2 MIN=30

# 4. Testar configuração
make test
```

## 📖 **Referências**

- **Documentação Make:** https://www.gnu.org/software/make/
- **Sintaxe Makefile:** https://makefiletutorial.com/
- **Boas Práticas:** https://clarkgrubb.com/makefile-style-guide

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
