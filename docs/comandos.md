# 📋 Comandos Detalhados - BlueAI Docker Ops

Referência completa de todos os comandos disponíveis no sistema simplificado.

## 🐳 Script Principal

### **blueai-docker-ops.sh**

O script principal que unifica todas as funcionalidades do sistema.

```bash
./blueai-docker-ops.sh [COMANDO]
```

## 🚀 Comandos Essenciais

### **Setup e Configuração**

```bash
# Configuração inicial completa do sistema
./blueai-docker-ops.sh setup

# Configuração interativa
./blueai-docker-ops.sh config

# Configurar agendamento
./blueai-docker-ops.sh schedule

# Ver volumes configurados
./blueai-docker-ops.sh volumes

# Status geral do sistema
./blueai-docker-ops.sh status

# Testar sistema completo
./blueai-docker-ops.sh test
```

### **Instalação e Gestão**

```bash
# Instalar sistema
./blueai-docker-ops.sh install

# Desinstalar sistema
./blueai-docker-ops.sh uninstall
```

## 📦 Comandos de Backup

### **Execução de Backup**

```bash
# Executar backup
./blueai-docker-ops.sh backup

# Listar backups disponíveis
./blueai-docker-ops.sh backup-list

# Restaurar backup específico
./blueai-docker-ops.sh backup-restore [ARQUIVO]
```

### **Exemplos de Uso**

```bash
# Fazer backup manual
./blueai-docker-ops.sh backup

# Ver backups disponíveis
./blueai-docker-ops.sh backup-list

# Restaurar backup específico
./blueai-docker-ops.sh backup-restore backup_20250104_120000.tar.gz
```

## 🔄 Comandos de Recovery

### **Execução de Recovery**

```bash
# Executar recovery
./blueai-docker-ops.sh recovery
```

### **Exemplos de Uso**

```bash
# Executar recovery de todos os serviços configurados
./blueai-docker-ops.sh recovery
```

## 📊 Monitoramento

### **Logs e Relatórios**

```bash
# Ver logs do sistema
./blueai-docker-ops.sh logs

# Gerar relatórios
./blueai-docker-ops.sh report
```

### **Exemplos de Uso**

```bash
# Ver logs do sistema
./blueai-docker-ops.sh logs

# Gerar relatórios
./blueai-docker-ops.sh report
```

## 🔧 Comandos Avançados

### **Acesso a Funcionalidades Avançadas**

```bash
# Mostrar comandos avançados disponíveis
./blueai-docker-ops.sh advanced
```

### **Comandos Avançados Disponíveis**

```bash
# Backup avançado
backup run      # Executar backup completo
backup validate # Validar configuração
backup test     # Testar backup

# Logs avançados
logs --last-24h     # Logs das últimas 24 horas
logs --errors       # Apenas erros
logs --performance  # Análise de performance
logs --search TEXT  # Buscar nos logs

# Relatórios avançados
report html     # Gerar relatório HTML
report text     # Gerar relatório de texto
report export   # Exportar dados

# Recovery avançado
config                # Configurar volumes e serviços
recovery validate     # Validar configuração
recovery start        # Iniciar recuperação
recovery stop         # Parar recuperação

# Automação
automation install     # Instalar LaunchAgent
automation status      # Verificar status
automation test        # Testar automação

# Desenvolvimento
version               # Informações da versão
changelog             # Changelog
compatibility         # Verificar compatibilidade
stats                 # Estatísticas do sistema
```

## 🎯 Comandos por Categoria

### **🔄 Backup e Recovery**
- `backup` - Executar backup
- `backup-list` - Listar backups
- `backup-restore` - Restaurar backup
- `recovery` - Executar recovery

### **⚙️ Configuração**
- `setup` - Configuração inicial
- `config` - Configuração interativa
- `schedule` - Configurar agendamento
- `volumes` - Ver volumes configurados

### **📊 Monitoramento**
- `status` - Status geral do sistema
- `logs` - Ver logs do sistema
- `report` - Gerar relatórios
- `test` - Testar sistema completo

### **🔧 Gestão**
- `install` - Instalar sistema
- `uninstall` - Desinstalar sistema
- `advanced` - Comandos avançados

## 📋 Exemplos Práticos

### **Configuração Inicial**

```bash
# 1. Configuração completa
./blueai-docker-ops.sh setup

# 2. Verificar status
./blueai-docker-ops.sh status

# 3. Ver volumes configurados
./blueai-docker-ops.sh volumes
```

### **Operação Diária**

```bash
# 1. Ver status do sistema
./blueai-docker-ops.sh status

# 2. Executar backup
./blueai-docker-ops.sh backup

# 3. Ver logs
./blueai-docker-ops.sh logs

# 4. Gerar relatório
./blueai-docker-ops.sh report
```

### **Troubleshooting**

```bash
# 1. Testar sistema
./blueai-docker-ops.sh test

# 2. Ver logs de erro
./blueai-docker-ops.sh advanced

# 3. Verificar configurações
./blueai-docker-ops.sh status
```

## 🚨 Comandos de Emergência

### **Recuperação Rápida**

```bash
# 1. Executar recovery
./blueai-docker-ops.sh recovery

# 2. Verificar status
./blueai-docker-ops.sh status

# 3. Ver logs
./blueai-docker-ops.sh logs
```

### **Backup de Emergência**

```bash
# 1. Fazer backup imediato
./blueai-docker-ops.sh backup

# 2. Verificar se foi criado
./blueai-docker-ops.sh backup-list
```

## 📚 Ajuda e Suporte

### **Comandos de Ajuda**

```bash
# Ajuda principal
./blueai-docker-ops.sh --help
./blueai-docker-ops.sh -h
./blueai-docker-ops.sh help

# Ajuda para comandos avançados
./blueai-docker-ops.sh advanced
```

### **Informações do Sistema**

```bash
# Ver versão
./blueai-docker-ops.sh --version

# Ver informações do sistema
./blueai-docker-ops.sh status
```

## 🔍 Dicas de Uso

### **1. Sempre comece com `setup`**
```bash
./blueai-docker-ops.sh setup
```

### **2. Use `status` para verificar o sistema**
```bash
./blueai-docker-ops.sh status
```

### **3. Use `advanced` para funcionalidades extras**
```bash
./blueai-docker-ops.sh advanced
```

### **4. Use `test` para validar configurações**
```bash
./blueai-docker-ops.sh test
```

## 📖 Próximos Passos

- 🏗️ **[Arquitetura do Sistema](arquitetura.md)** - Como o sistema funciona
- 🔧 **[Configuração Avançada](configuracao.md)** - Personalizações
- 🆘 **[Solução de Problemas](solucao-problemas.md)** - Troubleshooting
- 🚀 **[Guia de Início Rápido](guia-inicio-rapido.md)** - Primeiros passos

---

**🎯 Sistema simplificado com 8 comandos essenciais para operação diária!**
