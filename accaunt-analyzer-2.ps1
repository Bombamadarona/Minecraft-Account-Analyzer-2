$minecraftPath = "$env:APPDATA\.minecraft"
$usernameCachePath = Join-Path -Path $minecraftPath -ChildPath "usernamecache.json"
$userCachePath = Join-Path -Path $minecraftPath -ChildPath "usercache.json"
$premiumCachePath = Join-Path -Path $env:TEMP -ChildPath "premiumCache.json"

Write-Host "@@@@@@    @@@@@@      @@@       @@@@@@@@   @@@@@@   @@@@@@@   @@@  @@@     @@@  @@@@@@@  "        -ForegroundColor Red
Write-Host "@@@@@@@   @@@@@@@      @@@       @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@ @@@     @@@  @@@@@@@  "       -ForegroundColor Red
Write-Host "!@@       !@@          @@!       @@!       @@!  @@@  @@!  @@@  @@!@!@@@     @@!    @@!    "       -ForegroundColor Red
Write-Host "!@!       !@!          !@!       !@!       !@!  @!@  !@!  @!@  !@!!@!@!     !@!    !@!    "       -ForegroundColor Red
Write-Host "!!@@!!    !!@@!!       @!!       @!!!:!    @!@!@!@!  @!@!!@!   @!@ !!@!     !!@    @!!    "       -ForegroundColor Red
Write-Host " !!@!!!    !!@!!!      !!!       !!!!!:    !!!@!!!!  !!@!@!    !@!  !!!     !!!    !!!    "       -ForegroundColor Red
Write-Host "     !:!       !:!     !!:       !!:       !!:  !!!  !!: :!!   !!:  !!!     !!:    !!:    "       -ForegroundColor Red
Write-Host "    !:!       !:!       :!:      :!:       :!:  !:!  :!:  !:!  :!:  !:!     :!:    :!:    "       -ForegroundColor Red
Write-Host ":::: ::   :::: ::       :: ::::   :: ::::  ::   :::  ::   :::   ::   ::      ::     ::  "         -ForegroundColor Red
Write-Host ":: : :    :: : :       : :: : :  : :: ::    :   : :   :   : :  ::    :      :       :"            -ForegroundColor Red
Write-Host ""
Write-Host "Discord: https://discord.gg/UET6TdxFUk"
Write-Host ""

Write-Host ""
Write-Host ("-" + ("=" * 58) + "-") -ForegroundColor Cyan
Write-Host ("|" + (" " * 15) + "MINECRAFT ACCOUNT ANALYZER 2" + (" " * 15) + "|") -ForegroundColor Cyan
Write-Host ("-" + ("=" * 58) + "-") -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $minecraftPath)) {
    Write-Host "La cartella .minecraft non esiste nel percorso: $minecraftPath" -ForegroundColor Red
    exit
}

if (-not (Test-Path $usernameCachePath)) {
    Write-Host "Il file usernamecache.json non esiste nella cartella .minecraft" -ForegroundColor Red
}

if (-not (Test-Path $userCachePath)) {
    Write-Host "Il file usercache.json non esiste nella cartella .minecraft" -ForegroundColor Red
}

$premiumCache = @{}
if (Test-Path $premiumCachePath) {
    $json = Get-Content -Raw -Path $premiumCachePath | ConvertFrom-Json
    if ($json -is [System.Management.Automation.PSCustomObject]) {
        $premiumCache = @{}
        $json.PSObject.Properties | ForEach-Object { $premiumCache[$_.Name] = $_.Value }
    } elseif ($json -is [hashtable]) {
        $premiumCache = $json
    }
}

function Test-NickPremium {
    param([string]$Nickname, [int]$RetryDelay = 2, [int]$MaxRetry = 3)

    $retry = 0
    do {
        try {
            Invoke-RestMethod -Uri "https://api.minecraftservices.com/minecraft/profile/lookup/name/$Nickname" -Method GET -ErrorAction Stop | Out-Null
            return $true
        } catch {
            if ($_.Exception.Response.StatusCode.value__ -eq 404) { return $false }
            elseif ($_.Exception.Response.StatusCode.value__ -eq 429) {
                Start-Sleep -Seconds $RetryDelay
                $RetryDelay *= 2
            } else {
                $retry++
                Start-Sleep -Seconds 2
            }
        }
        $retry++
    } while ($retry -lt $MaxRetry)
    return $null
}

