$lyrics = @"
Your morning eyes, I could stare like watching stars
I could walk you by, and I'll tell without a thought
You'd be mine, would you mind if I took your hand tonight?
Know you're all that I want this life

I'll imagine we fell in love
I'll nap under moonlight skies with you
I think I'll picture us, you with the waves
The ocean's colors on your face
I'll leave my heart with your air
So let me fly with you
Will you be forever with me?

My love will always stay by you
I'll keep it safe, so don't you worry a thing
I'll tell you I love you more
It's stuck with you forever, so promise you won't let it go
I'll trust the universe will always bring me to you

I'll imagine we fell in love
I'll nap under moonlight skies with you
I think I'll picture us, you with the waves
The ocean's colors on your face
I'll leave my heart with your air
So let me fly with you
Will you be forever with me?
"@

$originalBg = $Host.UI.RawUI.BackgroundColor
$originalFg = $Host.UI.RawUI.ForegroundColor

try {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host
    
    $lyrics -split "`n" | ForEach-Object {
        $line = $_
        $chars = $line.ToCharArray()
        for($i=0; $i -lt $chars.Length; $i++) {
            Write-Host $chars[$i] -ForegroundColor Green -NoNewline
            Start-Sleep -Milliseconds 100
        }
        Write-Host ""
        Start-Sleep -Seconds 2
    }

    Start-Sleep -Seconds 5  # Final delay after all lyrics
}
finally {
    $Host.UI.RawUI.BackgroundColor = $originalBg
    $Host.UI.RawUI.ForegroundColor = $originalFg
    Clear-Host
} 