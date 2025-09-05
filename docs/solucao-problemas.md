# 🆘 Solução de Problemas

Guia completo para resolver problemas comuns do BlueAI Docker Ops simplificado.

## 🔍 Diagnóstico Rápido

### **Verificar Status Geral**
```bash
# Teste completo do sistema
./blueai-docker-ops.sh test

# Verificar status geral
./blueai-docker-ops.sh status

# Ver logs do sistema
./blueai-docker-ops.sh logs
```

### **Comandos de Diagnóstico**
```bash
# Ver volumes configurados
./blueai-docker-ops.sh volumes

# Ver comandos avançados disponíveis
./blueai-docker-ops.sh advanced
```

## 🚀 Problemas de Configuração

### **"Setup não funcionou corretamente"**

#### **Sintomas:**
- Erro durante `make setup`
- Configuração incompleta
- Comandos não funcionam

#### **Soluções:**
```bash
# 1. Verificar se está no diretório correto
pwd
# Deve mostrar: .../blueai-docker-ops/backend

# 2. Verificar permissões
ls -la blueai-docker-ops.sh
# Deve mostrar: -rwxr-xr-x

# 3. Executar setup novamente
./blueai-docker-ops.sh setup

# 4. Se ainda houver problemas, verificar logs
./blueai-docker-ops.sh logs
```

#### **Prevenção:**
- Sempre execute `make setup` do diretório raiz
- Verifique se Docker está rodando antes do setup
- Certifique-se de ter permissões adequadas

### **"Configuração pede horário duas vezes"**

#### **Sintomas:**
- Durante setup, sistema pede horário do backup duas vezes
- Configuração duplicada

#### **Soluções:**
```bash
# 1. Verificar se é a primeira execução
# Se sim, use apenas: make setup

# 2. Se já configurado, use apenas:
./blueai-docker-ops.sh schedule

# 3. Para reconfigurar tudo:
./blueai-docker-ops.sh config
```

## 🐳 Problemas com Docker

### **"Docker não está rodando"**

#### **Sintomas:**
- Erro: "Docker is not running"
- Comando `docker ps` falha
- Containers não respondem

#### **Soluções:**
```bash
# 1. Iniciar Docker Desktop
open -a Docker

# 2. Aguardar inicialização (30-60 segundos)
# 3. Verificar se está funcionando
docker ps

# 4. Se ainda não funcionar, reiniciar
killall Docker
open -a Docker
```

#### **Prevenção:**
- Configure Docker para iniciar automaticamente
- Verifique se há atualizações pendentes

### **"Container não encontrado"**

#### **Sintomas:**
- Erro: "No such container"
- Container não aparece na lista

#### **Soluções:**
```bash
# 1. Verificar containers existentes
docker ps -a

# 2. Se container existe mas está parado, iniciar
docker start [nome_container]

# 3. Se container não existe, recriar
# (consulte documentação específica do container)
```

### **"Volume não encontrado"**

#### **Sintomas:**
- Erro: "No such volume"
- Backup falha ao acessar volume

#### **Soluções:**
```bash
# 1. Verificar volumes existentes
docker volume ls

# 2. Verificar se container está rodando
docker ps

# 3. Se volume não existe, recriar container
docker-compose up -d
```

## 📧 Problemas com Notificações

### **"Email não enviado"**

#### **Sintomas:**
- Não recebe emails de notificação
- Erro: "mail: command not found"
- Erro: "sendmail: command not found"

#### **Soluções:**
```bash
# 1. Verificar configuração de email
cat config/notification-config.sh | grep EMAIL

# 2. Testar notificações
./blueai-docker-ops.sh advanced

# 3. Verificar se cliente de email está instalado
which mail
```

#### **Prevenção:**
- Configure email durante setup inicial
- Teste notificações após configuração
- Verifique configurações de firewall

### **"Notificações macOS não funcionam"**

#### **Sintomas:**
- Notificações não aparecem no macOS
- Erro: "osascript: command not found"

#### **Soluções:**
```bash
# 1. Verificar permissões de notificação
# Sistema > Preferências > Notificações > BlueAI Docker Ops

# 2. Testar notificações
./blueai-docker-ops.sh advanced

# 3. Verificar se osascript está disponível
which osascript
```

## 🔄 Problemas com Backup

### **"Backup falha"**

#### **Sintomas:**
- Erro durante execução de backup
- Backup não é criado
- Mensagens de erro no log

#### **Soluções:**
```bash
# 1. Verificar status do sistema
./blueai-docker-ops.sh status

# 2. Ver logs de erro
./blueai-docker-ops.sh logs

# 3. Verificar volumes configurados
./blueai-docker-ops.sh volumes

# 4. Testar backup manualmente
./blueai-docker-ops.sh backup
```

