$ErrorActionPreference = 'SilentlyContinue'

Write-Output "`n[AEGIS TERMINATOR] Lancement du protocole d'éradication..."

$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principalCheck = [System.Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principalCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "[-] Erreur critique : Le Terminator nécessite les privilèges Administrateur. Abandon de la frappe."
    exit 1
}

# 1. Neutralisation profonde des services d'espionnage
$targetServices = @("DiagTrack", "PcaSvc", "CDPSvc", "dmwappushservice", "wercplsupport")
Write-Output "`n[+] Purge des services de télémétrie :"

foreach ($svcName in $targetServices) {
    $svc = Get-Service -Name $svcName
    if ($svc) {
        # Arrêt forcé du service en cours
        Stop-Service -Name $svcName -Force
        # Désactivation via l'API de gestion
        Set-Service -Name $svcName -StartupType Disabled
        
        # Verrouillage absolu via le Registre (Start = 4 signifie Désactivé)
        $regPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$svcName"
        if (Test-Path $regPath) {
            Set-ItemProperty -Path $regPath -Name "Start" -Value 4 -Force
        }
        Write-Output "  [X] Service $svcName abattu et verrouillé."
    }
}

# 2. Désactivation des coursiers silencieux (Tâches planifiées)
Write-Output "`n[+] Désactivation des tâches d'amélioration de l'expérience (CEIP) :"
$tasksToDisable = @(
    @{Name="Proxy"; Path="\Microsoft\Windows\Autochk\"},
    @{Name="Consolidator"; Path="\Microsoft\Windows\Customer Experience Improvement Program\"},
    @{Name="UsbCeip"; Path="\Microsoft\Windows\Customer Experience Improvement Program\"}
)

foreach ($taskInfo in $tasksToDisable) {
    $task = Get-ScheduledTask -TaskName $taskInfo.Name -TaskPath $taskInfo.Path
    if ($task) {
        Disable-ScheduledTask -TaskName $taskInfo.Name -TaskPath $taskInfo.Path | Out-Null
        Write-Output "  [X] Tâche $($taskInfo.Name) désactivée avec succès."
    }
}

Write-Output "`n[TERMINATOR FINI] La zone est sécurisée. Les canaux d'écoute sont détruits."
