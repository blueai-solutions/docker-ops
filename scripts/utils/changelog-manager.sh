#!/bin/bash

# =============================================================================
# GERENCIADOR DE CHANGELOG DO SISTEMA DE BACKUP DOCKER
# =============================================================================

# Definir diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Carregar configuração de versão
VERSION_CONFIG="$PROJECT_ROOT/config/version-config.sh"
if [ -f "$VERSION_CONFIG" ]; then
    source "$VERSION_CONFIG"
else
    echo "❌ Arquivo de configuração de versão não encontrado"
    exit 1
fi

# Diretório de changelogs
CHANGELOG_DIR="$PROJECT_ROOT/docs/changelog"

# Função para mostrar ajuda
show_help() {
    echo "🐳 Gerenciador de Changelog - $SYSTEM_NAME"
    echo "=========================================="
    echo ""
    echo "📋 Uso: $0 [comando] [opções]"
    echo ""
    echo "🔧 Comandos disponíveis:"
    echo "  create <versão>     - Criar novo changelog para versão"
    echo "  list               - Listar todos os changelogs"
    echo "  show <versão>      - Mostrar changelog específico"
    echo "  update <versão>    - Atualizar changelog existente"
    echo "  template           - Mostrar template de changelog"
    echo "  validate           - Validar todos os changelogs"
    echo "  stats              - Estatísticas dos changelogs"
    echo "  help               - Mostrar esta ajuda"
    echo ""
    echo "📝 Exemplos:"
    echo "  $0 create 2.1.0"
    echo "  $0 show 2.0.0"
    echo "  $0 list"
    echo "  $0 validate"
}

# Função para criar novo changelog
create_changelog() {
    local version="$1"
    
    if [ -z "$version" ]; then
        echo "❌ Erro: Versão não especificada"
        echo "💡 Use: $0 create <versão>"
        return 1
    fi
    
    # Validar formato da versão
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "❌ Erro: Formato de versão inválido"
        echo "💡 Use formato: X.Y.Z (ex: 2.1.0)"
        return 1
    fi
    
    local changelog_file="$CHANGELOG_DIR/v${version}.md"
    
    if [ -f "$changelog_file" ]; then
        echo "⚠️  Changelog para v$version já existe"
        read -p "Deseja sobrescrever? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Operação cancelada"
            return 1
        fi
    fi
    
    # Criar diretório se não existir
    mkdir -p "$CHANGELOG_DIR"
    
    # Criar template do changelog
    cat > "$changelog_file" << EOF
# Changelog v$version

**Data de Release:** $(date +%Y-%m-%d)  
**Versão:** $version  
**Tipo:** [Major/Minor/Patch] Release  
**Compatibilidade:** macOS 10.15+, Docker 20.0+  

## 🎉 Novas Funcionalidades

- [ ] Nova funcionalidade 1
- [ ] Nova funcionalidade 2

## 🔧 Melhorias

- [ ] Melhoria 1
- [ ] Melhoria 2

## 🐛 Correções

- [ ] Correção 1
- [ ] Correção 2

## 📊 Estatísticas da Versão

### Arquivos e Código
- **Arquivos modificados:** 0
- **Linhas de código:** 0
- **Documentação:** 0 documentos
- **Testes:** 0/0 aprovados
- **Compatibilidade:** 100%

### Funcionalidades
- **Comandos adicionados:** 0
- **Configurações:** 0 opções
- **Níveis de log:** 0
- **Tipos de notificação:** 0
- **Formatos de relatório:** 0

### Qualidade
- **Cobertura de testes:** 0%
- **Documentação:** Básica
- **Compatibilidade:** Universal
- **Performance:** Otimizada
- **Usabilidade:** Intuitiva

## 🔗 Links Úteis

- [Guia de Início Rápido](../guia-inicio-rapido.md)
- [Comandos Disponíveis](../comandos.md)
- [Arquitetura do Sistema](../arquitetura.md)
- [Solução de Problemas](../solucao-problemas.md)
- [Documentação Completa](../README.md)

## 👥 Contribuidores

- **Desenvolvedor** - Descrição da contribuição

## 🎯 Impacto da Versão

Descrição do impacto desta versão no sistema.

---

*"Mensagem de impacto da versão"*
EOF

    echo "✅ Changelog criado: $changelog_file"
    echo "📝 Edite o arquivo para adicionar as mudanças da versão"
}

