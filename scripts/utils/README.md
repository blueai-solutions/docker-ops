# 🛠️ Utilitários - BlueAI Docker Ops

Esta pasta contém scripts utilitários **para usuários finais** do sistema.

## 📋 Scripts Disponíveis

### **🔧 Configuração e Recuperação**
- **`container-configurator.sh`** - Configurador interativo de containers
  - Configurar containers para backup
  - Interface gráfica interativa
  - Validação de configurações
  - Backup de configurações

- **`recovery-configurator.sh`** - Configurador de recuperação
  - Configurar estratégias de recuperação
  - Definir prioridades de containers
  - Configurar notificações
  - Backup de configurações

### **🧪 Testes e Validação**
- **`test-system.sh`** - Teste completo do sistema
  - Validação de todos os componentes
  - Testes de funcionalidade
  - Verificação de dependências
  - Relatórios de status

### **🔄 Manutenção e Limpeza**
- **`config-backup-manager.sh`** - Gerenciador de backups de configuração
  - Criar backups automáticos
  - Restaurar configurações
  - Gerenciar histórico
  - Limpeza de backups antigos

- **`cleanup-deprecated.sh`** - Limpeza de código legado
  - Remover funcionalidades obsoletas
  - Limpar arquivos temporários
  - Otimizar estrutura
  - Manter compatibilidade

## 🚀 Como Usar

### **Configurar Containers**
```bash
# Ver ajuda
./scripts/utils/container-configurator.sh --help

# Configurar containers
./scripts/utils/container-configurator.sh config

# Listar configuração atual
./scripts/utils/container-configurator.sh list
```

### **Configurar Recuperação**
```bash
# Ver ajuda
./scripts/utils/recovery-configurator.sh --help

# Configurar recuperação
./scripts/utils/recovery-configurator.sh config

# Testar configuração
./scripts/utils/recovery-configurator.sh test
```

### **Testar Sistema**
```bash
# Ver ajuda
./scripts/utils/test-system.sh --help

# Teste completo
./scripts/utils/test-system.sh

# Teste específico
./scripts/utils/test-system.sh --component backup
```

### **Gerenciar Backups de Configuração**
```bash
# Ver ajuda
./scripts/utils/config-backup-manager.sh --help

# Criar backup
./scripts/utils/config-backup-manager.sh create

# Listar backups
./scripts/utils/config-backup-manager.sh list

# Restaurar backup
./scripts/utils/config-backup-manager.sh restore
```

## 🎯 Funcionalidades

### **Interface Interativa**
- Menus gráficos intuitivos
- Validação de entrada
- Feedback visual claro
- Tratamento de erros

### **Backup Automático**
- Criação automática de backups
- Versionamento de configurações
- Restauração segura
- Limpeza automática

### **Testes Completos**
- Validação de todos os componentes
- Testes de funcionalidade
- Verificação de dependências
- Relatórios detalhados

## 📚 Documentação Relacionada

- [Guia de Início Rápido](../../docs/guia-inicio-rapido.md)
- [Comandos](../../docs/comandos.md)
- [Arquitetura](../../docs/arquitetura.md)
- [Solução de Problemas](../../docs/solucao-problemas.md)

## 🆘 Suporte

- **📧 Email:** docker-ops@blueaisolutions.com.br
- **🐛 Issues:** https://github.com/blueai-solutions/docker-ops/issues
- **📖 Documentação:** https://github.com/blueai-solutions/docker-ops/tree/main/docs

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
