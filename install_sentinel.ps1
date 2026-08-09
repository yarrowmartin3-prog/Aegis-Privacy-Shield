$ErrorActionPreference = 'Stop'
$hostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$markerBegin = '# BEGIN AEGIS PRIVACY SHIELD'

$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principalCheck = [System.Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principalCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "[-] Erreur : Lancez ce script en Administrateur."
    exit 1
}

Write-Output "[AEGIS SENTINEL] Installation de la tâche planifiée Self-Healing..."
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -Command `"if ((Get-Content '$hostsPath' -Raw) -notmatch '$markerBegin') { & 'D:\aegis_privacy_shield.ps1' -ShieldUp }`""

# Déclencheur 1 : Exécution immédiate au démarrage
$trigger1 = New-ScheduledTaskTrigger -AtStartup

# Déclencheur 2 : Exécution répétée toutes les heures indéfiniment
$trigger2 = New-ScheduledTaskTrigger -Once -At "12:00 AM" -RepetitionInterval (New-TimeSpan -Hours 1)

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "AegisPrivacySentinel" -Action $action -Trigger @($trigger1, $trigger2) -Principal $principal -Settings $settings -Force | Out-Null
Write-Output "[+] Tâche AegisPrivacySentinel installée avec succès ! Le bunker s'auto-répare désormais en arrière-plan."