# Função para listar changelogs
list_changelogs() {
    echo "📋 Changelogs Disponíveis"
    echo "========================="
    echo ""
    
    if [ ! -d "$CHANGELOG_DIR" ]; then
        echo "❌ Diretório de changelogs não encontrado"
        return 1
    fi
    
    local changelogs=($(ls "$CHANGELOG_DIR"/v*.md 2>/dev/null | sort -V))
    
    if [ ${#changelogs[@]} -eq 0 ]; then
        echo "📭 Nenhum changelog encontrado"
        return 0
    fi
    
    for changelog in "${changelogs[@]}"; do
        local version=$(basename "$changelog" .md | sed 's/v//')
        local size=$(wc -c < "$changelog" | tr -d ' ')
        local lines=$(wc -l < "$changelog" | tr -d ' ')
        local date=$(grep "Data de Release:" "$changelog" | head -1 | sed 's/.*Data de Release: *//' | sed 's/ .*//')
        
        echo "📄 v$version"
        echo "   📅 Data: $date"
        echo "   📏 Tamanho: $size bytes ($lines linhas)"
        echo "   📁 Arquivo: $(basename "$changelog")"
        echo ""
    done
    
    echo "📊 Total: ${#changelogs[@]} changelog(s)"
}

# Função para mostrar changelog específico
show_changelog() {
    local version="$1"
    
    if [ -z "$version" ]; then
        echo "❌ Erro: Versão não especificada"
        echo "💡 Use: $0 show <versão>"
        return 1
    fi
    
    local changelog_file="$CHANGELOG_DIR/v${version}.md"
    
    if [ -f "$changelog_file" ]; then
        echo "📋 Changelog v$version"
        echo "====================="
        echo ""
        cat "$changelog_file"
    else
        echo "❌ Changelog para v$version não encontrado"
        echo ""
        echo "📋 Versões disponíveis:"
        list_changelogs
        return 1
    fi
}

# Função para atualizar changelog
update_changelog() {
    local version="$1"
    
    if [ -z "$version" ]; then
        echo "❌ Erro: Versão não especificada"
        echo "💡 Use: $0 update <versão>"
        return 1
    fi
    
    local changelog_file="$CHANGELOG_DIR/v${version}.md"
    
    if [ ! -f "$changelog_file" ]; then
        echo "❌ Changelog para v$version não encontrado"
        echo "💡 Use: $0 create $version para criar"
        return 1
    fi
    
    # Abrir editor
    if command -v code >/dev/null 2>&1; then
        code "$changelog_file"
    elif command -v nano >/dev/null 2>&1; then
        nano "$changelog_file"
    elif command -v vim >/dev/null 2>&1; then
        vim "$changelog_file"
    else
        echo "📝 Arquivo: $changelog_file"
        echo "💡 Abra o arquivo em seu editor preferido"
    fi
}

# Função para mostrar template
show_template() {
    echo "📋 Template de Changelog"
    echo "========================"
    echo ""
    cat << 'EOF'
# Changelog vX.Y.Z

**Data de Release:** YYYY-MM-DD  
**Versão:** X.Y.Z  
**Tipo:** [Major/Minor/Patch] Release  
**Compatibilidade:** macOS 10.15+, Docker 20.0+  

## 🎉 Novas Funcionalidades

- [ ] Nova funcionalidade 1
- [ ] Nova funcionalidade 2

## 🔧 Melhorias

- [ ] Melhoria 1
- [ ] Melhoria 2

## 🐛 Correções

- [ ] Correção 1
- [ ] Correção 2

## 📊 Estatísticas da Versão

### Arquivos e Código
- **Arquivos modificados:** 0
- **Linhas de código:** 0
- **Documentação:** 0 documentos
- **Testes:** 0/0 aprovados
- **Compatibilidade:** 100%

### Funcionalidades
- **Comandos adicionados:** 0
- **Configurações:** 0 opções
- **Níveis de log:** 0
- **Tipos de notificação:** 0
- **Formatos de relatório:** 0

### Qualidade
- **Cobertura de testes:** 0%
- **Documentação:** Básica
- **Compatibilidade:** Universal
- **Performance:** Otimizada
- **Usabilidade:** Intuitiva

## 🔗 Links Úteis

- [Guia de Início Rápido](../guia-inicio-rapido.md)
- [Comandos Disponíveis](../comandos.md)
- [Arquitetura do Sistema](../arquitetura.md)
- [Solução de Problemas](../solucao-problemas.md)
- [Documentação Completa](../README.md)

## 👥 Contribuidores

- **Desenvolvedor** - Descrição da contribuição

## 🎯 Impacto da Versão

Descrição do impacto desta versão no sistema.

---

*"Mensagem de impacto da versão"*
EOF
}

# Função para validar changelogs
validate_changelogs() {
    echo "🔍 Validando Changelogs"
    echo "======================"
    echo ""
    
    if [ ! -d "$CHANGELOG_DIR" ]; then
        echo "❌ Diretório de changelogs não encontrado"
        return 1
    fi
    
    local changelogs=($(ls "$CHANGELOG_DIR"/v*.md 2>/dev/null | sort -V))
    local valid_count=0
    local total_count=${#changelogs[@]}
    
    if [ $total_count -eq 0 ]; then
        echo "📭 Nenhum changelog encontrado"
        return 0
    fi
    
    for changelog in "${changelogs[@]}"; do
        local version=$(basename "$changelog" .md | sed 's/v//')
        local errors=0
        
        echo "🔍 Validando v$version..."
        
        # Verificar se arquivo não está vazio
        if [ ! -s "$changelog" ]; then
            echo "  ❌ Arquivo vazio"
            ((errors++))
        fi
        
        # Verificar campos obrigatórios
        if ! grep -q "Data de Release:" "$changelog"; then
            echo "  ❌ Campo 'Data de Release' não encontrado"
            ((errors++))
        fi
        
        if ! grep -q "Versão:" "$changelog"; then
            echo "  ❌ Campo 'Versão' não encontrado"
            ((errors++))
        fi
        
        if ! grep -q "Tipo:" "$changelog"; then
            echo "  ❌ Campo 'Tipo' não encontrado"
            ((errors++))
        fi
        
        # Verificar seções obrigatórias
        if ! grep -q "## 🎉 Novas Funcionalidades" "$changelog"; then
            echo "  ❌ Seção 'Novas Funcionalidades' não encontrada"
            ((errors++))
        fi
        
        if ! grep -q "## 🔧 Melhorias" "$changelog"; then
            echo "  ❌ Seção 'Melhorias' não encontrada"
            ((errors++))
        fi
        
        if ! grep -q "## 🐛 Correções" "$changelog"; then
            echo "  ❌ Seção 'Correções' não encontrada"
            ((errors++))
        fi
        
        if [ $errors -eq 0 ]; then
            echo "  ✅ Válido"
            ((valid_count++))
        else
            echo "  ❌ $errors erro(s) encontrado(s)"
        fi
        echo ""
    done
    
    echo "📊 Resultado da Validação:"
    echo "  ✅ Válidos: $valid_count/$total_count"
    echo "  ❌ Inválidos: $((total_count - valid_count))/$total_count"
    
    if [ $valid_count -eq $total_count ]; then
        echo "🎉 Todos os changelogs estão válidos!"
        return 0
    else
        echo "⚠️  Alguns changelogs precisam de correção"
        return 1
    fi
}

# Função para estatísticas
show_stats() {
    echo "📊 Estatísticas dos Changelogs"
    echo "============================="
    echo ""
    
    if [ ! -d "$CHANGELOG_DIR" ]; then
        echo "❌ Diretório de changelogs não encontrado"
        return 1
    fi
    
    local changelogs=($(ls "$CHANGELOG_DIR"/v*.md 2>/dev/null | sort -V))
    local total_count=${#changelogs[@]}
    
    if [ $total_count -eq 0 ]; then
        echo "📭 Nenhum changelog encontrado"
        return 0
    fi
    
    local total_size=0
    local total_lines=0
    local versions=()
    
    for changelog in "${changelogs[@]}"; do
        local size=$(wc -c < "$changelog" | tr -d ' ')
        local lines=$(wc -l < "$changelog" | tr -d ' ')
        local version=$(basename "$changelog" .md | sed 's/v//')
        
        total_size=$((total_size + size))
        total_lines=$((total_lines + lines))
        versions+=("$version")
    done
    
    echo "📈 Informações Gerais:"
    echo "  Total de changelogs: $total_count"
    echo "  Tamanho total: $total_size bytes"
    echo "  Linhas totais: $total_lines"
    echo "  Tamanho médio: $((total_size / total_count)) bytes"
    echo "  Linhas médias: $((total_lines / total_count))"
    echo ""
    
    echo "📋 Versões:"
    for version in "${versions[@]}"; do
        echo "  - v$version"
    done
    echo ""
    
    echo "📅 Timeline:"
    for changelog in "${changelogs[@]}"; do
        local version=$(basename "$changelog" .md | sed 's/v//')
        local date=$(grep "Data de Release:" "$changelog" | head -1 | sed 's/.*Data de Release: *//' | sed 's/ .*//')
        echo "  v$version: $date"
    done
}

# Função principal
main() {
    local command="$1"
    local version="$2"
    
    case "$command" in
        create)
            create_changelog "$version"
            ;;
        list)
            list_changelogs
            ;;
        show)
            show_changelog "$version"
            ;;
        update)
            update_changelog "$version"
            ;;
        template)
            show_template
            ;;
        validate)
            validate_changelogs
            ;;
        stats)
            show_stats
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "❌ Comando desconhecido: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
