<#
.SYNOPSIS
    Windows 11 Home Advanced Debloat Script
    Versão: 1.0
    Autor: Moysés Voss
    Data: 23/04/2026

.DESCRIPTION
    Este script realiza um debloat seguro no Windows 11 Pro, removendo aplicativos desnecessários,
    desativando telemetria, otimizando o desempenho e ajustando configurações de privacidade.
    Inclui criação de ponto de restauração e interface colorida.

.NOTES
    Requer privilégios de Administrador.
    Compatível especificamente com Windows 11 Pro.
#>

$ErrorActionPreference = "SilentlyContinue"

# INTERFACE

function Write-Header {
    param([string]$Text)
    Write-Host "`n====================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "====================================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Text)
    Write-Host "[ERRO] $Text" -ForegroundColor Red
}

# VERIFICAR ADMIN

function Test-Admin {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-ErrorMsg "Execute o PowerShell como administrador."
        exit
    }
}

# PONTO DE RESTAURAÇÃO

function Create-RestorePoint {

    Write-Header "CRIANDO PONTO DE RESTAURAÇÃO"

    try {
        Enable-ComputerRestore -Drive "C:\"
        Checkpoint-Computer -Description "DebloatHome_BeforeChanges" -RestorePointType MODIFY_SETTINGS
        Write-Success "Ponto de restauração criado."
    }
    catch {
        Write-ErrorMsg "Não foi possível criar ponto de restauração."
    }
}

# REMOVER BLOATWARE

function Remove-Bloatware {

    Write-Header "REMOVENDO APLICATIVOS DESNECESSÁRIOS"

    $apps = @(
        "*Xbox*"
        "*Clipchamp*"
        "*SkypeApp*"
        "*MicrosoftSolitaireCollection*"
        "*PowerAutomateDesktop*"
        "*BingNews*"
        "*Weather*"
        "*GetHelp*"
        "*Getstarted*"
        "*WindowsFeedbackHub*"
        "*YourPhone*"
        "*Microsoft3DViewer*"
    )

    foreach ($app in $apps) {

        Write-Host "Removendo $app..." -ForegroundColor Gray

        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online |
        Where-Object DisplayName -like $app |
        Remove-AppxProvisionedPackage -Online
    }

    Write-Success "Remoção concluída."
}

# TELEMETRIA (versão compatível com Home)

function Disable-Telemetry {

    Write-Header "REDUZINDO TELEMETRIA"

    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\DataCollection" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 1

    Stop-Service DiagTrack -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled

    Stop-Service dmwappushservice -ErrorAction SilentlyContinue
    Set-Service dmwappushservice -StartupType Disabled

    Write-Success "Serviços de telemetria desativados."
}

# OTIMIZAÇÕES

function Optimize-Performance {

    Write-Header "APLICANDO OTIMIZAÇÕES"

    Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SystemPaneSuggestionsEnabled" -Value 0

    Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Start_IrisRecommendations" -Value 0

    Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
    -Name "GlobalUserDisabled" -Value 1

    Write-Success "Otimizações aplicadas."
}

# EXTRAS

function Apply-Extras {

    Write-Header "AJUSTES EXTRAS"

    # desativar widgets

    New-Item `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
    -Force | Out-Null

    Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
    -Name "AllowNewsAndInterests" `
    -Value 0

    Write-Success "Widgets desativados."

    # limpar temporários

    Write-Host "Limpando arquivos temporários..." -ForegroundColor Gray

    Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue |
    Remove-Item -Force -Recurse

    Get-ChildItem "C:\Windows\Temp" -Recurse -ErrorAction SilentlyContinue |
    Remove-Item -Force -Recurse

    Write-Success "Limpeza concluída."
}

# MENU

function Show-Menu {

    Clear-Host

    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "   WINDOWS 11 HOME DEBLOAT TOOL"
    Write-Host "====================================================`n" -ForegroundColor Cyan

    Write-Host "1 - Debloat completo"
    Write-Host "2 - Remover aplicativos"
    Write-Host "3 - Reduzir telemetria"
    Write-Host "4 - Otimizar desempenho"
    Write-Host "5 - Extras"
    Write-Host "6 - Sair"

    Write-Host "`nEscolha: " -NoNewline
}

# EXECUÇÃO


$choice=""

while($choice -ne "6"){

    Show-Menu

    $choice=Read-Host

    switch($choice){

        "1"{
            Create-RestorePoint
            Remove-Bloatware
            Disable-Telemetry
            Optimize-Performance
            Apply-Extras
            Pause
        }

        "2"{Remove-Bloatware;Pause}

        "3"{Disable-Telemetry;Pause}

        "4"{Optimize-Performance;Pause}

        "5"{Apply-Extras;Pause}

        "6"{Write-Host "Saindo..."}

        default{Write-ErrorMsg "Opção inválida"}
    }
}

Read-Host "Pressione ENTER para sair"