function Check-Accounts {
    param([array]$Names, [int]$MaxConcurrentJobs = 3)

    if (-not $Names -or $Names.Count -eq 0) {
        Write-Host "Nessun nickname da controllare." -ForegroundColor Yellow
        return
    }

    $total = $Names.Count
    $counter = 0
    $jobs = [System.Collections.ArrayList]@()

    foreach ($name in $Names) {
        while ($jobs.Count -ge $MaxConcurrentJobs) {
            $finished = $jobs | Where-Object { $_.State -eq 'Completed' -or $_.State -eq 'Failed' }
            foreach ($f in $finished) {
                $output = Receive-Job $f
                foreach ($line in $output) {
                    if ($line -match "\[Premium\]") { Write-Host $line -ForegroundColor Yellow }
                    elseif ($line -match "\[SP\]") { Write-Host $line -ForegroundColor Gray }
                    elseif ($line -match "\[Errore\]") { Write-Host $line -ForegroundColor Red }
                    else { Write-Host $line }
                }
                Remove-Job $f
                $jobs.Remove($f) | Out-Null
                $counter++
                $percent = [math]::Round(($counter / $total) * 100)
                Write-Progress -Activity "Controllo account" -Status "$counter di $total" -PercentComplete $percent
            }
            Start-Sleep -Milliseconds 200
        }

        $job = Start-Job -ScriptBlock {
            param($n, $cachePath)
            $localCache = @{}
            if (Test-Path $cachePath) {
                $json = Get-Content -Raw -Path $cachePath | ConvertFrom-Json
                if ($json -is [System.Management.Automation.PSCustomObject]) {
                    $localCache = @{}
                    $json.PSObject.Properties | ForEach-Object { $localCache[$_.Name] = $_.Value }
                } elseif ($json -is [hashtable]) { $localCache = $json }
            }

            if ($localCache.ContainsKey($n)) {
                $isPremium = $localCache[$n]
            } else {
                $isPremium = Test-NickPremium -Nickname $n
                $localCache[$n] = $isPremium
                $localCache | ConvertTo-Json | Set-Content -Path $cachePath
            }

            if ($isPremium -eq $true) { Write-Output "- $n [Premium]" }
            elseif ($isPremium -eq $false) { Write-Output "- $n [SP]" }
            else { Write-Output "- $n [Errore]" }

        } -ArgumentList $name, $premiumCachePath

        $jobs.Add($job) | Out-Null
    }

    while ($jobs.Count -gt 0) {
        $finished = $jobs | Where-Object { $_.State -eq 'Completed' -or $_.State -eq 'Failed' }
        foreach ($f in $finished) {
            $output = Receive-Job $f
            foreach ($line in $output) {
                if ($line -match "\[Premium\]") { Write-Host $line -ForegroundColor Yellow }
                elseif ($line -match "\[SP\]") { Write-Host $line -ForegroundColor Gray }
                elseif ($line -match "\[Errore\]") { Write-Host $line -ForegroundColor Red }
                else { Write-Host $line }
            }
            Remove-Job $f
            $jobs.Remove($f) | Out-Null
            $counter++
            $percent = [math]::Round(($counter / $total) * 100)
            Write-Progress -Activity "Controllo account" -Status "$counter di $total" -PercentComplete $percent
        }
        Start-Sleep -Milliseconds 200
    }
    Write-Progress -Activity "Controllo account" -Completed
}

$allNames = @()
if (Test-Path $usernameCachePath) {
    $usernameData = Get-Content -Raw -Path $usernameCachePath | ConvertFrom-Json
    $allNames += $usernameData | ForEach-Object { $_.PSObject.Properties.Value } | Where-Object { $_ }
}
if (Test-Path $userCachePath) {
    $userData = Get-Content -Raw -Path $userCachePath | ConvertFrom-Json
    $allNames += $userData | Select-Object -ExpandProperty name | Where-Object { $_ }
}

if ($allNames.Count -gt 0) {
    Check-Accounts -Names $allNames -MaxConcurrentJobs 3
} else {
    Write-Host "Nessun account trovato da controllare." -ForegroundColor Yellow
}

Write-Host ""
Write-Host ("-" + ("=" * 58) + "-") -ForegroundColor Cyan
Write-Host ("|" + (" " * 19) + "CONTROLLO COMPLETATO" + (" " * 19) + "|") -ForegroundColor Cyan
Write-Host ("-" + ("=" * 58) + "-") -ForegroundColor Cyan
Write-Host ""

