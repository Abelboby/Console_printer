$lyrics = @"
[Insert your lyrics here]
Line 2
Line 3...
"@

$originalBg = $Host.UI.RawUI.BackgroundColor
$originalFg = $Host.UI.RawUI.ForegroundColor

try {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "White"
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
}
finally {
    $Host.UI.RawUI.BackgroundColor = $originalBg
    $Host.UI.RawUI.ForegroundColor = $originalFg
    Clear-Host
} 