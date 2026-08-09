<#
.SYNOPSIS
    Aegis Privacy Shield (Mode Zéro Compromis)
    Éradication du GDID, verrouillage du réseau de télémétrie et nettoyage des identifiants cachés.
.DESCRIPTION
    Script propriétaire de NovaSuite Technologies pour la souveraineté numérique absolue.
#>

[CmdletBinding()]
param(
    [switch]$AuditOnly,
    [switch]$ShieldUp,
    [switch]$TearDown
)

$ErrorActionPreference = 'Stop'

$script:AegisBlockHosts = @(
    'login.live.com',
    'account.live.com',
    'cs.dds.microsoft.com',
    'dds.microsoft.com',
    'aad.cs.dds.microsoft.com',
    'fd.dds.microsoft.com',
    'cdpcs.access.microsoft.com',
    'ztd.dds.microsoft.com',
    'activity.windows.com',
    'assets.activity.windows.com',
    'edge.activity.windows.com',
    'telemetry.microsoft.com',
    'vortex.data.microsoft.com',
    'Settings-win.data.microsoft.com'
)

$script:HostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$script:MarkerBegin = '# BEGIN AEGIS PRIVACY SHIELD'
$script:MarkerEnd = '# END AEGIS PRIVACY SHIELD'

function Test-Administrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-AegisAudit {
    Write-Output "`n[AEGIS AUDIT] Analyse des identifiants et de la posture de confidentialité..."
    
    $hives = @(
        @{ Name = "Utilisateur Courant"; Path = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\IdentityCRL\ExtendedProperties" },
        @{ Name = "SYSTEM"; Path = "Registry::HKEY_USERS\S-1-5-18\SOFTWARE\Microsoft\IdentityCRL\ExtendedProperties" }
    )

    foreach ($hive in $hives) {
        if (Test-Path $hive.Path) {
            $lid = (Get-ItemProperty $hive.Path -ErrorAction SilentlyContinue).LID
            if ($lid) {
                Write-Output "  [!] GDID Actif détecté dans [$($hive.Name)] : $lid"
            } else {
                Write-Output "  [✓] Aucun GDID clair dans [$($hive.Name)]"
            }
        } else {
            Write-Output "  [✓] Ruche [$($hive.Name)] propre ou absente"
        }
    }

    $adIdPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    if (Test-Path $adIdPath) {
        $enabled = (Get-ItemProperty $adIdPath -ErrorAction SilentlyContinue).Enabled
        if ($enabled -eq 1) {
            Write-Output "  [!] ID Publicitaire activé (Risque de profilage marketing)"
        } else {
            Write-Output "  [✓] ID Publicitaire désactivé"
        }
    } else {
        Write-Output "  [✓] Clé d'ID Publicitaire absente"
    }

    if (Test-Path $script:HostsPath) {
        $content = Get-Content $script:HostsPath -Raw
        if ($content -match [regex]::Escape($script:MarkerBegin)) {
            Write-Output "  [✓] Le bouclier réseau Aegis est actif dans le fichier hosts."
        } else {
            Write-Output "  [!] Le fichier hosts ne contient pas le blindage Aegis."
        }
    }
}

function Invoke-AegisShieldUp {
    if (-not (Test-Administrator)) {
        Write-Output "[-] Erreur : Le déploiement du bouclier nécessite des privilèges Administrateur."
        exit 1
    }

    Write-Output "`n[AEGIS SHIELD] Déploiement du protocole Zéro Compromis..."

    $adIdPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    if (-not (Test-Path $adIdPath)) { New-Item -Path $adIdPath -Force | Out-Null }
    Set-ItemProperty -Path $adIdPath -Name "Enabled" -Value 0 -Force
    Write-Output "  [+] ID Publicitaire neutralisé."

    $purgePaths = @(
        "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\IdentityCRL\ExtendedProperties",
        "Registry::HKEY_USERS\S-1-5-18\SOFTWARE\Microsoft\IdentityCRL\ExtendedProperties"
    )
    foreach ($path in $purgePaths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Output "  [+] Ruche purgée : $path"
        }
    }

    $hostsContent = Get-Content $script:HostsPath -Raw -ErrorAction SilentlyContinue
    if ($hostsContent -notmatch [regex]::Escape($script:MarkerBegin)) {
        $blockBlock = "`n$script:MarkerBegin`n"
        foreach ($hostName in $script:AegisBlockHosts) {
            $blockBlock += "0.0.0.0 $hostName`n"
            $blockBlock += ":: $hostName`n"
        }
        $blockBlock += "$script:MarkerEnd`n"
        
        Add-Content -Path $script:HostsPath -Value $blockBlock -Force
        Write-Output "  [+] Domaines de télémétrie et d'enrôlement bloqués au niveau du système."
    }

    ipconfig /flushdns | Out-Null
    Write-Output "  [+] Cache DNS nettoyé."
    Write-Output "`n[SUCCESS] Le Bouclier Aegis est pleinement opérationnel (Mode Zéro Compromis)."
}

if (-not $AuditOnly -and -not $ShieldUp -and -not $TearDown) {
    $script:AuditOnly = $true
}

if ($AuditOnly) { Invoke-AegisAudit }
if ($ShieldUp) { Invoke-AegisShieldUp }
