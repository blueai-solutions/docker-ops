# 🛠️ Scripts de Desenvolvimento - BlueAI Docker Ops

Esta pasta contém scripts utilizados **apenas por desenvolvedores** para gerenciar o projeto.

## 📋 Scripts Disponíveis

### **🏷️ Gerenciamento de Releases**
- **`release-manager.sh`** - Gerenciador completo de releases e tags
  - Criar releases
  - Incrementar versões
  - Listar releases
  - Verificar status do repositório

### **📝 Gerenciamento de Changelog**
- **`changelog-manager.sh`** - Gerenciador de histórico de mudanças
  - Criar entradas de changelog
  - Gerenciar versões
  - Gerar relatórios

### **🔢 Utilitários de Versão**
- **`version-utils.sh`** - Utilitários para gerenciamento de versões
  - Verificar versões
  - Download de releases
  - Comparação de versões

## 🚀 Como Usar

### **Gerenciar Releases**
```bash
# Ver ajuda
./scripts/dev/release-manager.sh --help

# Criar nova release
./scripts/dev/release-manager.sh create-release 2.4.0

# Incrementar versão
./scripts/dev/release-manager.sh bump-version minor

# Ver status
./scripts/dev/release-manager.sh check-status
```

### **Gerenciar Changelog**
```bash
# Ver ajuda
./scripts/dev/changelog-manager.sh --help

# Listar entradas
./scripts/dev/changelog-manager.sh list

# Criar nova entrada
./scripts/dev/changelog-manager.sh create
```

### **Utilitários de Versão**
```bash
# Ver ajuda
./scripts/dev/version-utils.sh --help

# Verificar versão atual
./scripts/dev/version-utils.sh check

# Download de release
./scripts/dev/version-utils.sh download
```

## ⚠️ **IMPORTANTE**

**Estes scripts NÃO são incluídos no pacote de release para usuários finais.**

**Eles são utilizados apenas por desenvolvedores para:**
- Gerenciar releases do projeto
- Manter changelog atualizado
- Gerenciar versões
- Operações de desenvolvimento

## 📚 Documentação Relacionada

- [Guia de Distribuição](../../docs/distribuicao.md)
- [Processo de Release](../../docs/distribuicao.md#-processo-de-release)
- [Gerenciamento de Versões](../../docs/distribuicao.md#-gerenciamento-de-versões)

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
