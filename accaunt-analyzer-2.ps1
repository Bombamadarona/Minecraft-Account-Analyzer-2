$minecraftPath = "$env:APPDATA\.minecraft"
$usernameCachePath = Join-Path -Path $minecraftPath -ChildPath "usernamecache.json"
$userCachePath = Join-Path -Path $minecraftPath -ChildPath "usercache.json"              

function Test-NickPremium {
    param([string]$Nickname)

    $url = "https://api.minecraftservices.com/minecraft/profile/lookup/name/$Nickname"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -ErrorAction Stop
        return $true
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 404) {
            return $false
        } elseif ($_.Exception.Response.StatusCode.value__ -eq 429) {
            Write-Host "⏳ Rate limit raggiunto. Attendo 5 secondi..." -ForegroundColor DarkGray
            Start-Sleep -Seconds 5
            return Test-NickPremium -Nickname $Nickname
        } else {
            return $null
        }
    }
}

                                                                                          
Write-Output "@@@@@@    @@@@@@      @@@       @@@@@@@@   @@@@@@   @@@@@@@   @@@  @@@     @@@  @@@@@@@  "
Write-Output "@@@@@@@   @@@@@@@      @@@       @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@ @@@     @@@  @@@@@@@  "
Write-Output "!@@       !@@          @@!       @@!       @@!  @@@  @@!  @@@  @@!@!@@@     @@!    @@!    "
Write-Output "!@!       !@!          !@!       !@!       !@!  @!@  !@!  @!@  !@!!@!@!     !@!    !@!    "
Write-Output "!!@@!!    !!@@!!       @!!       @!!!:!    @!@!@!@!  @!@!!@!   @!@ !!@!     !!@    @!!    "
Write-Output " !!@!!!    !!@!!!      !!!       !!!!!:    !!!@!!!!  !!@!@!    !@!  !!!     !!!    !!!    "
Write-Output "     !:!       !:!     !!:       !!:       !!:  !!!  !!: :!!   !!:  !!!     !!:    !!:    "
Write-Output "    !:!       !:!       :!:      :!:       :!:  !:!  :!:  !:!  :!:  !:!     :!:    :!:    "
Write-Output ":::: ::   :::: ::       :: ::::   :: ::::  ::   :::  ::   :::   ::   ::      ::     ::  "  
Write-Output ":: : :    :: : :       : :: : :  : :: ::    :   : :   :   : :  ::    :      :       :"    
Write-Output ""
Write-Output "https://discord.gg/UET6TdxFUk"
Write-Output ""

Write-Host "`n------------------------------------------" -ForegroundColor DarkGray
Write-Host "         MINECRAFT ACCOUNT ANALYZER 2"
Write-Host "------------------------------------------`n" -ForegroundColor DarkGray


if (Test-Path $usernameCachePath) {
    Write-Host "`n📁 usernamecache.json:" -ForegroundColor Cyan
    $usernameData = Get-Content -Raw -Path $usernameCachePath | ConvertFrom-Json
    $names = $usernameData | ForEach-Object { $_.PSObject.Properties.Value } | Where-Object { $_ }

    foreach ($name in $names) {
        $isPremium = Test-NickPremium -Nickname $name
        if ($isPremium -eq $true) {
            Write-Host "- $name [Premium]" -ForegroundColor Green
        } elseif ($isPremium -eq $false) {
            Write-Host "- $name [SP]" -ForegroundColor Yellow
        } else {
            Write-Host "- $name [Errore durante la verifica]" -ForegroundColor Red
        }
        Start-Sleep -Seconds 2
    }
} else {
    Write-Host "Il file usernamecache.json non esiste nella cartella .minecraft." -ForegroundColor Red
}

if (Test-Path $userCachePath) {
    Write-Host "`n📁 usercache.json:" -ForegroundColor Cyan
    $userData = Get-Content -Raw -Path $userCachePath | ConvertFrom-Json
    $names = $userData | Select-Object -ExpandProperty name | Where-Object { $_ }

    foreach ($name in $names) {
        $isPremium = Test-NickPremium -Nickname $name
        if ($isPremium -eq $true) {
            Write-Host "- $name [Premium]" -ForegroundColor Green
        } elseif ($isPremium -eq $false) {
            Write-Host "- $name [SP]" -ForegroundColor Yellow
        } else {
            Write-Host "- $name [Errore durante la verifica]" -ForegroundColor Red
        }
        Start-Sleep -Seconds 2
    }
} else {
    Write-Host "Il file usercache.json non esiste nella cartella .minecraft." -ForegroundColor Red
}