#### **Prevenção:**
- Execute `./blueai-docker-ops.sh test` regularmente
- Monitore logs do sistema
- Verifique espaço em disco

### **"Backup não encontrado"**

#### **Sintomas:**
- Backup não aparece na lista
- Erro ao restaurar backup

#### **Soluções:**
```bash
# 1. Listar backups disponíveis
./blueai-docker-ops.sh status

# 2. Verificar diretório de backups
ls -la backups/

# 3. Verificar permissões
ls -la backups/*.tar.gz
```

## 🔄 Problemas com Recovery

### **"Recovery falha"**

#### **Sintomas:**
- Erro durante execução de recovery
- Containers não são recuperados
- Mensagens de erro no log

#### **Soluções:**
```bash
# 1. Verificar configuração de recovery
cat config/recovery-config.sh

# 2. Ver status do sistema
./blueai-docker-ops.sh status

# 3. Executar recovery novamente
./blueai-docker-ops.sh recovery

# 4. Ver logs de erro
./blueai-docker-ops.sh logs
```

#### **Prevenção:**
- Configure recovery durante setup inicial
- Teste recovery em ambiente de desenvolvimento
- Mantenha backups atualizados

## 🕐 Problemas com Agendamento

### **"Backup automático não executa"**

#### **Sintomas:**
- Backup não executa no horário configurado
- LaunchAgent não está funcionando

#### **Soluções:**
```bash
# 1. Verificar status do agendamento
./blueai-docker-ops.sh status

# 2. Verificar LaunchAgent
launchctl list | grep docker

# 3. Reconfigurar agendamento
./blueai-docker-ops.sh schedule

# 4. Testar agendamento
./blueai-docker-ops.sh advanced
```

#### **Prevenção:**
- Configure agendamento durante setup inicial
- Teste agendamento após configuração
- Monitore logs do LaunchAgent

### **"Horário incorreto"**

#### **Sintomas:**
- Backup executa em horário diferente do configurado
- Configuração de horário não é respeitada

#### **Soluções:**
```bash
# 1. Verificar configuração atual
cat config/version-config.sh | grep SCHEDULE

# 2. Reconfigurar horário
./blueai-docker-ops.sh schedule

# 3. Verificar LaunchAgent
launchctl list | grep docker
```

## 📊 Problemas com Logs e Relatórios

### **"Logs não aparecem"**

#### **Sintomas:**
- Logs não são gerados
- Diretório de logs está vazio

#### **Soluções:**
```bash
# 1. Verificar diretório de logs
ls -la logs/

# 2. Verificar permissões
ls -la logs/*.log

# 3. Executar comando para gerar logs
./blueai-docker-ops.sh backup

# 4. Ver logs gerados
./blueai-docker-ops.sh logs
```

#### **Prevenção:**
- Execute comandos regularmente para gerar logs
- Verifique permissões de escrita no diretório logs
- Monitore tamanho dos arquivos de log

### **"Relatórios não são gerados"**

#### **Sintomas:**
- Relatórios HTML não são criados
- Diretório de relatórios está vazio

#### **Soluções:**
```bash
# 1. Verificar diretório de relatórios
ls -la reports/

# 2. Gerar relatório manualmente
./blueai-docker-ops.sh report

# 3. Verificar permissões
ls -la reports/*.html
```

### **"Filtros de relatório não funcionam"**

#### **Sintomas:**
- Botões de filtro não respondem
- Avisos e erros não aparecem nos relatórios
- Estatísticas incorretas

#### **Soluções:**
```bash
# 1. O sistema foi corrigido na versão 2.4.0
# Os filtros agora funcionam corretamente

# 2. Para verificar se está funcionando:
./blueai-docker-ops.sh report html
# Abra o arquivo HTML no navegador
# Teste os botões: Todos, Info, Avisos, Erros

# 3. Se ainda houver problemas, verificar logs:
./blueai-docker-ops.sh logs --search "report"
```

#### **Melhorias Implementadas:**
- ✅ **Filtros funcionais** - Botões de filtro agora funcionam corretamente
- ✅ **Parsing correto** - Logs são parseados no formato correto [timestamp] [level] [module] message
- ✅ **Estatísticas precisas** - Contagem inclui todos os arquivos de log
- ✅ **Detecção automática** - Funciona em desenvolvimento e produção
- ✅ **Indicação visual** - Filtros ativos são destacados visualmente

## 🔧 Problemas de Instalação

### **"Comando não encontrado"**

#### **Sintomas:**
- Erro: "command not found"
- Comando não está no PATH

#### **Soluções:**
```bash
# 1. Verificar se está instalado
which blueai-docker-ops

# 2. Se não estiver, executar setup
./blueai-docker-ops.sh setup

# 3. Verificar PATH
echo $PATH

# 4. Recarregar shell
source ~/.zshrc  # ou ~/.bashrc
```

