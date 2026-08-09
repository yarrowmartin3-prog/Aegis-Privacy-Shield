# Aegis Privacy Shield & Terminator 🛡️
*Propulsé par NovaSuite Technologies*

Une suite de scripts PowerShell (Blue Team) conçue pour éradiquer les identifiants de suivi persistants (GDID), désactiver la télémétrie du noyau et rendre le durcissement de Windows 11 *Self-Healing* (auto-réparateur).

## ⚠️ AVERTISSEMENT : Mode Zéro Compromis
Ce script est conçu pour les environnements exigeant une souveraineté numérique absolue. Il coupe les ponts avec l'infrastructure d'identité Microsoft. 
**En exécutant ce script, les services suivants seront BRISÉS et cesseront de fonctionner :**
* Le Microsoft Store (et les mises à jour d'applications UWP)
* L'écosystème Xbox (PC Game Pass, authentification Xbox Live)
* La synchronisation native OneDrive
* L'enrôlement automatique des appareils Windows

Si vous utilisez votre PC pour le développement, la cybersécurité (Kali, Termux) ou que vous jouez sur console, ce compromis offre une confidentialité inégalée.

## 📂 Fichiers inclus
* `aegis_privacy_shield.ps1` : Le script principal pour purger le Registre et bloquer les domaines.
* `install_sentinel.ps1` : Installe une tâche planifiée cachée qui réapplique le bouclier réseau.
* `aegis_terminator.ps1` : Le protocole d'éradication forçant l'arrêt des services de télémétrie (DiagTrack, CDPSvc) et des tâches CEIP.
* `install_terminator_sentinel.ps1` : Installe le daemon d'auto-guérison pour s'assurer que les services abattus ne ressuscitent jamais.
* `aegis_hunter.ps1` : Un scanner de reconnaissance pour auditer l'état des services et confirmer le silence radio.

## 🛠️ Déploiement et Haute Disponibilité (Faux Positifs)

**Note sur Windows Defender :** Ces scripts modifient le fichier `hosts`, purgent des clés de registre et créent des tâches invisibles avec les privilèges `SYSTEM`. Windows Defender détectera ces actions comme une menace heuristique (ex: *SettingsModifier:Win32/HostsFileHijack*). **C'est un faux positif attendu.**

Pour garantir la résilience de l'environnement (Self-Healing) et éviter la suppression des fichiers, il est impératif de créer un dossier sanctuaire sur le lecteur principal et de l'exclure des analyses avant l'exécution.

### Installation recommandée (PowerShell Administrateur) :

```powershell
# 1. Créer le bunker sur le disque principal
New-Item -Path "C:\NovaSuite_Aegis" -ItemType Directory -Force

# 2. Mettre le dossier sur liste blanche (Exclusion Defender)
Add-MpPreference -ExclusionPath "C:\NovaSuite_Aegis"

# 3. Copier vos scripts dans ce dossier, se placer dedans, puis lancer :
.\install_sentinel.ps1
.\install_terminator_sentinel.ps1

### Installation recommandée (PowerShell Administrateur) :

```powershell
# 1. Créer le bunker sur le disque principal
New-Item -Path "C:\NovaSuite_Aegis" -ItemType Directory -Force

# 2. Mettre le dossier sur liste blanche (Exclusion Defender)
Add-MpPreference -ExclusionPath "C:\NovaSuite_Aegis"

# 3. Déployer les sentinelles :
.\install_sentinel.ps1
.\install_terminator_sentinel.ps1

# 4. Vérifier le silence radio (Audit) :
.\aegis_hunter.ps1