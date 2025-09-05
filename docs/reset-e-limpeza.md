# 🚨 Reset e Limpeza - BlueAI Docker Ops

Documentação completa dos comandos de reset e limpeza do sistema.

## ⚠️ **ATENÇÃO: COMANDOS PERIGOSOS!**

Os comandos documentados nesta seção são **extremamente perigosos** e podem resultar na **perda irreversível de dados**. Use-os apenas quando:

- ✅ **Tenha certeza absoluta** do que está fazendo
- ✅ **Tenha feito backup** de todas as configurações importantes
- ✅ **Entenda completamente** as consequências
- ✅ **Tenha um plano de recuperação** definido

## 🔧 Comandos Disponíveis

### **🧹 `clean-data` - Limpeza Seletiva de Dados**

**Propósito:** Limpar dados temporários e arquivos de sistema sem afetar configurações.

**O que é APAGADO:**
- 📦 Backups de dados (arquivos `.tar.gz`)
- 📊 Logs do sistema (arquivos `.log`)
- 📈 Relatórios gerados (HTML, TXT)
- 🗂️ Arquivos temporários do sistema

**O que é PRESERVADO:**
- ⚙️ Configurações de containers
- 🔔 Configurações de notificações
- 🕐 Configurações de agendamento
- 🏗️ Estrutura do sistema
- 📁 Templates de configuração

**Uso Recomendado:**
```bash
# Para manutenção regular (semanal/mensal)
./blueai-docker-ops.sh clean-data

# Para liberar espaço em disco
./blueai-docker-ops.sh clean-data

# Para limpeza antes de reinstalação
./blueai-docker-ops.sh clean-data
```

**Confirmação:** Digite `LIMPAR` para confirmar

---

### **🚨 `factory-reset` - Reset Completo de Fábrica**

**Propósito:** Resetar o sistema para o estado de instalação limpa, apagando TUDO.

**O que é APAGADO:**
- ⚙️ **TODAS** as configurações locais
- 📦 **TODOS** os backups de dados
- 📊 **TODOS** os logs do sistema
- 📈 **TODOS** os relatórios
- 🕐 **TODAS** as configurações de agendamento
- 🔔 **TODAS** as notificações configuradas
- 🌍 **TODAS** as variáveis de ambiente
- 🗂️ **TODOS** os arquivos temporários

**O que é RESTAURADO:**
- 📁 Templates de configuração limpos
- 🏗️ Estrutura básica do sistema
- 📚 Documentação do sistema

**Uso Recomendado:**
```bash
# Para problemas graves no sistema
./blueai-docker-ops.sh factory-reset

# Para mudança de ambiente (nova máquina)
./blueai-docker-ops.sh factory-reset

# Para testes de instalação
./blueai-docker-ops.sh factory-reset

# Para instalação completamente limpa
./blueai-docker-ops.sh factory-reset
```

**Confirmação:** Digite `RESET` + `CONFIRMO` (dupla confirmação)

---

## 🛡️ Medidas de Segurança

### **1. Confirmações Múltiplas**
- **`clean-data`** → Confirmação simples (`LIMPAR`)
- **`factory-reset`** → Confirmação dupla (`RESET` + `CONFIRMO`)

### **2. Backups Automáticos**
- Arquivos de configuração do shell são preservados
- Timestamps em todos os backups
- Logs de todas as operações

### **3. Validações**
- Verificação de existência de arquivos
- Contagem de itens removidos
- Relatórios detalhados de limpeza

## 📋 Fluxo de Uso Recomendado

### **Para Limpeza de Manutenção:**
```bash
1. Verificar espaço em disco
   df -h

2. Executar limpeza
   ./blueai-docker-ops.sh clean-data

3. Verificar resultado
   ./blueai-docker-ops.sh status
```

### **Para Reset Completo:**
```bash
1. Fazer backup manual de configurações importantes
   cp -r config/ config-backup-$(date +%Y%m%d_%H%M%S)/

2. Executar reset
   ./blueai-docker-ops.sh factory-reset

3. Reconfigurar sistema
   ./blueai-docker-ops.sh setup

4. Configurar containers
   ./blueai-docker-ops.sh config

5. Configurar agendamento
   ./blueai-docker-ops.sh schedule
```

## 🚨 Cenários de Emergência

### **Sistema Corrompido:**
```bash
# 1. Tentar recuperação normal
./blueai-docker-ops.sh recovery

# 2. Se falhar, fazer reset
./blueai-docker-ops.sh factory-reset

# 3. Reconfigurar do zero
./blueai-docker-ops.sh setup
```

### **Problemas de Performance:**
```bash
# 1. Limpar dados temporários
./blueai-docker-ops.sh clean-data

# 2. Verificar logs
./blueai-docker-ops.sh logs

# 3. Testar sistema
./blueai-docker-ops.sh test
```

### **Mudança de Ambiente:**
```bash
# 1. Fazer reset completo
./blueai-docker-ops.sh factory-reset

# 2. Configurar nova instalação
./blueai-docker-ops.sh setup

# 3. Adaptar configurações para novo ambiente
./blueai-docker-ops.sh config
```

## 📚 Próximos Passos

Após usar qualquer comando de reset:

1. **Reinicie o terminal** para aplicar mudanças
2. **Execute setup** para reconfigurar o sistema
3. **Configure containers** para backup
4. **Configure agendamento** para automação
5. **Teste o sistema** para validar funcionamento

## 🔗 Comandos Relacionados

- **`./blueai-docker-ops.sh setup`** - Reconfiguração após reset
- **`./blueai-docker-ops.sh config`** - Configuração de containers
- **`./blueai-docker-ops.sh schedule`** - Configuração de agendamento
- **`./blueai-docker-ops.sh test`** - Validação do sistema
- **`./blueai-docker-ops.sh advanced`** - Outros comandos avançados

---

**⚠️ LEMBRE-SE: Estes comandos são irreversíveis. Use com extrema cautela!**
