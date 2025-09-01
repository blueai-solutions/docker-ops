# 🆘 Solução de Problemas

Guia completo para resolver problemas comuns do BlueAI Docker Ops.

## 🔍 Diagnóstico Rápido

### **Verificar Status Geral**
```bash
# Teste completo do sistema
./scripts/utils/test-system.sh

# Verificar status dos containers
./blueai-docker-ops.sh status

# Verificar logs recentes
./blueai-docker-ops.sh logs --recent
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

# 2. Testar envio de email
./blueai-docker-ops.sh config test

# 3. Verificar se cliente de email está instalado
which mail
which sendmail

# 4. Se não estiver instalado, instalar
# macOS: Já vem com mail/sendmail
```

#### **Configuração de Email:**
```bash
# Editar configuração
nano config/notification-config.sh

# Configurações importantes:
EMAIL_ENABLED=true
EMAIL_TO="seu-email@gmail.com"
EMAIL_FROM="docker-ops@blueaisolutions.com.br"
```

### **"Notificação macOS não aparece"**

#### **Sintomas:**
- Notificações não aparecem no macOS
- Erro: "osascript: command not found"

#### **Soluções:**
```bash
# 1. Verificar se notificações estão habilitadas
cat config/notification-config.sh | grep MACOS

# 2. Testar notificação manual
osascript -e 'display notification "Teste" with title "Docker Backup"'

# 3. Verificar configurações do macOS
# Sistema > Notificações > Docker Backup
```

#### **Configuração:**
```bash
# Habilitar notificações macOS
MACOS_NOTIFICATIONS_ENABLED=true
NOTIFICATION_TITLE="Docker Backup"
```

## 🚀 Problemas com LaunchAgent

### **"LaunchAgent não executa backup automático"**

#### **Sintomas:**
- Backup não executa no horário agendado
- LaunchAgent não aparece na lista

#### **Soluções:**
```bash
# 1. Verificar status do LaunchAgent
./scripts/utils/install-launchagent.sh status

# 2. Verificar logs do LaunchAgent
./scripts/utils/install-launchagent.sh logs

# 3. Reinstalar LaunchAgent
./scripts/utils/install-launchagent.sh uninstall
./scripts/utils/install-launchagent.sh install

# 4. Testar manualmente
./scripts/utils/install-launchagent.sh test
```

### **"LaunchAgent não carrega"**

#### **Sintomas:**
- Erro: "Could not find specified service"
- LaunchAgent não aparece em `launchctl list`

#### **Soluções:**
```bash
# 1. Verificar arquivo do LaunchAgent
cat /Users/$USER/Library/LaunchAgents/com.user.dockerbackup.plist

# 2. Verificar permissões
ls -la /Users/$USER/Library/LaunchAgents/

# 3. Recarregar LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.user.dockerbackup.plist
launchctl load ~/Library/LaunchAgents/com.user.dockerbackup.plist
```

## 💾 Problemas com Backup

### **"Backup falha por espaço insuficiente"**

#### **Sintomas:**
- Erro: "No space left on device"
- Backup interrompido

#### **Soluções:**
```bash
# 1. Verificar espaço em disco
df -h

# 2. Limpar backups antigos
./blueai-docker-ops.sh cleanup --backups

# 3. Limpar logs antigos
./scripts/logging/log-analyzer.sh --cleanup --days 7

# 4. Verificar tamanho dos backups
ls -lh backups/
```

### **"Backup corrompido"**

#### **Sintomas:**
- Erro: "tar: Unexpected EOF"
- Arquivo de backup com tamanho 0
- Falha na verificação de integridade

#### **Soluções:**
```bash
# 1. Verificar integridade dos backups
./blueai-docker-ops.sh backup list

# 2. Remover backup corrompido
rm backups/[arquivo_corrompido].tar.gz

# 3. Executar novo backup
./blueai-docker-ops.sh backup

# 4. Verificar logs para identificar causa
./blueai-docker-ops.sh logs --errors --recent
```

### **"Backup muito lento"**

#### **Sintomas:**
- Backup demora muito tempo
- Sistema fica lento durante backup

#### **Soluções:**
```bash
# 1. Verificar performance
./blueai-docker-ops.sh logs --performance

# 2. Verificar uso de CPU/Disco
top
iostat 1

# 3. Otimizar horário do backup
./scripts/utils/install-launchagent.sh schedule

# 4. Considerar backup incremental
# (funcionalidade futura)
```

## 📝 Problemas com Logs

### **"Logs não aparecem"**

#### **Sintomas:**
- Arquivos de log vazios
- Logs não são gerados

#### **Soluções:**
```bash
# 1. Verificar se diretório de logs existe
ls -la logs/

# 2. Verificar permissões
ls -la logs/

# 3. Criar diretório se não existir
mkdir -p logs/

# 4. Verificar configuração de logging
cat scripts/logging/logging-functions.sh | head -20
```

