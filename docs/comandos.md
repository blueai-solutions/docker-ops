# 📋 Comandos Detalhados - Sistema de Backup Docker

Referência completa de todos os comandos disponíveis no sistema.

## 🐳 Script Principal

### **blueai-docker-ops.sh**

O script principal que unifica todas as funcionalidades do sistema.

```bash
./blueai-docker-ops.sh [COMANDO] [OPÇÕES]
```

## 🔄 Comandos de Backup

### **Backup Dinâmico**

```bash
# Executar backup dinâmico (recomendado)
./blueai-docker-ops.sh backup

# Backup dinâmico explícito
./blueai-docker-ops.sh dynamic backup

# Listar containers configurados para backup
./blueai-docker-ops.sh dynamic list

# Validar configuração de backup
./blueai-docker-ops.sh dynamic validate

# Testar backup sem executar
./blueai-docker-ops.sh dynamic test
```

### **Gerenciamento de Backups**

```bash
# Listar backups disponíveis
./blueai-docker-ops.sh backup list

# Restaurar backup específico
./blueai-docker-ops.sh backup restore [arquivo.tar.gz]

# Executar backup completo
./blueai-docker-ops.sh backup run
```

## 🔄 Comandos de Recuperação

### **Recuperação Dinâmica**

```bash
# Recuperar todos os containers configurados
./blueai-docker-ops.sh recover

# Configurar recuperação interativamente
./blueai-docker-ops.sh recovery config

# Listar containers configurados para recuperação
./blueai-docker-ops.sh recovery list

# Preview da configuração de recuperação
./blueai-docker-ops.sh recovery preview

# Validar configuração de recuperação
./blueai-docker-ops.sh recovery validate

# Resetar configuração de recuperação
./blueai-docker-ops.sh recovery reset

# Iniciar recuperação de containers
./blueai-docker-ops.sh recovery start

# Parar recuperação de containers
./blueai-docker-ops.sh recovery stop

# Status da recuperação
./blueai-docker-ops.sh recovery status

# Logs da recuperação
./blueai-docker-ops.sh recovery logs
```

## ⚙️ Comandos de Configuração

### **Configuração de Containers**

```bash
# Configurar containers para backup (interativo)
./blueai-docker-ops.sh config containers

# Preview da configuração de containers
./blueai-docker-ops.sh config preview

# Validar configuração de containers
./blueai-docker-ops.sh config validate

# Resetar configuração de containers
./blueai-docker-ops.sh config reset

# Testar configurações
./blueai-docker-ops.sh config test

# Editar configurações
./blueai-docker-ops.sh config edit
```

### **Gerenciamento de Backups de Configuração**

```bash
# Listar backups de configuração
./blueai-docker-ops.sh config backups list

# Restaurar backup de configuração
./blueai-docker-ops.sh config backups restore [arquivo]

# Limpar backups antigos
./blueai-docker-ops.sh config backups clean [dias]

# Informações do backup
./blueai-docker-ops.sh config backups info [arquivo]

# Comparar backup com configuração atual
./blueai-docker-ops.sh config backups diff [arquivo]
```

## 📊 Comandos de Monitoramento

### **Status e Informações**

```bash
# Verificar status dos containers
./blueai-docker-ops.sh status

# Analisar logs do sistema
./blueai-docker-ops.sh logs

# Monitorar logs em tempo real
./blueai-docker-ops.sh monitor
```

### **Análise de Logs**

```bash
# Logs das últimas 24 horas
./blueai-docker-ops.sh logs --last-24h

# Apenas erros
./blueai-docker-ops.sh logs --errors

# Análise de performance
./blueai-docker-ops.sh logs --performance

# Estatísticas gerais
./blueai-docker-ops.sh logs --stats

# Buscar nos logs
./blueai-docker-ops.sh logs --search "texto"

# Exportar logs
./blueai-docker-ops.sh logs --export
```

## 📈 Comandos de Relatórios

### **Geração de Relatórios**

```bash
# Gerar relatório HTML
./blueai-docker-ops.sh report html

# Gerar relatório de texto
./blueai-docker-ops.sh report text

# Exportar dados
./blueai-docker-ops.sh report export
```

## 🧪 Comandos de Teste

### **Testes e Validação**

```bash
# Testar notificações
./blueai-docker-ops.sh notify-test

# Validar configurações
./blueai-docker-ops.sh validate

# Teste completo do sistema
./scripts/utils/test-system.sh
```

## 🧹 Comandos de Manutenção

### **Limpeza e Manutenção**

```bash
# Limpar logs e backups antigos
./blueai-docker-ops.sh cleanup

# Limpar funcionalidades depreciadas
./scripts/utils/cleanup-deprecated.sh --check
./scripts/utils/cleanup-deprecated.sh --remove
```

## 📝 Comandos de Versão

### **Gerenciamento de Versão**

```bash
# Mostrar informações da versão
./blueai-docker-ops.sh version

# Mostrar changelog
./blueai-docker-ops.sh changelog [versão]

# Gerenciar changelogs
./blueai-docker-ops.sh changelog-manager

# Verificar compatibilidade
./blueai-docker-ops.sh compatibility

# Verificar atualizações
./blueai-docker-ops.sh update-check

# Mostrar estatísticas do sistema
./blueai-docker-ops.sh stats
```

## 🔄 Comandos de Automação

### **LaunchAgent (macOS)**

