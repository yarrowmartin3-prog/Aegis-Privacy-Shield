$ErrorActionPreference = 'Stop'

$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principalCheck = [System.Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principalCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "[-] Erreur : Lancez ce script en Administrateur."
    exit 1
}

Write-Output "[AEGIS TERMINATOR SENTINEL] Installation du daemon d'auto-guérison pour les services..."

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"D:\aegis_terminator.ps1`""

$trigger1 = New-ScheduledTaskTrigger -AtStartup
$trigger2 = New-ScheduledTaskTrigger -Once -At "12:00 AM" -RepetitionInterval (New-TimeSpan -Hours 1)

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "AegisTerminatorSentinel" -Action $action -Trigger @($trigger1, $trigger2) -Principal $principal -Settings $settings -Force | Out-Null

Write-Output "[+] Tâche AegisTerminatorSentinel installée avec succès ! L'éradication est désormais permanente."
