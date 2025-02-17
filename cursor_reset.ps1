# cursor_id_manager.ps1

function Get-StoragePath {
    # Get the path to the storage file based on the operating system.
    $system = $env:OS
    Write-Host "Operating System: $system"
    Write-Host "Searching for storage file ......"

    try {
        if ($system -like "*Windows*") {
            $basePath = [System.Environment]::GetFolderPath('ApplicationData')
        } elseif ($system -like "*Darwin*") {  # MacOS
            $basePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('UserProfile'), "Library/Application Support")
        } else {  # Linux and others
            $basePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('UserProfile'), ".config")
        }

        $storagePath = Join-Path -Path $basePath -ChildPath "Cursor/User/globalStorage/storage.json"
        Write-Host "Storage file location: $storagePath"
        return $storagePath
    } catch {
        throw "Failed to determine storage path: $_"
    }
}

function Create-TimestampBackup {
    param (
        [string]$storagePath
    )
    # Create a timestamped backup of the storage file.
    try {
        $backupTimestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
        $backupPath = Join-Path -Path (Split-Path $storagePath -Parent) -ChildPath "storage.json.backup_$backupTimestamp"
        Write-Host "Creating backup ......"
        Copy-Item -Path $storagePath -Destination $backupPath -Force
        Write-Host "Backup file location: $backupPath"
    } catch {
        throw "Failed to create backup: $_"
    }
}

function Generate-NewIds {
    # Generate new unique identifiers for Cursor.
    $newIds = @{
        "telemetry.machineId" = [BitConverter]::ToString((New-Guid).ToByteArray()).Replace("-", "").ToLower()
        "telemetry.macMachineId" = [BitConverter]::ToString((New-Guid).ToByteArray()).Replace("-", "").ToLower()
        "telemetry.devDeviceId" = [Guid]::NewGuid().ToString()
        "telemetry.sqmId" = "{0}" -f [Guid]::NewGuid()
    }
    return $newIds
}

function Print-Ids {
    param (
        [string]$prefix,
        [hashtable]$ids
    )
    # Print the IDs in a formatted way.
    Write-Host "`n$prefix IDs:"
    Write-Host "-" * 50
    foreach ($key in $ids.Keys) {
        $idName = $key.Split(".")[-1].Replace("Id", " ID").ToUpper()
        Write-Host "{0,-15} : {1}" -f $idName, $ids[$key]
    }
    Write-Host "-" * 50
}

function Reset-CursorIds {
    param (
        [string]$storagePath
    )
    # Reset Cursor telemetry IDs with new random values.
    try {
        # Read current data
        $data = Get-Content -Path $storagePath | ConvertFrom-Json

        # Get current IDs
        $currentIds = @{
            "telemetry.machineId" = $data."telemetry.machineId"
            "telemetry.macMachineId" = $data."telemetry.macMachineId"
            "telemetry.devDeviceId" = $data."telemetry.devDeviceId"
            "telemetry.sqmId" = $data."telemetry.sqmId"
        }

        Write-Host "`nFetching cursor IDs......"
        Print-Ids -prefix "Current" -ids $currentIds

        # Generate and set new IDs
        Write-Host "`nResetting cursor IDs......"
        $newIds = Generate-NewIds
        $data.PSObject.Properties.Remove("telemetry.machineId")
        $data.PSObject.Properties.Remove("telemetry.macMachineId")
        $data.PSObject.Properties.Remove("telemetry.devDeviceId")
        $data.PSObject.Properties.Remove("telemetry.sqmId")
        $data.PSObject.Properties.Add("telemetry.machineId", $newIds["telemetry.machineId"])
        $data.PSObject.Properties.Add("telemetry.macMachineId", $newIds["telemetry.macMachineId"])
        $data.PSObject.Properties.Add("telemetry.devDeviceId", $newIds["telemetry.devDeviceId"])
        $data.PSObject.Properties.Add("telemetry.sqmId", $newIds["telemetry.sqmId"])

        # Write updated data
        $data | ConvertTo-Json -Depth 10 | Set-Content -Path $storagePath

        Print-Ids -prefix "New" -ids $newIds
        Write-Host "`nCursor IDs have been reset successfully."
    } catch {
        throw "Error processing storage file: $_"
    }
}

function Main {
    try {
        $storagePath = Get-StoragePath
        Create-TimestampBackup -storagePath $storagePath
        Reset-CursorIds -storagePath $storagePath
    } catch {
        Write-Host "Error: $_"
    } finally {
        exit  # Close the PowerShell session
    }
}

# Execute the main function
Main
