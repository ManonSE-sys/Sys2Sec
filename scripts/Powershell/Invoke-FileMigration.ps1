<#
.SYNOPSIS
    Copie récursivement des données avec Robocopy.

.DESCRIPTION
    Exemple de script PowerShell permettant d'automatiser une migration
    de fichiers avec Robocopy.

    Fonctionnalités :
    - copie des sous-répertoires ;
    - plusieurs tentatives en cas d'échec ;
    - génération d'un fichier de log ;
    - vérification des chemins avant exécution.

.NOTES
    Projet : Sys2Sec
#>

$Source      = "C:\Data\Source"
$Destination = "D:\Data\Destination"
$LogFolder   = "C:\Temp"
$LogFile     = "$LogFolder\robocopy.log"

if (-not (Test-Path $Source)) {
    Write-Error "Le répertoire source n'existe pas : $Source"
    exit 1
}

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

if (-not (Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

Write-Host "Début de la copie..."
Write-Host "Source      : $Source"
Write-Host "Destination : $Destination"

robocopy `
    $Source `
    $Destination `
    /E `
    /R:5 `
    /W:5 `
    /LOG:$LogFile

$ExitCode = $LASTEXITCODE

Write-Host "Code retour Robocopy : $ExitCode"

if ($ExitCode -lt 8) {
    Write-Host "La copie s'est terminée sans erreur critique."
}
else {
    Write-Error "Robocopy a rencontré une erreur."
    exit $ExitCode
}
