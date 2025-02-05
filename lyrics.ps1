$musicUrl = "https://raw.githubusercontent.com/Abelboby/Console_printer/main/blue.mp3"
$tempFile = "$env:TEMP\blue.mp3"
irm $musicUrl -OutFile $tempFile

# Media Player initialization
Add-Type -AssemblyName PresentationCore
$mediaPlayer = New-Object System.Windows.Media.MediaPlayer
$mediaPlayer.Open($tempFile)
$mediaPlayer.Volume = 1.0
$mediaPlayer.Play()
Start-Sleep -Milliseconds 500  # Audio buffer

$originalBg = $Host.UI.RawUI.BackgroundColor
$originalFg = $Host.UI.RawUI.ForegroundColor

try {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host

    # Timestamp to seconds mapping
    $lyricData = @(
        (19, "Your morning eyes, I could stare like watching stars"),
        (26, "I could walk you by and I'll tell without a thought"),
        (33, "You'd be mine, would you mind if I took your hand tonight"),
        (40, "Know you're all that I want, this life`n"),
        (48, "I'll imagine we fell in love"),
        (50, "I'll nap under moonlight skies with you"),
        (55, "I think I'll picture us, you with the waves"),
        (58, "The ocean's colors on your face"),
        (62, "I'll leave my heart with your air"),  # 1:02
        (66, "So let me fly with you"),             # 1:06
        (69, "Will you be forever with me`n"),        # 1:09
        (107, "My love will always stay by you"),   # 1:47
        (113, "I'll keep it safe"),                 # 1:53
        (115, "So don't you worry a thing"),        # 1:55
        (118, "I'll tell you I love you more"),     # 1:58
        (121, "It's stuck with you forever"),       # 2:01
        (125, "So promise you won't let it go"),    # 2:05
        (128, "I'll trust the universe will always bring me to you`n"), # 2:08
        (137, "I'll imagine we fell in love"),      # 2:17
        (139, "I'll nap under moonlight skies with you"), # 2:19
        (143, "I think I'll picture us, you with the waves"), # 2:23
        (146, "The ocean's colors on your face"),   # 2:26
        (151, "I'll leave my heart with your air"), # 2:31
        (154, "So let me fly with you"),            # 2:34
        (158, "Will you be forever with me")        # 2:38
    )

    $songStart = Get-Date
    foreach ($item in $lyricData) {
        $targetTime = $item[0]
        $line = $item[1]
        
        # Calculate elapsed time since song start
        $elapsed = [math]::Round(((Get-Date) - $songStart).TotalSeconds, 2)
        $requiredWait = $targetTime - $elapsed

        # Wait until target time if needed
        if($requiredWait -gt 0) {
            Start-Sleep -Milliseconds ($requiredWait * 1000)
        }

        # Calculate available time until next line
        $nextLineTime = ($lyricData[[array]::IndexOf($lyricData, $item)+1].Item1 - $targetTime)
        $maxTypingTime = if($nextLineTime) { $nextLineTime } else { 0 }

        # Dynamic character delay calculation
        $baseDelay = 100  # Base 100ms per char
        $lineLength = $line.Length
        $requiredTypingTime = $lineLength * ($baseDelay/1000)
        
        # Adjust delay if needed to fit within timeframe
        if($maxTypingTime -gt 0 -and $requiredTypingTime -gt $maxTypingTime) {
            $adjustedDelay = [math]::Floor(($maxTypingTime * 1000) / $lineLength)
            $actualDelay = [math]::Min($adjustedDelay, 200)  # Max 200ms/char
        } else {
            $actualDelay = $baseDelay
        }

        # Render line with calculated speed
        $line.ToCharArray() | ForEach-Object {
            Write-Host $_ -NoNewline -ForegroundColor Green
            Start-Sleep -Milliseconds $actualDelay
        }
        Write-Host ""
    }

    # Final instrumental (2:44 to 3:41 = 57 seconds)
    $remainingTime = 221 - $targetTime  # 3:41 = 221 seconds
    if ($remainingTime -gt 0) {
        Start-Sleep -Seconds $remainingTime
    }

} finally {
    $mediaPlayer.Stop()
    $mediaPlayer.Close()
    Remove-Item $tempFile -ErrorAction SilentlyContinue
    $Host.UI.RawUI.BackgroundColor = $originalBg
    $Host.UI.RawUI.ForegroundColor = $originalFg
    Clear-Host
} 