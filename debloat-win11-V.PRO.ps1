<#
.SYNOPSIS
    Windows 11 Pro Advanced Debloat Script
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

# --- CONFIGURAÇÕES DE INTERFACE ---
$ErrorActionPreference = "SilentlyContinue"

function Write-Header {
    param([string]$Text)
    Write-Host "`n====================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan -Bold
    Write-Host "====================================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "[OK] " -NoNewline -ForegroundColor Green
    Write-Host $Text
}

function Write-WarningMsg {
    param([string]$Text)
    Write-Host "[!] " -NoNewline -ForegroundColor Yellow
    Write-Host $Text
}

function Write-ErrorMsg {
    param([string]$Text)
    Write-Host "[ERRO] " -NoNewline -ForegroundColor Red
    Write-Host $Text
}

# --- VERIFICAÇÃO DE ADMINISTRADOR ---
function Test-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-ErrorMsg "Este script DEVE ser executado como Administrador."
        Write-Host "Por favor, clique com o botão direito no PowerShell e selecione 'Executar como administrador'." -ForegroundColor Yellow
        exit
    }
}

# --- PONTO DE RESTAURAÇÃO ---
function Create-RestorePoint {
    Write-Header "SEGURANÇA: CRIANDO PONTO DE RESTAURAÇÃO"
    Write-Host "Isso garante que você possa reverter as alterações se algo der errado." -ForegroundColor Gray
    
    try {
        Checkpoint-Computer -Description "ManusDebloat_BeforeOptimization" -RestorePointType "MODIFY_SETTINGS"
        Write-Success "Ponto de restauração criado com sucesso."
    } catch {
        Write-ErrorMsg "Falha ao criar ponto de restauração. Verifique se a Proteção do Sistema está ativada."
    }
}

# --- REMOÇÃO DE BLOATWARE (UWP) ---
function Remove-Bloatware {
    Write-Header "REMOÇÃO DE BLOATWARE (APLICATIVOS UWP)"
    
    $AppsToRemove = @(
        "*Xbox*",
        "*Cortana*",
        "*Clipchamp*",
        "*BingNews*",
        "*Weather*",
        "*People*",
        "*3DViewer*",
        "*MixedReality*",
        "*ZuneVideo*",
        "*ZuneMusic*",
        "*Office.OneNote*",
        "*SkypeApp*",
        "*MicrosoftSolitaireCollection*",
        "*PowerAutomateDesktop*",
        "*Todos*",
        "*GetHelp*",
        "*Getstarted*",
        "*WindowsFeedbackHub*",
        "*YourPhone*",
        "*BingWeather*",
        "*Microsoft3DViewer*",
        "*MixedReality.Portal*"
    )

    foreach ($AppName in $AppsToRemove) {
        Write-Host "Removendo: $AppName..." -NoNewline -ForegroundColor Gray
        Get-AppxPackage -Name $AppName -AllUsers | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $AppName } | Remove-AppxProvisionedPackage -Online
        Write-Host " Concluído." -ForegroundColor Green
    }
    Write-Success "Remoção de aplicativos concluída."
}

# --- DESATIVAR TELEMETRIA E COLETA DE DADOS ---
function Disable-Telemetry {
    Write-Header "PRIVACIDADE: DESATIVANDO TELEMETRIA E COLETA DE DADOS"
    
    # Nível de Telemetria (0 = Segurança, apenas Enterprise/Pro)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    
    # Serviços de Telemetria
    $Services = @("DiagTrack", "dmwappushservice", "WerSvc")
    foreach ($Svc in $Services) {
        Stop-Service -Name $Svc -Confirm:$false
        Set-Service -Name $Svc -StartupType Disabled
        Write-Success "Serviço desativado: $Svc"
    }

    # Tarefas Agendadas de Telemetria
    $Tasks = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    )
    foreach ($Task in $Tasks) {
        Disable-ScheduledTask -TaskName $Task
        Write-Success "Tarefa desativada: $Task"
    }
    
    # Desativar ID de Anúncios
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    Write-Success "ID de anúncios desativado."
}

# --- OTIMIZAÇÕES DE DESEMPENHO ---
function Optimize-Performance {
    Write-Header "DESEMPENHO: OTIMIZAÇÕES DE SISTEMA"
    
    # Desativar Anúncios e Sugestões no Menu Iniciar/Configurações
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
    
    # Desativar Apps em Segundo Plano (Global)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1
    
    # Desativar Transparência (Opcional para desempenho)
    # Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0
    
    Write-Success "Sugestões e atividades em segundo plano otimizadas."
}

# --- EXTRAS ÚTEIS ---
function Apply-Extras {
    Write-Header "EXTRAS: AJUSTES ADICIONAIS"
    
    # Desativar Widgets
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0
    Write-Success "Widgets desativados."

    # Desativar Copilot
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1
    Write-Success "Copilot desativado."

    # Limpeza de Arquivos Temporários
    Write-Host "Limpando arquivos temporários..." -ForegroundColor Gray
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force
    Write-Success "Arquivos temporários limpos."
}

# --- MENU PRINCIPAL ---
function Show-Menu {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "   WINDOWS 11 PRO ADVANCED DEBLOAT TOOL" -ForegroundColor Cyan -Bold
    Write-Host "====================================================`n" -ForegroundColor Cyan
    
    Write-Host "1. Executar Debloat Completo (Recomendado)" -ForegroundColor White
    Write-Host "2. Apenas Remover Bloatware (Apps UWP)"
    Write-Host "3. Apenas Desativar Telemetria e Privacidade"
    Write-Host "4. Apenas Otimizações de Desempenho"
    Write-Host "5. Apenas Extras (Widgets, Copilot, Limpeza)"
    Write-Host "6. Sair"
    Write-Host "`nEscolha uma opção: " -NoNewline
}

# --- EXECUÇÃO ---

$choice = ""
while ($choice -ne "6") {
    Show-Menu
    $choice = Read-Host
    
    switch ($choice) {
        "1" {
            $confirm = Read-Host "`nTem certeza que deseja executar o debloat completo? (S/N)"
            if ($confirm -eq "S" -or $confirm -eq "s") {
                Create-RestorePoint
                Remove-Bloatware
                Disable-Telemetry
                Optimize-Performance
                Apply-Extras
                Write-Header "PROCESSO CONCLUÍDO COM SUCESSO!"
                Write-Host "Recomenda-se reiniciar o computador para aplicar todas as alterações." -ForegroundColor Yellow
                Pause
            }
        }
        "2" { Remove-Bloatware; Pause }
        "3" { Disable-Telemetry; Pause }
        "4" { Optimize-Performance; Pause }
        "5" { Apply-Extras; Pause }
        "6" { Write-Host "`nSaindo... Tenha um ótimo dia!" -ForegroundColor Cyan }
        default { Write-ErrorMsg "Opção inválida." ; Start-Sleep -Seconds 2 }
    }
}
Read-Host "Pressione ENTER para sair"   
