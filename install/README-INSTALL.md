# 🚀 Instalação Rápida - BlueAI Docker Ops

## ⚡ Instalação em Uma Linha

```bash
curl -sSL https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install.sh | bash
```

## 📋 Pré-requisitos

- ✅ **macOS 10.15+** (Catalina ou superior)
- ✅ **Docker 20.10.0+** instalado e rodando
- ✅ **Usuário com permissões** de administrador

## 🔧 Instalação Manual

```bash
# 1. Download
curl -O https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/install.sh

# 2. Executar
chmod +x install.sh
./install.sh
```

## 🎯 Após a Instalação

```bash
# Verificar instalação
blueai-docker-ops --help

# Configurar containers
blueai-docker-ops config containers

# Executar primeiro backup
blueai-docker-ops backup
```

## 🗑️ Desinstalação

```bash
# Download do desinstalador
curl -O https://raw.githubusercontent.com/blueai-solutions/docker-ops/main/uninstall.sh

# Executar
chmod +x uninstall.sh
./uninstall.sh
```

## 📚 Documentação Completa

- **📖 Guia de Instalação**: [INSTALL.md](INSTALL.md)
- **📋 Comandos**: [docs/comandos.md](docs/comandos.md)
- **🚀 Início Rápido**: [docs/guia-inicio-rapido.md](docs/guia-inicio-rapido.md)

## 🆘 Suporte

- **🐛 Issues**: [GitHub Issues](https://github.com/blueai-solutions/docker-ops/issues)
- **📧 Email**: docker-ops@blueaisolutions.com.br

---

**Desenvolvido com ❤️ pela BlueAI Solutions**
