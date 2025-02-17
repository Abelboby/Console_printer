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

