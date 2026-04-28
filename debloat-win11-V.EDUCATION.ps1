<#
.SYNOPSIS
    Windows 11 Education Advanced Debloat Script
    Versão: 1.0
    Autor: Moysés Voss
    Data: 23/04/2026

.DESCRIPTION
    Script de otimização e debloat para Windows 11 Education.
    Remove aplicativos UWP desnecessários, desativa telemetria,
    melhora privacidade e otimiza desempenho.

.NOTES
    Requer privilégios de Administrador.
    Compatível com Windows 11 Education / Enterprise.
#>

$ErrorActionPreference = "SilentlyContinue"

# --- INTERFACE ---
function Write-Header {
    param([string]$Text)
    Write-Host "`n====================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "====================================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "[OK] " -NoNewline -ForegroundColor Green
    Write-Host $Text
}

function Write-ErrorMsg {
    param([string]$Text)
    Write-Host "[ERRO] " -NoNewline -ForegroundColor Red
    Write-Host $Text
}

# --- ADMIN CHECK ---
function Test-Admin {

    $principal = New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )

    if (-not $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )) {

        Write-ErrorMsg "Execute o PowerShell como Administrador."
        exit
    }
}

Test-Admin

# --- RESTORE POINT ---
function Create-RestorePoint {

    Write-Header "CRIANDO PONTO DE RESTAURAÇÃO"

    try {

        Enable-ComputerRestore -Drive "C:\"
        Checkpoint-Computer `
            -Description "EducationDebloat_BeforeOptimization" `
            -RestorePointType MODIFY_SETTINGS

        Write-Success "Ponto de restauração criado."

    } catch {

        Write-ErrorMsg "Não foi possível criar ponto de restauração."
    }
}

# --- REMOÇÃO DE APPS ---
function Remove-Bloatware {

    Write-Header "REMOVENDO APLICATIVOS UWP"

    $Apps = @(

        "*Xbox*"
        "*Clipchamp*"
        "*BingNews*"
        "*Weather*"
        "*People*"
        "*3DViewer*"
        "*MixedReality*"
        "*SkypeApp*"
        "*Solitaire*"
        "*PowerAutomateDesktop*"
        "*MicrosoftTeams*"
        "*YourPhone*"
        "*GetHelp*"
        "*GetStarted*"
        "*WindowsFeedbackHub*"
        "*OfficeHub*"
        "*ZuneMusic*"
        "*ZuneVideo*"

    )

    foreach ($app in $Apps) {

        Write-Host "Removendo $app"

        Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage

        Get-AppxProvisionedPackage -Online |
        Where-Object DisplayName -Like $app |
        Remove-AppxProvisionedPackage -Online
    }

    Write-Success "Apps removidos."
}

# --- TELEMETRIA ---
function Disable-Telemetry {

    Write-Header "DESATIVANDO TELEMETRIA"

    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null

    Set-ItemProperty `
        -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
        -Name "AllowTelemetry" `
        -Value 0 `
        -Type DWord

    $services = @(
        "DiagTrack"
        "dmwappushservice"
    )

    foreach ($s in $services) {

        Stop-Service $s -Force
        Set-Service $s -StartupType Disabled

        Write-Success "$s desativado"
    }

    # Tasks

    $tasks = @(

        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"

    )

    foreach ($task in $tasks) {

        Disable-ScheduledTask -TaskPath $task
    }

    Write-Success "Telemetria reduzida."
}

# --- PERFORMANCE ---
function Optimize-Performance {

    Write-Header "OTIMIZANDO DESEMPENHO"

    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

    Set-ItemProperty $path "SystemPaneSuggestionsEnabled" 0
    Set-ItemProperty $path "SubscribedContent-338388Enabled" 0
    Set-ItemProperty $path "SubscribedContent-338389Enabled" 0

    # Apps em segundo plano

    Set-ItemProperty `
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
        "GlobalUserDisabled" `
        1

    Write-Success "Sugestões e apps em background desativados."
}

# --- EXTRAS ---
function Apply-Extras {

    Write-Header "EXTRAS"

    # Widgets

    New-Item `
        "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
        -Force | Out-Null

    Set-ItemProperty `
        "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
        "AllowNewsAndInterests" `
        0

    Write-Success "Widgets desativados."

    # Copilot

    New-Item `
        "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" `
        -Force | Out-Null

    Set-ItemProperty `
        "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" `
        "TurnOffWindowsCopilot" `
        1

    Write-Success "Copilot desativado."

    # limpeza

    Write-Host "Limpando temporários..."

    Remove-Item "$env:TEMP\*" -Recurse -Force
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force

    Write-Success "Arquivos temporários removidos."
}

# --- EXECUÇÃO ---
function Run-Debloat {

    Create-RestorePoint
    Remove-Bloatware
    Disable-Telemetry
    Optimize-Performance
    Apply-Extras

    Write-Header "PROCESSO FINALIZADO"
    Write-Host "Reinicie o sistema."
}

Run-Debloat
