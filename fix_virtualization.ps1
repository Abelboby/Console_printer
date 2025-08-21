# ==========================================================
# Fix Android Emulator Acceleration on Windows Home
# ==========================================================

$ErrorActionPreference = "Stop"

Write-Host "🔍 Checking if virtualization is enabled in BIOS..."

# Check virtualization support
$cpu = Get-CimInstance Win32_Processor
if ($cpu.VirtualizationFirmwareEnabled -ne $true) {
    Write-Host "❌ Virtualization is not enabled in BIOS. Please enable Intel VT-x / AMD SVM in BIOS first."
    exit 1
} else {
    Write-Host "✅ Virtualization is enabled in BIOS."
}

# Enable Windows features (WHPX + VirtualMachinePlatform)
Write-Host "⚙️ Enabling Windows Hypervisor Platform (WHPX) and Virtual Machine Platform..."
dism.exe /Online /Enable-Feature /FeatureName:HypervisorPlatform /All /NoRestart
dism.exe /Online /Enable-Feature /FeatureName:VirtualMachinePlatform /All /NoRestart

Write-Host "✅ WHPX + Virtual Machine Platform enabled (restart may be required)."

# Install Android Emulator Hypervisor Driver
$androidRoot = "C:\Android"
$hypervisorDriverPath = "$androidRoot\extras\google\Android_Emulator_Hypervisor_Driver\silent_install.bat"

Write-Host "📦 Installing Android Emulator Hypervisor Driver..."
& sdkmanager --install "extras;google;Android_Emulator_Hypervisor_Driver"

if (Test-Path $hypervisorDriverPath) {
    Write-Host "🚀 Running Hypervisor Driver silent install..."
    Start-Process -FilePath $hypervisorDriverPath -Wait -Verb RunAs
    Write-Host "✅ Hypervisor Driver installed."
} else {
    Write-Host "⚠️ Hypervisor driver installer not found. Make sure ANDROID_SDK_ROOT is set correctly."
}

# Verify acceleration
Write-Host "🔍 Verifying emulator acceleration..."
Start-Process "emulator" -ArgumentList "
