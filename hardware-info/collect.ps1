# Zbiera podstawowe dane sprzetowe z komputera z Windows i zapisuje je
# do pliku hardware-info/<nazwa-komputera>.md.
#
# Jak uruchomic:
#   1. Otworz PowerShell (Start -> wpisz "PowerShell" -> Enter)
#   2. Wejdz do folderu z repo, np:  cd C:\sciezka\do\szkwiat
#   3. Uruchom:  .\hardware-info\collect.ps1
#
# Jesli pojawi sie blad o "execution policy", uruchom najpierw:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$ErrorActionPreference = "SilentlyContinue"

$computerName = $env:COMPUTERNAME
$outFile = Join-Path $PSScriptRoot "$computerName.md"

$sb = New-Object System.Text.StringBuilder

function Add-Section($title, $content) {
    [void]$sb.AppendLine("## $title")
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine($content)
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine()
}

[void]$sb.AppendLine("# Dane sprzetowe: $computerName")
[void]$sb.AppendLine()
[void]$sb.AppendLine("Zebrano: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') (czas lokalny)")
[void]$sb.AppendLine()

$os = Get-CimInstance Win32_OperatingSystem
Add-Section "System" ("$($os.Caption) $($os.OSArchitecture), wersja: $($os.Version)")

$cpu = Get-CimInstance Win32_Processor
$cpuInfo = $cpu | ForEach-Object { "$($_.Name) - rdzenie: $($_.NumberOfCores), watki: $($_.NumberOfLogicalProcessors)" }
Add-Section "CPU" ($cpuInfo -join "`n")

$ramGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
Add-Section "Pamiec RAM" "Calkowita RAM: $ramGB GB"

$disks = Get-CimInstance Win32_DiskDrive | ForEach-Object {
    "$($_.Model) - rozmiar: $([math]::Round($_.Size/1GB,1)) GB"
}
Add-Section "Dyski (fizyczne)" ($disks -join "`n")

$volumes = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    "$($_.DeviceID) - rozmiar: $([math]::Round($_.Size/1GB,1)) GB, wolne: $([math]::Round($_.FreeSpace/1GB,1)) GB"
}
Add-Section "Partycje" ($volumes -join "`n")

$gpu = Get-CimInstance Win32_VideoController | ForEach-Object { $_.Name }
Add-Section "Karta graficzna" ($gpu -join "`n")

$net = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" | ForEach-Object {
    "$($_.Description): $($_.IPAddress -join ', ')"
}
Add-Section "Siec" ($net -join "`n")

$sb.ToString() | Out-File -FilePath $outFile -Encoding utf8

Write-Host "Zapisano dane do hardware-info\$computerName.md"
Write-Host "Teraz w PowerShell wpisz:"
Write-Host "  git add hardware-info/$computerName.md"
Write-Host "  git commit -m 'Add hardware info for $computerName'"
Write-Host "  git push"
