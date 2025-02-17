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

    # Initialize space saved counters
    $spaceSavedFiles = 0
    $spaceSavedDirs = 0

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
                        $sizeBefore = [math]::Round((Get-ChildItem $item.FullName -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
                        Remove-Item $item.FullName -Force -Recurse -ErrorAction SilentlyContinue
                        Write-Host "Removed directory: $($item.Name)" -ForegroundColor Green
                        $successfullyDeletedDirs++
                        $spaceSavedDirs += $sizeBefore
                    } else {
                        # For files
                        $sizeBefore = [math]::Round($item.Length / 1GB, 2)
                        # Try to force close any handles to the file
                        $handle = [System.IO.File]::Open($item.FullName, 'Open', 'Read', 'None')
                        $handle.Close()
                        $handle.Dispose()
                        
                        Remove-Item $item.FullName -Force -ErrorAction SilentlyContinue
                        Write-Host "Removed file: $($item.Name)" -ForegroundColor Green
                        $successfullyDeletedFiles++
                        $spaceSavedFiles += $sizeBefore
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

    # Calculate total space saved
    $totalSpaceSavedGB = [math]::Round(($spaceSavedFiles + $spaceSavedDirs), 2)
    Write-Host "`nTotal Space Saved: $totalSpaceSavedGB GB" -ForegroundColor Green
    Write-Host "==================================================`n" -ForegroundColor Cyan

    # Display closing watermark
    Write-Host "`n==================================================" -ForegroundColor Magenta
    Write-Host "  Created by: Abel Boby" -ForegroundColor Magenta
    Write-Host "  GitHub: github.com/abelboby" -ForegroundColor Magenta
    Write-Host "==================================================`n" -ForegroundColor Magenta
}
catch {
    Write-Host "An error occurred during cleanup: $($_.Exception.Message)" -ForegroundColor Red
}

