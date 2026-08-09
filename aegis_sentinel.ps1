<#
.SYNOPSIS
    Aegis Sentinel & Artifact Hunter (Self-Healing & Deep Privacy)
.DESCRIPTION
    Surveille, répare automatiquement le bouclier et chasse les mouchards cachés du Registre.
#>

[CmdletBinding()]
param(
    [switch]$InstallSentinel,
    [switch]$HuntArtifacts
)

$ErrorActionPreference = 'Stop'
$script:HostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$script:MarkerBegin = '# BEGIN AEGIS PRIVACY SHIELD'
$script:MarkerEnd = '# END AEGIS PRIVACY SHIELD'

function Test-Administrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-ArtifactHunter {
    Write-Output "`n[AEGIS ARTIFACT HUNTER] Analyse approfondie des mouchards et processus cachés..."

    $diagTrackPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DiagTrack"
    if (Test-Path $diagTrackPath) {
        $startType = (Get-ItemProperty $diagTrackPath -ErrorAction SilentlyContinue).Start
        if ($startType -ne 4) {
            Write-Output "  [!] Service DiagTrack (Télémétrie active) détecté comme non désactivé (Start=$startType)"
        } else {
            Write-Output "  [✓] Service DiagTrack déjà neutralisé."
        }
    }

    $cloudContentPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    if (Test-Path $cloudContentPath) {
        Write-Output "  [✓] Politiques de contenu cloud présentes."
    } else {
        Write-Output "  [!] Absence de restriction sur le contenu cloud et les applications suggérées."
    }

    $deviceIdentitiesPath = "Registry::HKEY_USERS\S-1-5-18\Software\Microsoft\IdentityCRL\DeviceIdentities"
    if (Test-Path $deviceIdentitiesPath) {
        Write-Output "  [!] Arbre DeviceIdentities (SYSTEM) présent. Risque d'association matérielle."
    } else {
        Write-Output "  [✓] Arbre DeviceIdentities propre."
    }

    if (Test-Path $script:HostsPath) {
        $content = Get-Content $script:HostsPath -Raw
        if ($content -match [regex]::Escape($script:MarkerBegin)) {
            Write-Output "  [✓] Intégrité du fichier hosts : Bouclier présent."
        } else {
            Write-Output "  [!] ALERTE : Le bouclier hosts a été altéré ou supprimé !"
        }
    }
    Write-Output "`n[HUNTER FINI] Fin de l'analyse des artefacts."
}

function Install-AegisSentinelTask {
    if (-not (Test-Administrator)) {
        Write-Output "[-] Erreur : L'installation du mécanisme Self-Healing nécessite les privilèges Administrateur."
        exit 1
    }

    Write-Output "`n[AEGIS SENTINEL] Installation du daemon d'auto-guérison (Self-Healing)..."
    
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -Command `"if ((Get-Content '$script:HostsPath' -Raw) -notmatch '$script:MarkerBegin') { & 'D:\aegis_privacy_shield.ps1' -ShieldUp }`""
    $trigger = New-ScheduledTaskTrigger -AtStartup -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration ([TimeSpan]::MaxValue)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    Register-ScheduledTask -TaskName "AegisPrivacySentinel" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Output "  [+] Sentinel enregistrée avec succès. Le bouclier est désormais Self-Healing (vérification horaire par SYSTEM)."
}

if ($InstallSentinel) {
    Install-AegisSentinelTask
} else {
    Invoke-ArtifactHunter
}
