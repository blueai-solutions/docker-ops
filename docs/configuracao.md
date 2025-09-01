# 🔧 Configuração - BlueAI Docker Ops

## ⚠️ IMPORTANTE

**Este é um pacote de distribuição limpo que NÃO contém configurações específicas do ambiente local.**

## 📋 Configuração Inicial

### **1. Configuração Automática (Recomendado)**
```bash
# Configuração interativa
./scripts/utils/config-setup.sh --interactive

# Configuração automática com email
./scripts/utils/config-setup.sh --email seu@email.com

# Configuração com horário específico
./scripts/utils/config-setup.sh --schedule 2 --schedule-min 30
```

### **2. Configuração Manual**
```bash
# Copiar templates para configurações
cp config/templates/version-config.template.sh config/version-config.sh
cp config/templates/notification-config.template.sh config/notification-config.sh

# Editar configurações conforme necessário
nano config/version-config.sh
nano config/notification-config.sh
```

## 📁 Estrutura de Configuração

```
config/
├── templates/                    # Templates limpos
│   ├── version-config.template.sh
│   ├── notification-config.template.sh
│   ├── backup-config.template.sh
│   └── recovery-config.template.sh
└── backups/                      # Backups automáticos
```

## 🎯 O que o script de configuração faz

- ✅ Cria configurações limpas usando templates
- ✅ Faz backup das configurações existentes
- ✅ Configura email e horário automaticamente
- ✅ Garante que não haja informações locais
- ✅ Valida parâmetros de configuração
- ✅ Configura todos os arquivos de configuração

## 📧 Configurações Disponíveis

### **Versão e Sistema**
- Versão da aplicação
- Informações de build
- Configurações de agendamento
- URLs de atualização

### **Notificações**
- Email de destino
- Email de origem
- Som das notificações macOS
- Nível de log

### **Backup**
- Diretório de backup
- Configurações de retenção
- Containers para backup
- Configurações por container

### **Recuperação**
- Diretório de backups
- Containers para recuperação
- Configurações de rede
- Verificações de saúde

## 🚀 Exemplos de Uso

### **Configuração Rápida**
```bash
# Configurar email e horário padrão
./scripts/utils/config-setup.sh --email admin@empresa.com

# Configurar backup às 3:00 da manhã
./scripts/utils/config-setup.sh --schedule 3 --schedule-min 0

# Configuração completa interativa
./scripts/utils/config-setup.sh --interactive
```

### **Configuração Avançada**
```bash
# Forçar configuração sem confirmação
./scripts/utils/config-setup.sh --force --email admin@empresa.com

# Configuração personalizada
./scripts/utils/config-setup.sh \
  --email admin@empresa.com \
  --schedule 1 \
  --schedule-min 30
```

## 🔍 Verificação de Configuração

### **Verificar Configurações Atuais**
```bash
# Ver arquivo de versão
cat config/version-config.sh

# Ver arquivo de notificações
cat config/notification-config.sh

# Verificar se templates existem
ls -la config/templates/
```

### **Testar Configuração**
```bash
# Testar sistema com nova configuração
./blueai-docker-ops.sh --help

# Testar notificações
./blueai-docker-ops.sh notify-test

# Verificar agendamento
./scripts/install/install-launchagent.sh status
```

## 🛠️ Troubleshooting

### **Problemas Comuns**

#### **1. Template não encontrado**
```bash
# Verificar se templates existem
ls -la config/templates/

# Se não existir, recriar estrutura
mkdir -p config/templates
# Copiar templates do repositório
```

#### **2. Configuração não carregada**
```bash
# Verificar permissões
chmod +x scripts/utils/config-setup.sh

# Verificar sintaxe
bash -n config/version-config.sh
bash -n config/notification-config.sh
```

#### **3. Backup não criado**
```bash
# Verificar diretório de backups
ls -la config/backups/

# Criar diretório se não existir
mkdir -p config/backups
```

## 📚 Documentação Relacionada

- [Guia de Início Rápido](guia-inicio-rapido.md)
- [Comandos](comandos.md)
- [LaunchAgent](launchagent.md)
- [Solução de Problemas](solucao-problemas.md)

## 🆘 Suporte

- **📧 Email:** docker-ops@blueaisolutions.com.br
- **🐛 Issues:** https://github.com/blueai-solutions/docker-ops/issues
- **📖 Documentação:** https://github.com/blueai-solutions/docker-ops/tree/main/docs

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
