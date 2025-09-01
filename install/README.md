# 🚀 Scripts de Instalação - BlueAI Docker Ops

Esta pasta contém todos os scripts e documentação relacionados à instalação do BlueAI Docker Ops.

## 📋 Arquivos Disponíveis

### **🔧 Scripts de Instalação**
- **`install.sh`** - Instalador automático do sistema
- **`uninstall.sh`** - Desinstalador do sistema

### **📚 Documentação**
- **`INSTALL.md`** - Guia completo de instalação
- **`README-INSTALL.md`** - Instalação rápida

## ⚡ Instalação Rápida

### **Instalação em Uma Linha**
```bash
curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install/install.sh | bash
```

### **Instalação Manual**
```bash
# 1. Download
curl -O https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install/install.sh

# 2. Executar
chmod +x install.sh
./install.sh
```

## 🗑️ Desinstalação

### **Download e Execução**
```bash
# 1. Download
curl -O https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install/uninstall.sh

# 2. Executar
chmod +x uninstall.sh
./uninstall.sh
```

## 📖 Documentação Completa

- **📖 [INSTALL.md](INSTALL.md)** - Guia detalhado de instalação
- **🚀 [README-INSTALL.md](README-INSTALL.md)** - Instalação rápida

## 🎯 Após a Instalação

```bash
# Verificar instalação
blueai-docker-ops --help

# Configurar containers
blueai-docker-ops config containers

# Executar primeiro backup
blueai-docker-ops backup
```

## 🆘 Suporte

- **🐛 Issues**: [GitHub Issues](https://github.com/blueai-solutions/docker-ops/issues)
- **📧 Email**: docker-ops@blueaisolutions.com.br
- **📖 Documentação**: [docs/](../docs/)

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
