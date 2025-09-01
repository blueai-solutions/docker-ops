# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- Novas funcionalidades em desenvolvimento

## [2.3.1] - 2025-08-29

### Added
- Sistema de organização de backups de configuração em pasta dedicada
- Script gerenciador de backups de configuração (config-backup-manager.sh)
- Sistema de limpeza de código legado (cleanup-deprecated.sh)
- Comandos integrados para gerenciar backups de configuração
- Migração automática de comandos antigos para novos
- Documentação completa atualizada

### Changed
- Remoção completa do smart-backup.sh (código legado)
- Unificação dos comandos de backup (backup → dynamic backup)
- Sistema de recuperação totalmente dinâmico
- Status dinâmico baseado em configuração de recuperação
- Documentação principal completamente reescrita

### Fixed
- Correção do parsing de portas no sistema de recuperação
- Correção do cálculo de tamanhos de containers
- Correção de referências a arquivos removidos
- Correção de permissões e execução de scripts
- Remoção de todas as referências ao smart-backup

### Removed
- smart-backup.sh e todas as suas referências
- Código legado desnecessário
- Comandos duplicados
- Configurações hardcoded

## [2.3.0] - 2025-08-29

### Added
- Configurador interativo de recuperação de containers
- Interface interativa com detecção automática de containers
- Comandos de recuperação avançados (config, preview, validate, reset, start, stop, status, logs, list)
- Detecção inteligente de containers Docker com configurações
- Preview da configuração antes de salvar
- Validação automática de configurações

### Changed
- Melhoria na interface de usuário com menus interativos
- Sistema de configuração com backup automático
- Integração completa com Docker para detecção de containers
- Correção da duplicação de arquivos backup-volumes.sh

### Fixed
- Eliminação de arquivo duplicado backup-volumes.sh
- Padronização de configurações de backup
- Suporte completo a diferentes versões do Docker
- Tratamento robusto de erros para containers não encontrados

## [2.2.0] - 2025-08-29

### Added
- Configurador interativo de containers para backup
- Interface interativa com detecção automática de containers
- Comandos de configuração avançados (containers, preview, validate, reset)
- Detecção inteligente de containers Docker com status e volumes
- Preview da configuração antes de salvar
- Validação automática de configurações

### Changed
- Melhoria na interface de usuário com menus interativos
- Sistema de configuração com backup automático
- Integração completa com Docker para detecção de containers

### Fixed
- Correção do erro de logging `[: INFO: integer expression expected`
- Suporte completo a diferentes versões do Docker
- Tratamento robusto de erros para containers não encontrados

## [2.1.0] - 2025-08-29

### Added
- Sistema de changelog profissional em arquivos separados
- Gerenciador de changelog com comandos completos
- Template automático para criação de novos changelogs
- Validação automática de estrutura de changelogs
- Estatísticas detalhadas dos changelogs
- Integração completa com o sistema principal

### Changed
- Melhoria no sistema de versionamento com carregamento dinâmico
- Documentação atualizada com seção de changelog
- Interface de usuário melhorada com comandos de gerenciamento

### Fixed
- Suporte completo a Bash 3.x para novos scripts
- Organização lógica dos changelogs em diretório dedicado
- Links relativos corrigidos para documentação

## [2.0.0] - 2025-08-29

### Added
- Sistema de versionamento completo
- Configuração dinâmica de containers
- Documentação completa (5 documentos)
- Sistema de logs estruturado avançado
- Notificações por email e macOS
- LaunchAgent para automação
- Estrutura de projeto reorganizada

### Changed
- Reorganização completa da estrutura do projeto
- Melhoria no sistema de notificações
- Sistema de backup mais inteligente

### Fixed
- Correção de bugs de compatibilidade com Bash 3.x
- Melhoria na performance de backup
- Correção de caminhos de arquivos

## [1.5.0] - 2025-01-15

### Added
- Sistema de notificações por email
- Notificações macOS nativas
- LaunchAgent para automação
- Scripts de teste e validação

### Changed
- Melhoria na estrutura de logs
- Otimização de performance

## [1.0.0] - 2024-12-01

### Added
- Backup básico de volumes Docker
- Script de recuperação
- Estrutura inicial do projeto
- Funcionalidades core de backup

---

## Links Úteis

- [Guia de Início Rápido](../guia-inicio-rapido.md)
- [Comandos Disponíveis](../comandos.md)
- [Arquitetura do Sistema](../arquitetura.md)
- [Solução de Problemas](../solucao-problemas.md)
- [Documentação Completa](../README.md)
