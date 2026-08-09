$ErrorActionPreference = 'SilentlyContinue'

Write-Output "`n[AEGIS HUNTER] Lancement du balayage des services de télémétrie..."

# 1. Liste des services connus pour l'espionnage
$spyServices = @("DiagTrack", "dmwappushservice", "wercplsupport", "PcaSvc", "CDPSvc", "Census")

Write-Output "`n--- ÉTAT DES SERVICES SYSTÈME ---"
foreach ($svcName in $spyServices) {
    $svc = Get-Service -Name $svcName
    if ($svc) {
        if ($svc.Status -eq 'Running') {
            Write-Output "[!] DANGER : Le service $($svc.Name) ($($svc.DisplayName)) est ACTIF et tourne."
        } else {
            Write-Output "[✓] SÉCURISÉ : Le service $($svc.Name) est arrêté."
        }
    }
}

# 2. Chasse aux tâches planifiées du "Customer Experience Improvement Program" (CEIP)
Write-Output "`n--- TÂCHES PLANIFIÉES (CEIP) ---"
$tasks = Get-ScheduledTask | Where-Object { $_.TaskPath -match "Customer Experience Improvement Program" -or $_.TaskPath -match "Autochk" }
if ($tasks) {
    foreach ($task in $tasks) {
        if ($task.State -ne 'Disabled') {
            Write-Output "[!] TÂCHE ACTIVE : $($task.TaskName) dans $($task.TaskPath)"
        }
    }
} else {
    Write-Output "[✓] Aucune tâche du programme d'amélioration détectée."
}

Write-Output "`n[HUNTER FINI] Balayage terminé."
