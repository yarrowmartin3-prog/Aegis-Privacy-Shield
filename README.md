# Aegis Privacy Shield 🛡️
*Propulsé par NovaSuite Technologies*

Un script PowerShell de durcissement (Hardening) conçu pour éradiquer les identifiants de suivi persistants (GDID) et bloquer la télémétrie de bas niveau sur Windows 11.

## ⚠️ AVERTISSEMENT : Mode Zéro Compromis
Ce script est conçu pour les environnements exigeant une souveraineté numérique absolue. Il coupe les ponts avec l'infrastructure d'identité Microsoft. 
**En exécutant ce script, les services suivants seront BRISÉS et cesseront de fonctionner :**
* Le Microsoft Store (et les mises à jour d'applications UWP)
* L'écosystème Xbox (PC Game Pass, authentification Xbox Live)
* La synchronisation native OneDrive
* L'enrôlement automatique des appareils Windows

Si vous utilisez votre PC pour le développement, la cybersécurité (Kali, Termux) ou que vous jouez sur console (PS5), ce compromis offre une confidentialité inégalée.

## Fichiers inclus
* `aegis_privacy_shield.ps1` : Le script principal pour purger le Registre et bloquer les domaines.
* `install_sentinel.ps1` : Installe une tâche planifiée cachée (Self-Healing) qui réapplique le bouclier si Windows tente de le supprimer.