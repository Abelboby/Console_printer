$lyrics = @"
[Insert your lyrics here]
Line 2
Line 3...
"@

Clear-Host
$lyrics -split "`n" | ForEach-Object {
    $line = $_
    $chars = $line.ToCharArray()
    for($i=0; $i -lt $chars.Length; $i++) {
        Write-Host $chars[$i] -NoNewline
        Start-Sleep -Milliseconds 100
    }
    Write-Host ""
    Start-Sleep -Seconds 2
} 