#### **Prevenção:**
- Execute setup completo durante instalação
- Verifique se comandos estão no PATH
- Recarregue shell após instalação

### **"Permissões negadas"**

#### **Sintomas:**
- Erro: "Permission denied"
- Não consegue executar scripts

#### **Soluções:**
```bash
# 1. Verificar permissões
ls -la blueai-docker-ops.sh

# 2. Tornar executável
chmod +x blueai-docker-ops.sh
chmod +x scripts/**/*.sh

# 3. Verificar proprietário
ls -la blueai-docker-ops.sh
```

#### **Prevenção:**
- Clone repositório como usuário normal (não root)
- Verifique permissões após clone
- Use `chmod +x` para scripts necessários

## 🚨 Problemas Críticos

### **"Sistema não responde"**

#### **Sintomas:**
- Comandos não respondem
- Sistema trava durante execução

#### **Soluções:**
```bash
# 1. Interromper execução
Ctrl+C

# 2. Verificar processos
ps aux | grep blueai

# 3. Matar processos se necessário
killall blueai-docker-ops.sh

# 4. Reiniciar terminal
# 5. Testar sistema
./blueai-docker-ops.sh test
```

### **"Configuração corrompida"**

#### **Sintomas:**
- Arquivos de configuração corrompidos
- Sistema não funciona corretamente

#### **Soluções:**
```bash
# 1. Fazer backup da configuração atual
cp -r config config.backup.$(date +%Y%m%d_%H%M%S)

# 2. Restaurar configuração padrão
./blueai-docker-ops.sh config

# 3. Se não funcionar, reconfigurar tudo
./blueai-docker-ops.sh setup
```

### **"Sistema completamente corrompido"**

#### **Sintomas:**
- Nenhum comando funciona
- Configurações irreparáveis
- Problemas de permissão graves

#### **Soluções:**
```bash
# 1. Fazer backup manual de configurações importantes
cp -r config config-backup-$(date +%Y%m%d_%H%M%S)/

# 2. Reset completo de fábrica (PERIGOSO!)
./blueai-docker-ops.sh factory-reset

# 3. Reconfigurar sistema do zero
./blueai-docker-ops.sh setup

# 4. Configurar containers e agendamento
./blueai-docker-ops.sh config
./blueai-docker-ops.sh schedule
```

### **"Problemas de performance ou espaço em disco"**

#### **Sintomas:**
- Sistema lento
- Pouco espaço em disco
- Logs muito grandes
- Erro: "No space left on device" durante backup

#### **Soluções:**
```bash
# 1. O sistema agora verifica automaticamente o espaço em disco
# e limpa recursos Docker quando necessário

# 2. Para verificar espaço manualmente:
df -h

# 3. Para limpar recursos Docker manualmente:
docker system prune -f

# 4. Para verificar uso do Docker:
docker system df
```

#### **Melhorias Automáticas:**
- ✅ **Verificação automática** de espaço em disco antes do backup
- ✅ **Limpeza automática** de recursos Docker não utilizados
- ✅ **Tratamento inteligente** de erros de espaço em disco
- ✅ **Recuperação automática** quando há problemas de espaço
```bash
# 1. Limpeza seletiva de dados
./blueai-docker-ops.sh clean-data

# 2. Verificar espaço liberado
df -h

# 3. Verificar status do sistema
./blueai-docker-ops.sh status
```

## 📚 Recursos de Ajuda

### **Comandos de Ajuda**
```bash
# Ajuda principal
./blueai-docker-ops.sh --help

# Comandos avançados
./blueai-docker-ops.sh advanced

# Status detalhado
./blueai-docker-ops.sh status
```

### **Documentação**
- **Guia de Início Rápido:** [guia-inicio-rapido.md](guia-inicio-rapido.md)
- **Comandos Detalhados:** [comandos.md](comandos.md)
- **Arquitetura:** [arquitetura.md](arquitetura.md)

### **Logs e Debug**
```bash
# Ver logs detalhados
./blueai-docker-ops.sh logs

# Ver logs de erro
./blueai-docker-ops.sh advanced

# Ver logs de performance
./blueai-docker-ops.sh advanced
```

## 🎯 Prevenção de Problemas

### **Manutenção Regular**
```bash
# Teste semanal do sistema
./blueai-docker-ops.sh test

# Verificação de status
./blueai-docker-ops.sh status

# Limpeza de logs antigos
# (implementar conforme necessário)
```

### **Monitoramento**
- Execute `./blueai-docker-ops.sh status` regularmente
- Monitore logs do sistema
- Verifique espaço em disco
- Teste backup e recovery periodicamente

---

**🆘 Se o problema persistir, consulte a documentação completa ou abra uma issue no GitHub.**
