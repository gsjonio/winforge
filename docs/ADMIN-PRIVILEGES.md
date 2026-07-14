# Running Scripts with Administrator Privileges

[English](#english) | [Português](#português)

## English

### Overview

PowerShell doesn't have a native `sudo` command like Linux/macOS. However, there are several ways to run scripts and commands with administrator (elevated) privileges.

### Method 1: Right-Click "Run as Administrator"

**Simplest method for one-time execution:**

1. Open Windows Explorer
2. Navigate to the script location
3. Right-click `setup.ps1`
4. Select "Run with PowerShell"
5. Click "Yes" on the UAC prompt

### Method 2: Command Line Elevation

**Execute a PowerShell script with admin privileges from the command line:**

```powershell
# Basic syntax
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"

# With parameters
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1" -Group shell

# From cmd.exe (Command Prompt)
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \".\setup.ps1\"'"
```

### Method 3: PowerShell Function (closest to sudo)

**Create a `sudo` function in your PowerShell profile:**

```powershell
# Add to $PROFILE
function sudo {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$CommandLine
    )
    
    $cmdString = $CommandLine -join ' '
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$cmdString`""
}
```

**Usage:**

```powershell
sudo .\setup.ps1
sudo .\setup.ps1 -Group optimize
```

### Method 4: Test Before Elevation

**Check if already running as admin, then elevate if needed:**

```powershell
function Test-IsElevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsElevated)) {
    Write-Host "Requesting administrator privileges..."
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Your script runs here with admin privileges
Write-Host "Running with administrator privileges!"
```

### Understanding the Parameters

| Parameter | Purpose |
| ----------- | --------- |
| `-NoProfile` | Skip loading the user's profile (faster) |
| `-ExecutionPolicy Bypass` | Allow unsigned scripts to run (temporary) |
| `-File` | Execute a script file |
| `-Command` | Execute a PowerShell command string |
| `-Verb RunAs` | Request admin elevation via UAC |

### Important Notes

⚠️ **UAC Prompt**: You'll see a "User Account Control" dialog asking for confirmation
⚠️ **Execution Policy**: `-ExecutionPolicy Bypass` is temporary for that session only
✅ **Safe**: These methods use Windows' built-in security (UAC)
✅ **Reversible**: Can be run without elevation if not needed

### Why Admin Privileges Are Needed

The setup script requires admin privileges for:

- ✅ Installing fonts (`C:\Windows\Fonts\`)
- ✅ Modifying system registry
- ✅ Installing Windows features
- ✅ Modifying system-wide configurations
- ✅ Installing programs to `C:\Program Files\`

Without admin, the script will warn you and ask to continue anyway.

### Troubleshooting

**Q: "Access Denied" error?**
A: Run with admin privileges using Method 1 or 2

**Q: "Execution policy" error?**
A: Use `-ExecutionPolicy Bypass` flag

**Q: UAC prompt won't appear?**
A: Check if UAC is disabled in Settings → System → Security

**Q: Want to disable elevation prompts?**
A: Not recommended for security reasons. Instead, add your user to Administrators group (not recommended)

---

## Português

### Visão Geral

PowerShell não tem um comando nativo `sudo` como Linux/macOS. Porém, há várias formas de executar scripts e comandos com privilégios de administrador.

### Método 1: Clique Direito "Executar como Administrador"

**Método mais simples para execução única:**

1. Abra o Explorador de Arquivos
2. Navegue até a localização do script
3. Clique direito em `setup.ps1`
4. Selecione "Executar com o PowerShell"
5. Clique "Sim" no prompt UAC

### Método 2: Elevação via Linha de Comando

**Execute um script PowerShell com privilégios de admin da linha de comando:**

```powershell
# Sintaxe básica
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1"

# Com parâmetros
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup.ps1" -Group shell

# De cmd.exe (Prompt de Comando)
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \".\setup.ps1\"'"
```

### Método 3: Função PowerShell (o mais próximo de sudo)

**Crie uma função `sudo` no seu perfil do PowerShell:**

```powershell
# Adicione a $PROFILE
function sudo {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$CommandLine
    )
    
    $cmdString = $CommandLine -join ' '
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$cmdString`""
}
```

**Uso:**

```powershell
sudo .\setup.ps1
sudo .\setup.ps1 -Group optimize
```

### Método 4: Testar Antes de Elevar

**Verificar se já está como admin, depois elevar se necessário:**

```powershell
function Test-IsElevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsElevated)) {
    Write-Host "Solicitando privilégios de administrador..."
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Seu script executa aqui com privilégios de admin
Write-Host "Executando com privilégios de administrador!"
```

### Entendendo os Parâmetros

| Parâmetro | Propósito |
| ----------- | ---------- |
| `-NoProfile` | Pula o carregamento do perfil do usuário (mais rápido) |
| `-ExecutionPolicy Bypass` | Permite executar scripts não assinados (temporário) |
| `-File` | Executa um arquivo de script |
| `-Command` | Executa uma string de comando PowerShell |
| `-Verb RunAs` | Solicita elevação de admin via UAC |

### Notas Importantes

⚠️ **Prompt UAC**: Você verá um diálogo de "Controle de Conta de Usuário" pedindo confirmação
⚠️ **Execution Policy**: `-ExecutionPolicy Bypass` é temporário apenas para essa sessão
✅ **Seguro**: Esses métodos usam a segurança integrada do Windows (UAC)
✅ **Reversível**: Pode ser executado sem elevação se não for necessário

### Por Que Privilégios de Admin São Necessários

O script de setup necessita privilégios de admin para:

- ✅ Instalar fontes (`C:\Windows\Fonts\`)
- ✅ Modificar registro do sistema
- ✅ Instalar recursos do Windows
- ✅ Modificar configurações em nível de sistema
- ✅ Instalar programas em `C:\Program Files\`

Sem admin, o script o avisará e pedirá confirmação para continuar mesmo assim.

### Solução de Problemas

**P: Erro "Acesso Negado"?**
R: Execute com privilégios de admin usando Método 1 ou 2

**P: Erro de "Execution policy"?**
R: Use a flag `-ExecutionPolicy Bypass`

**P: Prompt UAC não aparece?**
R: Verifique se UAC está desabilitado em Configurações → Sistema → Segurança

**P: Quer desabilitar prompts de elevação?**
R: Não recomendado por razões de segurança. Em vez disso, adicione seu usuário ao grupo Administrators (não recomendado)