```bash
# Instalar LaunchAgent
./blueai-docker-ops.sh automação install

# Verificar status
./blueai-docker-ops.sh automação status

# Desinstalar LaunchAgent
./blueai-docker-ops.sh automação uninstall

# Testar script de backup
./blueai-docker-ops.sh automação test

# Ajuda dos comandos de automação
./blueai-docker-ops.sh automação --help
```

### **Comandos Diretos (Alternativa)**

```bash
# Instalar LaunchAgent
./scripts/utils/install-launchagent.sh

# Verificar status
./scripts/utils/install-launchagent.sh status

# Desinstalar LaunchAgent
./scripts/utils/install-launchagent.sh uninstall

# Testar script de backup
./scripts/utils/install-launchagent.sh test
```

## 📋 Opções Globais

### **Ajuda e Informações**

```bash
# Mostrar ajuda completa
./blueai-docker-ops.sh --help

# Mostrar ajuda de comando específico
./blueai-docker-ops.sh [COMANDO] --help

# Mostrar versão
./blueai-docker-ops.sh --version
```

## 🔧 Comandos Avançados

### **Utilitários do Sistema**

```bash
# Configurador de containers
./scripts/utils/container-configurator.sh

# Configurador de recuperação
./scripts/utils/recovery-configurator.sh

# Gerenciador de backups de configuração
./scripts/utils/config-backup-manager.sh

# Limpeza de funcionalidades depreciadas
./scripts/utils/cleanup-deprecated.sh

# Teste completo do sistema
./scripts/utils/test-system.sh

# Instalador do LaunchAgent
./scripts/utils/install-launchagent.sh

# Utilitários de versão
./scripts/utils/version-utils.sh
```

## 📊 Exemplos de Uso

### **Fluxo Típico de Backup**

```bash
# 1. Configurar containers
./blueai-docker-ops.sh config containers

# 2. Validar configuração
./blueai-docker-ops.sh config validate

# 3. Executar backup
./blueai-docker-ops.sh backup

# 4. Verificar status
./blueai-docker-ops.sh status

# 5. Gerar relatório
./blueai-docker-ops.sh report html
```

### **Fluxo Típico de Recuperação**

```bash
# 1. Configurar recuperação
./blueai-docker-ops.sh recovery config

# 2. Validar configuração
./blueai-docker-ops.sh recovery validate

# 3. Listar containers configurados
./blueai-docker-ops.sh recovery list

# 4. Executar recuperação
./blueai-docker-ops.sh recover

# 5. Verificar status
./blueai-docker-ops.sh status

# 6. Ver logs de erro
./blueai-docker-ops.sh logs --errors
```

### **Monitoramento Diário**

```bash
# Verificar status
./blueai-docker-ops.sh status

# Monitorar logs
./blueai-docker-ops.sh monitor

# Análise de performance
./blueai-docker-ops.sh logs --performance

# Gerar relatório
./blueai-docker-ops.sh report html
```

### **Troubleshooting**

```bash
# Ver logs de erro
./blueai-docker-ops.sh logs --errors

# Testar notificações
./blueai-docker-ops.sh notify-test

# Validar configurações
./blueai-docker-ops.sh validate

# Teste completo
./scripts/utils/test-system.sh
```

## 🚨 Comandos de Emergência

### **Recuperação Rápida**

```bash
# Recuperar containers imediatamente
./blueai-docker-ops.sh recover

# Verificar status
./blueai-docker-ops.sh status

# Ver logs de erro
./blueai-docker-ops.sh logs --errors

# Backup de emergência
./blueai-docker-ops.sh backup
```

### **Restauração de Backup**

```bash
# Listar backups disponíveis
./blueai-docker-ops.sh backup list

# Restaurar backup específico
./blueai-docker-ops.sh backup restore [arquivo]

# Verificar integridade
./blueai-docker-ops.sh validate
```

## 📋 Códigos de Retorno

| Código | Significado |
|--------|-------------|
| `0` | Sucesso |
| `1` | Erro geral |
| `2` | Erro de configuração |
| `3` | Erro de permissão |
| `4` | Erro de dependência |
| `5` | Erro de validação |

## 🔍 Opções de Debug

### **Logs Detalhados**

```bash
# Habilitar logs debug
export LOG_LEVEL=DEBUG

# Executar comando
./blueai-docker-ops.sh [COMANDO]
```

### **Modo Verboso**

```bash
# Executar com saída detalhada
./blueai-docker-ops.sh [COMANDO] --verbose
```

## 📚 Comandos por Categoria

### **🔄 Backup e Recuperação**
- `backup` - Executar backup dinâmico
- `dynamic backup` - Backup dinâmico explícito
- `recover` - Recuperar containers
- `recovery config` - Configurar recuperação

### **⚙️ Configuração**
- `config containers` - Configurar containers
- `config backups` - Gerenciar backups de configuração
- `recovery config` - Configurar recuperação

### **📊 Monitoramento**
- `status` - Verificar status
- `logs` - Analisar logs
- `monitor` - Monitorar em tempo real

### **📈 Relatórios**
- `report html` - Relatório HTML
- `report text` - Relatório texto
- `report export` - Exportar dados

### **🧪 Testes**
- `notify-test` - Testar notificações
- `validate` - Validar configurações
- `dynamic validate` - Validar backup dinâmico

### **🧹 Manutenção**
- `cleanup` - Limpar logs e backups
- `version` - Informações de versão
- `changelog` - Histórico de versões

---

**💡 Dica:** Use `./blueai-docker-ops.sh --help` para ver a ajuda completa de qualquer comando.