### **"Logs muito grandes"**

#### **Sintomas:**
- Arquivos de log ocupam muito espaço
- Sistema fica lento

#### **Soluções:**
```bash
# 1. Limpar logs antigos
./scripts/logging/log-analyzer.sh --cleanup --days 7

# 2. Verificar tamanho dos logs
du -sh logs/

# 3. Configurar rotação de logs
# (funcionalidade futura)
```

## 🔧 Problemas de Permissões

### **"Permission denied"**

#### **Sintomas:**
- Erro: "Permission denied"
- Scripts não executam

#### **Soluções:**
```bash
# 1. Verificar permissões dos scripts
ls -la scripts/
ls -la blueai-docker-ops.sh

# 2. Tornar scripts executáveis
chmod +x blueai-docker-ops.sh
chmod +x scripts/*/*.sh

# 3. Verificar permissões do diretório
ls -la

# 4. Se necessário, ajustar permissões
chmod 755 scripts/
chmod 644 config/*
```

### **"Cannot create directory"**

#### **Sintomas:**
- Erro: "mkdir: Permission denied"
- Não consegue criar diretórios

#### **Soluções:**
```bash
# 1. Verificar permissões do diretório atual
ls -la

# 2. Criar diretórios manualmente
mkdir -p logs/
mkdir -p reports/
mkdir -p backups/

# 3. Verificar permissões
ls -la

# 4. Se necessário, usar sudo
sudo mkdir -p /caminho/para/diretorio
```

## 🌐 Problemas de Rede

### **"Cannot connect to Docker daemon"**

#### **Sintomas:**
- Erro: "Cannot connect to the Docker daemon"
- Docker não responde

#### **Soluções:**
```bash
# 1. Verificar se Docker está rodando
docker ps

# 2. Reiniciar Docker
killall Docker
open -a Docker

# 3. Aguardar inicialização
sleep 30

# 4. Testar conexão
docker version
```

### **"Network timeout"**

#### **Sintomas:**
- Erro: "Connection timed out"
- Backup falha por timeout

#### **Soluções:**
```bash
# 1. Verificar conectividade
ping google.com

# 2. Verificar DNS
nslookup docker.com

# 3. Verificar firewall
# Sistema > Segurança e Privacidade > Firewall

# 4. Se necessário, adicionar exceção
```

## 📊 Problemas de Performance

### **"Sistema muito lento durante backup"**

#### **Sintomas:**
- Sistema fica lento
- Backup demora muito tempo

#### **Soluções:**
```bash
# 1. Verificar uso de recursos
top
iostat 1

# 2. Otimizar horário do backup
./scripts/utils/install-launchagent.sh schedule

# 3. Verificar se outros processos estão rodando
ps aux | grep -v grep | grep -E "(backup|docker)"

# 4. Considerar backup em horário de menor uso
```

### **"Backup consome muita memória"**

#### **Sintomas:**
- Uso de memória alto durante backup
- Sistema fica lento

#### **Soluções:**
```bash
# 1. Verificar uso de memória
free -h
vm_stat

# 2. Verificar processos Docker
docker stats

# 3. Parar containers desnecessários
docker stop [container_desnecessario]

# 4. Limpar recursos Docker
docker system prune
```

## 🔄 Problemas de Restauração

### **"Falha ao restaurar backup"**

#### **Sintomas:**
- Erro durante restauração
- Dados não são restaurados corretamente

#### **Soluções:**
```bash
# 1. Verificar integridade do backup
tar -tzf backups/[arquivo_backup].tar.gz

# 2. Parar container antes da restauração
docker stop [nome_container]

# 3. Restaurar manualmente
docker run --rm -v [nome_volume]:/data -v $(pwd)/backups:/backup alpine tar -xzf /backup/[arquivo_backup].tar.gz -C /data

# 4. Reiniciar container
docker start [nome_container]
```

## 📞 Quando Pedir Ajuda

### **Informações para Incluir:**
1. **Versão do sistema:** `uname -a`
2. **Versão do Docker:** `docker version`
3. **Logs de erro:** `./blueai-docker-ops.sh logs --errors --recent`
4. **Status do sistema:** `./scripts/utils/test-system.sh`
5. **Configuração:** `cat config/notification-config.sh`

### **Comandos de Diagnóstico:**
```bash
# Informações do sistema
./scripts/utils/test-system.sh > diagnostico.txt 2>&1

# Logs recentes
./blueai-docker-ops.sh logs --recent > logs_recentes.txt 2>&1

# Status dos containers
./blueai-docker-ops.sh status > status_containers.txt 2>&1

# Configurações
cat config/notification-config.sh > configuracoes.txt
```

---

**💡 Dica:** Sempre execute `./scripts/utils/test-system.sh` antes de pedir ajuda. Ele fornece informações valiosas para diagnóstico!
