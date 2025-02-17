# Store original console colors
$originalBg = $Host.UI.RawUI.BackgroundColor
$originalFg = $Host.UI.RawUI.ForegroundColor

try {
    # Set console colors
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host

    # Display watermark
    Write-Host "`n==================================================" -ForegroundColor Magenta
    Write-Host "  Created by: Abel Boby" -ForegroundColor Magenta
    Write-Host "  GitHub: github.com/abelboby" -ForegroundColor Magenta
    Write-Host "==================================================`n" -ForegroundColor Magenta

    Write-Host "Windows Temporary Files Cleanup Utility" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "`nThis will clean temporary files from the following locations:"
    Write-Host "- User's Temp folder"
    Write-Host "- Local AppData Temp folder"
    Write-Host "- Windows Temp folder"
    
    $confirmation = Read-Host "`nDo you want to proceed? (Y/N)"
    
    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "`nCleanup cancelled by user." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return
    }

    # Initialize counters
    $totalFiles = 0
    $totalDirectories = 0
    $successfullyDeletedFiles = 0
    $successfullyDeletedDirs = 0
    $failedToDeleteFiles = 0
    $failedToDeleteDirs = 0

    # Define paths to clean
    $tempPaths = @(
        "$env:TEMP",
        "$env:USERPROFILE\AppData\Local\Temp",
        "$env:windir\Temp"
    )

    Write-Host "`nStarting system cleanup..." -ForegroundColor Green
    
    foreach ($path in $tempPaths) {
        Write-Host "`nCleaning $path..." -ForegroundColor Cyan
        
        try {
            # Get both files and folders
            $items = Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue

            # Count total items
            $totalFiles += ($items | Where-Object { -not $_.PSIsContainer }).Count
            $totalDirectories += ($items | Where-Object { $_.PSIsContainer }).Count
            
            foreach ($item in $items) {
                try {
                    if ($item.PSIsContainer) {
                        # For folders, try to remove entire directory and its contents
                        Remove-Item $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
                        Write-Host "Removed directory: $($item.Name)" -ForegroundColor Green
                        $successfullyDeletedDirs++
                    } else {
                        # For files
                        # Try to force close any handles to the file
                        $handle = [System.IO.File]::Open($item.FullName, 'Open', 'Read', 'None')
                        $handle.Close()
                        $handle.Dispose()
                        
                        Remove-Item $item.FullName -Force -ErrorAction SilentlyContinue
                        Write-Host "Removed file: $($item.Name)" -ForegroundColor Green
                        $successfullyDeletedFiles++
                    }
                }
                catch {
                    if ($item.PSIsContainer) {
                        Write-Host "Could not remove directory: $($item.Name) - Access Denied or In Use" -ForegroundColor Yellow
                        $failedToDeleteDirs++
                    } else {
                        Write-Host "Could not remove file: $($item.Name) - Access Denied or In Use" -ForegroundColor Yellow
                        $failedToDeleteFiles++
                    }
                }
            }
        }
        catch {
            Write-Host "Error accessing path: $path" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }

    # Display cleanup report
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "                 Cleanup Report                    " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Files:" -ForegroundColor White
    Write-Host "  Total found: $totalFiles" -ForegroundColor White
    Write-Host "  Successfully deleted: $successfullyDeletedFiles" -ForegroundColor Green
    Write-Host "  Failed to delete: $failedToDeleteFiles" -ForegroundColor Yellow
    Write-Host "`nDirectories:" -ForegroundColor White
    Write-Host "  Total found: $totalDirectories" -ForegroundColor White
    Write-Host "  Successfully deleted: $successfullyDeletedDirs" -ForegroundColor Green
    Write-Host "  Failed to delete: $failedToDeleteDirs" -ForegroundColor Yellow
    Write-Host "==================================================`n" -ForegroundColor Cyan

    # Display drive space information
    Write-Host "Drive Space Information" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    
    # Get Recycle Bin size
    $recycleBinSize = 0
    $shell = New-Object -ComObject Shell.Application
    $recycleBin = $shell.Namespace(0xA)
    
    try {
        $recycleBinItems = $recycleBin.Items()
        foreach ($item in $recycleBinItems) {
            $recycleBinSize += $item.Size
        }
        $recycleBinSizeGB = [math]::Round($recycleBinSize / 1GB, 2)
        
        # Determine Recycle Bin status
        $recycleBinStatus = if ($recycleBinSizeGB -le 1) {
            @{Status = "Healthy"; Color = "Green"}
        } elseif ($recycleBinSizeGB -le 5) {
            @{Status = "Consider Emptying"; Color = "Yellow"}
        } else {
            @{Status = "Should Empty Now"; Color = "Red"}
        }
        
        Write-Host "`nRecycle Bin Size: $recycleBinSizeGB GB - $($recycleBinStatus.Status)" -ForegroundColor $recycleBinStatus.Color
    }
    catch {
        Write-Host "`nCould not calculate Recycle Bin size" -ForegroundColor Red
    }
    
    # Get Windows Update Cache Size
    $windowsUpdatePath = "$env:SystemRoot\SoftwareDistribution\Download"
    try {
        $updateCacheSize = 0
        Get-ChildItem -Path $windowsUpdatePath -Recurse -ErrorAction SilentlyContinue | 
        ForEach-Object { $updateCacheSize += $_.Length }
        $updateCacheSizeGB = [math]::Round($updateCacheSize / 1GB, 2)
        
        # Determine Windows Update Cache status
        $updateCacheStatus = if ($updateCacheSizeGB -le 1) {
            @{Status = "Normal"; Color = "Green"}
        } elseif ($updateCacheSizeGB -le 5) {
            @{Status = "Consider Clearing"; Color = "Yellow"}
        } else {
            @{Status = "Should Clear Now"; Color = "Red"}
        }
        
        Write-Host "`nWindows Update Cache Size: $updateCacheSizeGB GB - $($updateCacheStatus.Status)" -ForegroundColor $updateCacheStatus.Color
        
        if ($updateCacheSizeGB -gt 1) {
            $showInstructions = Read-Host "`nWould you like to see how to clear the Windows Update Cache? (Y/N)"
            
            if ($showInstructions -eq 'Y' -or $showInstructions -eq 'y') {
                Write-Host "`n=================== IMPORTANT NOTICE ===================" -ForegroundColor Red
                Write-Host "Before clearing Windows Update Cache:" -ForegroundColor Yellow
                Write-Host "1. Make sure no Windows updates are currently installing"
                Write-Host "2. Save all your work and close running applications"
                Write-Host "3. Ensure your PC won't go to sleep during the process"
                Write-Host "4. Have a stable power connection for laptops"
                Write-Host "====================================================`n" -ForegroundColor Red

                Write-Host "Steps to safely clear Windows Update Cache:" -ForegroundColor Cyan
                Write-Host "=========================================" -ForegroundColor Cyan
                Write-Host "1. Open Command Prompt as Administrator:" -ForegroundColor White
                Write-Host "   - Right-click Start Menu"
                Write-Host "   - Select 'Windows Terminal (Admin)' or 'Command Prompt (Admin)'"
                
                Write-Host "`n2. Stop Windows Update related services:" -ForegroundColor White
                Write-Host "   net stop wuauserv" -ForegroundColor Yellow
                Write-Host "   net stop bits" -ForegroundColor Yellow
                Write-Host "   net stop cryptsvc" -ForegroundColor Yellow
                Write-Host "   net stop msiserver" -ForegroundColor Yellow
                
                Write-Host "`n3. Clear the Cache:" -ForegroundColor White
                Write-Host "   - Navigate to: $windowsUpdatePath"
                Write-Host "   - Delete all contents inside this folder"
                Write-Host "   - Do NOT delete the folder itself" -ForegroundColor Red
                
                Write-Host "`n4. Restart the services:" -ForegroundColor White
                Write-Host "   net start wuauserv" -ForegroundColor Yellow
                Write-Host "   net start bits" -ForegroundColor Yellow
                Write-Host "   net start cryptsvc" -ForegroundColor Yellow
                Write-Host "   net start msiserver" -ForegroundColor Yellow
                
                Write-Host "`n5. Recommended Additional Steps:" -ForegroundColor White
                Write-Host "   - Restart your computer"
                Write-Host "   - Run Windows Update to check for new updates"
                
                Write-Host "`nNotes:" -ForegroundColor Green
                Write-Host "- This process is safe when done correctly"
                Write-Host "- Windows will redownload any needed updates"
                Write-Host "- This might take 10-15 minutes to complete"
                Write-Host "- If you encounter issues, seek help at:"
                Write-Host "  support.microsoft.com/windows-update" -ForegroundColor Cyan
                Write-Host "====================================================`n" -ForegroundColor Cyan
            }
        }
    }
    catch {
        Write-Host "`nCould not calculate Windows Update Cache size" -ForegroundColor Red
    }
    
    $drives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    $systemDrive = $env:SystemDrive
    
    foreach ($drive in $drives) {
        $freeSpace = [math]::Round($drive.FreeSpace / 1GB, 2)
        $totalSpace = [math]::Round($drive.Size / 1GB, 2)
        $usedSpace = [math]::Round(($drive.Size - $drive.FreeSpace) / 1GB, 2)
        $freePercent = [math]::Round(($drive.FreeSpace / $drive.Size) * 100, 1)
        
        # Highlight system drive
        if ($drive.DeviceID -eq $systemDrive) {
            Write-Host "`nSystem Drive $($drive.DeviceID) (OS Installed)" -ForegroundColor Yellow
        } else {
            Write-Host "`nDrive $($drive.DeviceID)" -ForegroundColor White
        }
        
        Write-Host "  Total Space: $totalSpace GB"
        Write-Host "  Used Space: $usedSpace GB"
        
        # Color code the free space status
        $spaceStatus = if ($freePercent -ge 25) {
            "Healthy"
        } elseif ($freePercent -ge 15) {
            "Warning"
        } else {
            "Critical"
        }
        
        $statusColor = switch ($spaceStatus) {
            "Healthy"  { "Green" }
            "Warning"  { "Yellow" }
            "Critical" { "Red" }
        }
        
        Write-Host "  Free Space: $freeSpace GB ($freePercent% free) - $spaceStatus" -ForegroundColor $statusColor
    }
    Write-Host "==================================================`n" -ForegroundColor Cyan

    Write-Host "Cleanup completed!" -ForegroundColor Green
    
    # Display closing watermark
    Write-Host "`n==================================================" -ForegroundColor Magenta
    Write-Host "  Created by: Abel Boby" -ForegroundColor Magenta
    Write-Host "  GitHub: github.com/abelboby" -ForegroundColor Magenta
    Write-Host "==================================================`n" -ForegroundColor Magenta
}
catch {
    Write-Host "An error occurred during cleanup: $($_.Exception.Message)" -ForegroundColor Red
}

