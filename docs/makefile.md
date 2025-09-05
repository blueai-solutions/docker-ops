# 🛠️ Makefile - BlueAI Docker Ops

## 📋 Visão Geral

O Makefile do BlueAI Docker Ops automatiza operações de desenvolvimento, teste e deploy, proporcionando uma experiência de desenvolvimento profissional e eficiente. **Para usuários finais, use o script principal `blueai-docker-ops.sh`**.

## 🎯 **Separação de Responsabilidades**

### **👨‍💻 Para Desenvolvedores (Makefile)**
- **Desenvolvimento** e testes
- **Build** e validação
- **Release** e deploy
- **Manutenção** do código

### **👤 Para Usuários Finais (blueai-docker-ops.sh)**
- **Setup** e configuração
- **Operação** diária
- **Backup** e recovery
- **Monitoramento** do sistema

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

### **🔧 Configuração (Alias para Script Principal)**
```bash
make setup             # Alias para ./blueai-docker-ops.sh setup
make config            # Alias para ./blueai-docker-ops.sh config
make schedule          # Alias para ./blueai-docker-ops.sh schedule
make status            # Alias para ./blueai-docker-ops.sh status
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
# Configuração completa em uma linha
make setup

# O sistema irá solicitar:
# 1. Email para notificações
# 2. Horário para backup automático
# 3. Confirmar configurações
```

### **🛠️ Desenvolvimento**
```bash
# Setup de desenvolvimento
make dev-setup

# Executar testes
make test

# Validação completa
make check-all
```

### **📦 Release e Deploy**
```bash
# Criar nova versão
make version-bump

# Criar release
make release-create

# Preparar deploy
make deploy-prep
```

## 🔧 **Comandos de Sistema (Alias)**

### **Setup e Configuração**
```bash
make setup             # Configuração inicial completa
make config            # Configuração interativa
make schedule          # Configurar agendamento
make status            # Status geral do sistema
```

**Estes comandos são aliases para o script principal:**
- `make setup` → `./blueai-docker-ops.sh setup`
- `make config` → `./blueai-docker-ops.sh config`
- `make schedule` → `./blueai-docker-ops.sh schedule`
- `make status` → `./blueai-docker-ops.sh status`

## 🚀 **Fluxo de Desenvolvimento**

### **1. Setup de Desenvolvimento**
```bash
# Configurar ambiente
make dev-setup

# Verificar status
make status
```

### **2. Desenvolvimento**
```bash
# Fazer alterações no código
# ...

# Validar sintaxe
make validate

# Executar testes
make test
```

### **3. Release**
```bash
# Incrementar versão
make version-bump

# Criar changelog
make changelog-create

# Criar release
make release-create
```

### **4. Deploy**
```bash
# Preparar pacote
make deploy-prep

# Criar distribuição
make package
```

## 📊 **Comandos por Categoria**

### **🔄 Sistema (Alias)**
- `setup` - Configuração inicial
- `config` - Configuração interativa
- `schedule` - Configurar agendamento
- `status` - Status geral

### **🛠️ Desenvolvimento**
- `dev-setup` - Setup de desenvolvimento
- `test` - Executar testes
- `validate` - Validar sintaxe
- `check` - Verificação completa

### **🏷️ Release**
- `version-bump` - Incrementar versão
- `changelog-create` - Criar changelog
- `release-create` - Criar release
- `release-status` - Status do repositório

### **📦 Deploy**
- `package` - Criar pacote
- `deploy-prep` - Preparar deploy
- `deploy-test` - Testar pacote

### **🧹 Manutenção**
- `clean` - Limpeza geral
- `clean-configs` - Limpar configurações
- `backup-configs` - Backup de configurações

## 🎯 **Quando Usar Cada Ferramenta**

### **Use `make` para:**
- ✅ **Desenvolvimento** e testes
- ✅ **Build** e validação
- ✅ **Release** e deploy
- ✅ **Manutenção** do código
- ✅ **Setup** de desenvolvimento

### **Use `./blueai-docker-ops.sh` para:**
- ✅ **Setup** inicial do sistema
- ✅ **Configuração** interativa
- ✅ **Operação** diária
- ✅ **Backup** e recovery
- ✅ **Monitoramento** do sistema

## 📚 **Documentação Relacionada**

### **Para Desenvolvedores**
- **Este documento** - Comandos do Makefile
- **Arquitetura** - [arquitetura.md](arquitetura.md)
- **Solução de Problemas** - [solucao-problemas.md](solucao-problemas.md)

### **Para Usuários Finais**
- **Guia de Início Rápido** - [guia-inicio-rapido.md](guia-inicio-rapido.md)
- **Comandos Detalhados** - [comandos.md](comandos.md)
- **Configuração** - [configuracao.md](configuracao.md)

## 🚨 **Solução de Problemas**

### **Comandos Não Encontrados**
```bash
# Ver todos os comandos disponíveis
make help

# Ver comandos específicos
make help-dev          # Comandos de desenvolvimento
make help-system       # Comandos de sistema (alias)
```

### **Permissões Negadas**
```bash
# Verificar permissões
ls -la Makefile

# Corrigir permissões se necessário
chmod 644 Makefile
```

### **Dependências Não Encontradas**
```bash
# Verificar se está no diretório correto
pwd
# Deve mostrar: .../blueai-docker-ops/backend

# Verificar se arquivos existem
ls -la blueai-docker-ops.sh
ls -la Makefile
```

## 🔮 **Funcionalidades Futuras**

### **Planejado para v2.5.0**
- **Interface web** para desenvolvimento
- **CI/CD integrado** com GitHub Actions
- **Testes automatizados** mais avançados
- **Deploy automático** para múltiplos ambientes

### **Roadmap de Longo Prazo**
- **Integração** com IDEs populares
- **Plugins** para extensibilidade
- **Machine learning** para otimização
- **Colaboração** em tempo real

---

**🛠️ Makefile para desenvolvimento, blueai-docker-ops.sh para usuários finais!**
