# Elitzur Games — Voice Chat + Fullbright auto-installer (Windows)
# Installs Fabric + Fabric API + Simple Voice Chat + Fullbright UB resource pack for MC 26.1.2
# Run from PowerShell:
#   Set-ExecutionPolicy -Scope Process Bypass -Force; irm https://elitzurms-art.github.io/elitzur-mods-install/install.ps1 | iex

$ErrorActionPreference = 'Stop'
$MC_VERSION   = '26.1.2'
$FABRIC_INST  = 'https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.1.1/fabric-installer-1.1.1.jar'
$FABRIC_API   = 'https://cdn.modrinth.com/data/P7dR8mSH/versions/E1mjhYMF/fabric-api-0.150.0%2B26.1.2.jar'
$VOICECHAT    = 'https://cdn.modrinth.com/data/9eGKb6K1/versions/DpT86E4Q/voicechat-fabric-2.6.18%2B26.1.2.jar'
$XAEROMAP     = 'https://cdn.modrinth.com/data/1bokaNcj/versions/65OfA4xM/xaerominimap-fabric-26.1.2-25.3.14.jar'
$SODIUM       = 'https://cdn.modrinth.com/data/AANobbMI/versions/eRJU33Hp/sodium-fabric-0.8.12%2Bmc26.1.2.jar'
$EMOTECRAFT   = 'https://cdn.modrinth.com/data/pZ2wrerK/versions/ZkP5YEad/emotecraft-for-MC26.1.2-3.3.0-a.build.150.jar'
$ZOOMIFY      = 'https://cdn.modrinth.com/data/w7ThoJFB/versions/3zi0VJPK/zoomify-2.16.0%2B26.1.jar'
$SODIUMEXTRA  = 'https://cdn.modrinth.com/data/PtjYWJkn/versions/1bz3AMCV/sodium-extra-fabric-0.8.7%2Bmc26.1.1.jar'
$LAMBDYN      = 'https://cdn.modrinth.com/data/yBW8D80W/versions/UnhzVQJV/lambdynamiclights-4.10.2%2B26.1.2.jar'
# Dependencies for Emotecraft + Zoomify
$PAL          = 'https://cdn.modrinth.com/data/ha1mEyJS/versions/Cqy4sfYU/PlayerAnimationLibMerged-1.2.3%2Bmc.26.1.jar'
$FABKOTLIN    = 'https://cdn.modrinth.com/data/Ha28R6CL/versions/2i87JpYj/fabric-language-kotlin-1.13.11%2Bkotlin.2.3.21.jar'
$YACL         = 'https://cdn.modrinth.com/data/1eAoo2KR/versions/hzww5Tor/yet_another_config_lib_v3-3.9.3%2B26.1-fabric.jar'
$FULLBRIGHT   = 'https://cdn.modrinth.com/data/ItHr72Fy/versions/bjc4gBmv/Fullbright-UB-1.21%20fub-6.0.zip'
$FB_FILE      = 'Fullbright-UB-1.21 fub-6.0.zip'
$GOLDCARROT   = 'https://elitzurms-art.github.io/elitzur-mods-install/packs/Golden-Carrot%20Hunger%20Bar.zip'
$GC_FILE      = 'Golden-Carrot Hunger Bar.zip'
$FANCYHEART   = 'https://elitzurms-art.github.io/elitzur-mods-install/packs/fancy-heart-bar-1-21.zip'
$FH_FILE      = 'fancy-heart-bar-1-21.zip'
$AMONGUS      = 'https://elitzurms-art.github.io/elitzur-mods-install/packs/Among%20Us%20in%20Minecraft%20v3_RP.zip'
$AU_FILE      = 'Among Us in Minecraft v3_RP.zip'
$MC_DIR       = "$env:APPDATA\.minecraft"
$MODS_DIR     = "$MC_DIR\mods"
$RP_DIR       = "$MC_DIR\resourcepacks"

function Step($n,$t) { Write-Host "`n[$n] $t" -ForegroundColor Cyan }
function Ok($t)      { Write-Host "  ✓ $t" -ForegroundColor Green }
function Fail($t)    { Write-Host "  ✗ $t" -ForegroundColor Red; exit 1 }

Write-Host "==========================================" -ForegroundColor Yellow
Write-Host " Elitzur Games — Voice Chat + Fullbright Installer" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

# 0. Make sure Minecraft / launcher are closed (they lock files we need to replace)
Step 0 'בודק ש-Minecraft סגור...'
$lockingProcs = @()
foreach ($p in 'Minecraft*','javaw','MinecraftLauncher*') {
    Get-Process -Name $p -ErrorAction SilentlyContinue | ForEach-Object { $lockingProcs += $_ }
}
if ($lockingProcs.Count -gt 0) {
    Write-Host ""
    Write-Host "  ⚠ נמצאו תהליכים של Minecraft פתוחים:" -ForegroundColor Yellow
    $lockingProcs | ForEach-Object { Write-Host "    PID $($_.Id) — $($_.ProcessName)" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "  סגור את Minecraft Launcher והמשחק לפני שתמשיך." -ForegroundColor Yellow
    $ans = Read-Host "  כדי לסגור אוטומטית הקלד Y, אחרת Enter לעצירה"
    if ($ans -eq 'Y' -or $ans -eq 'y') {
        $lockingProcs | ForEach-Object { try { Stop-Process -Id $_.Id -Force -ErrorAction Stop; Write-Host "    ✓ נסגר $($_.ProcessName)" -ForegroundColor Green } catch { Write-Host "    ✗ לא הצלחתי לסגור $($_.ProcessName)" -ForegroundColor Red } }
        Start-Sleep -Seconds 2
    } else {
        Fail "בטל: סגור את Minecraft והרץ שוב."
    }
} else {
    Ok "Minecraft סגור"
}

# 1. Find Java
Step 1 'מאתר Java...'
$java = $null
try { $java = (Get-Command java -ErrorAction Stop).Source } catch {}
if (-not $java) {
    $launcherJre = Get-ChildItem "$env:APPDATA\.minecraft\runtime\*\windows-x64\*\bin\javaw.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $launcherJre) { $launcherJre = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.4297127D64EC6_8wekyb3d8bbwe\LocalCache\Local\runtime\*\windows-x64\*\bin\javaw.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 }
    if ($launcherJre) { $java = $launcherJre.FullName }
}
if (-not $java) { Fail "Java לא נמצא. הפעל את Minecraft פעם אחת קודם כדי שה-launcher יוריד Java." }
Ok "Java: $java"

# 2. Ensure folders
Step 2 'מאתר תיקיית Minecraft...'
if (-not (Test-Path $MC_DIR)) { Fail "תיקיית $MC_DIR לא קיימת. הפעל את Minecraft פעם אחת קודם." }
if (-not (Test-Path $MODS_DIR)) { New-Item -ItemType Directory -Path $MODS_DIR | Out-Null }
if (-not (Test-Path $RP_DIR))   { New-Item -ItemType Directory -Path $RP_DIR | Out-Null }
Ok "תיקיית Minecraft: $MC_DIR"

# 3. Download Fabric installer
Step 3 'מוריד את Fabric installer...'
$tmp = "$env:TEMP\elitzur-vc-install"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$installerJar = "$tmp\fabric-installer.jar"
Invoke-WebRequest -Uri $FABRIC_INST -OutFile $installerJar -UseBasicParsing
Ok "Fabric installer הורד"

# 4. Run Fabric installer
Step 4 "מתקין Fabric Loader עבור MC $MC_VERSION..."
$javaArgs = @('-jar', $installerJar, 'client', '-mcversion', $MC_VERSION, '-dir', $MC_DIR, '-noprofile')
$logOut = "$tmp\fabric-installer.out.log"
$logErr = "$tmp\fabric-installer.err.log"
$p = Start-Process -FilePath $java -ArgumentList $javaArgs -PassThru -Wait -NoNewWindow -RedirectStandardOutput $logOut -RedirectStandardError $logErr
if ($p.ExitCode -ne 0) {
    $errText = ''
    if (Test-Path $logErr) { $errText = Get-Content $logErr -Raw -ErrorAction SilentlyContinue }
    if ($errText -match 'being used by another process') {
        Write-Host ""
        Write-Host "  ⚠ קובץ נעול ע""י תהליך אחר. סגור את Minecraft Launcher והמשחק ונסה שוב." -ForegroundColor Yellow
        Fail "Minecraft פתוח — סגור אותו והרץ את ה-installer שוב."
    }
    Write-Host ""
    Write-Host "  Fabric installer output:" -ForegroundColor Yellow
    if (Test-Path $logOut) { Get-Content $logOut -ErrorAction SilentlyContinue | Select-Object -Last 12 | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray } }
    if (Test-Path $logErr) { Get-Content $logErr -ErrorAction SilentlyContinue | Select-Object -Last 12 | ForEach-Object { Write-Host "    $_" -ForegroundColor Red } }
    Fail "Fabric installer failed (exit $($p.ExitCode)). See output above. Java: $java"
}
Ok "Fabric Loader installed"

# 4b. Create launcher profile (official Mojang launcher + TLauncher if present)
Step '4b' 'יוצר פרופיל ב-launchers...'
$fabricVer = Get-ChildItem "$MC_DIR\versions" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "fabric-loader-*-$MC_VERSION" } | Select-Object -Last 1
if (-not $fabricVer) { Write-Host "  ⚠ לא נמצאה גרסת Fabric — בחר ידנית ב-launcher" -ForegroundColor Yellow }
else {
    $profileName = "Elitzur Games (Fabric $MC_VERSION)"
    $profileKey  = 'elitzur-fabric'
    $created = $true

    # ---- 1) Official Mojang launcher ----
    $mojangPath = "$MC_DIR\launcher_profiles.json"
    if (Test-Path $mojangPath) {
        try {
            $mojang = Get-Content $mojangPath -Raw | ConvertFrom-Json
            if (-not $mojang.profiles) { $mojang | Add-Member -NotePropertyName 'profiles' -NotePropertyValue (New-Object PSObject) -Force }
            $newProf = [PSCustomObject]@{
                name = $profileName; type = 'custom'
                created = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                lastUsed = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                icon = 'Furnace'; lastVersionId = $fabricVer.Name
            }
            $mojang.profiles | Add-Member -NotePropertyName $profileKey -NotePropertyValue $newProf -Force
            $mojang | ConvertTo-Json -Depth 10 | Set-Content -Path $mojangPath -Encoding UTF8
            Ok "Mojang Launcher: '$profileName'"
        } catch { Write-Host "  ⚠ פרופיל ב-Mojang Launcher לא נוצר אוטומטית" -ForegroundColor Yellow }
    }

    # ---- 2) TLauncher ----
    $tlPaths = @("$MC_DIR\TlauncherProfiles.json", "$env:APPDATA\.tlauncher\TlauncherProfiles.json", "$env:APPDATA\.tlauncher\profiles.json")
    foreach ($tlPath in $tlPaths) {
        if (Test-Path $tlPath) {
            try {
                $tlRaw = Get-Content $tlPath -Raw
                $tl = if ([string]::IsNullOrWhiteSpace($tlRaw)) { [PSCustomObject]@{ profiles = (New-Object PSObject) } } else { $tlRaw | ConvertFrom-Json }
                if (-not $tl.profiles) { $tl | Add-Member -NotePropertyName 'profiles' -NotePropertyValue (New-Object PSObject) -Force }
                $tlProf = [PSCustomObject]@{
                    name = $profileName; type = 'custom'
                    created = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                    lastUsed = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                    icon = 'Furnace'; lastVersionId = $fabricVer.Name
                }
                $tl.profiles | Add-Member -NotePropertyName $profileKey -NotePropertyValue $tlProf -Force
                # set as selected so user sees it immediately
                $tl | Add-Member -NotePropertyName 'selectedProfile' -NotePropertyValue $profileKey -Force
                $tl | ConvertTo-Json -Depth 10 | Set-Content -Path $tlPath -Encoding UTF8
                Ok "TLauncher: '$profileName' (ב-$tlPath)"
            } catch { Write-Host "  ⚠ TLauncher profile (ב-$tlPath) לא נוצר אוטומטית" -ForegroundColor Yellow }
        }
    }
}

# 5. Download mods
Step 5 'מוריד את Fabric API + Voice Chat + Xaero''s Minimap + Sodium...'
$apiPath = "$MODS_DIR\fabric-api-0.150.0+26.1.2.jar"
$vcPath  = "$MODS_DIR\voicechat-fabric-2.6.18+26.1.2.jar"
$xmPath  = "$MODS_DIR\xaerominimap-fabric-26.1.2-25.3.14.jar"
$soPath  = "$MODS_DIR\sodium-fabric-0.8.12+mc26.1.2.jar"
Get-ChildItem "$MODS_DIR\fabric-api-*.jar","$MODS_DIR\voicechat-fabric-*.jar","$MODS_DIR\xaerominimap-*.jar","$MODS_DIR\sodium-fabric-*.jar" -ErrorAction SilentlyContinue | Remove-Item -Force
Invoke-WebRequest -Uri $FABRIC_API -OutFile $apiPath -UseBasicParsing
Ok "Fabric API → $apiPath"
Invoke-WebRequest -Uri $VOICECHAT  -OutFile $vcPath  -UseBasicParsing
Ok "Voice Chat → $vcPath"
Invoke-WebRequest -Uri $XAEROMAP   -OutFile $xmPath  -UseBasicParsing
Ok "Xaero's Minimap → $xmPath"
Invoke-WebRequest -Uri $SODIUM     -OutFile $soPath  -UseBasicParsing
Ok "Sodium → $soPath"
$emPath = "$MODS_DIR\emotecraft-for-MC26.1.2-3.3.0-a.build.150.jar"
$zmPath = "$MODS_DIR\zoomify-2.16.0+26.1.jar"
$sxPath = "$MODS_DIR\sodium-extra-fabric-0.8.7+mc26.1.1.jar"
$ldPath = "$MODS_DIR\lambdynamiclights-4.10.2+26.1.2.jar"
Get-ChildItem "$MODS_DIR\emotecraft-*.jar","$MODS_DIR\zoomify-*.jar","$MODS_DIR\sodium-extra-*.jar","$MODS_DIR\lambdynamiclights-*.jar" -ErrorAction SilentlyContinue | Remove-Item -Force
Invoke-WebRequest -Uri $EMOTECRAFT  -OutFile $emPath -UseBasicParsing
Ok "Emotecraft → $emPath"
Invoke-WebRequest -Uri $ZOOMIFY     -OutFile $zmPath -UseBasicParsing
Ok "Zoomify → $zmPath"
Invoke-WebRequest -Uri $SODIUMEXTRA -OutFile $sxPath -UseBasicParsing
Ok "Sodium Extra → $sxPath"
Invoke-WebRequest -Uri $LAMBDYN     -OutFile $ldPath -UseBasicParsing
Ok "LambDynamicLights → $ldPath"
$palPath = "$MODS_DIR\PlayerAnimationLibMerged-1.2.3+mc.26.1.jar"
$fkPath  = "$MODS_DIR\fabric-language-kotlin-1.13.11+kotlin.2.3.21.jar"
$yclPath = "$MODS_DIR\yet_another_config_lib_v3-3.9.3+26.1-fabric.jar"
Get-ChildItem "$MODS_DIR\PlayerAnimationLib*.jar","$MODS_DIR\fabric-language-kotlin-*.jar","$MODS_DIR\yet_another_config_lib_v3-*.jar" -ErrorAction SilentlyContinue | Remove-Item -Force
Invoke-WebRequest -Uri $PAL       -OutFile $palPath -UseBasicParsing
Ok "Player Animation Library → $palPath"
Invoke-WebRequest -Uri $FABKOTLIN -OutFile $fkPath  -UseBasicParsing
Ok "Fabric Language Kotlin → $fkPath"
Invoke-WebRequest -Uri $YACL      -OutFile $yclPath -UseBasicParsing
Ok "YACL → $yclPath"

# 6. Download resource packs
Step 6 'מוריד resource packs (Fullbright + Golden-Carrot + Fancy-Heart)...'
Get-ChildItem "$RP_DIR\$FB_FILE","$RP_DIR\$GC_FILE","$RP_DIR\$FH_FILE" -ErrorAction SilentlyContinue | Remove-Item -Force
Invoke-WebRequest -Uri $FULLBRIGHT -OutFile "$RP_DIR\$FB_FILE" -UseBasicParsing
Ok "Fullbright UB"
Invoke-WebRequest -Uri $GOLDCARROT -OutFile "$RP_DIR\$GC_FILE" -UseBasicParsing
Ok "Golden-Carrot Hunger Bar"
Invoke-WebRequest -Uri $FANCYHEART -OutFile "$RP_DIR\$FH_FILE" -UseBasicParsing
Ok "Fancy Heart Bar"
Invoke-WebRequest -Uri $AMONGUS -OutFile "$RP_DIR\$AU_FILE" -UseBasicParsing
Ok "Among Us in Minecraft v3 (לשרת imposter)"

# 6b. Enable in options.txt
Step '6b' 'מפעיל את ה-resource packs ב-options.txt...'
$optionsPath = "$MC_DIR\options.txt"
# In options.txt resourcePacks array, the END = TOP of Selected GUI (highest priority).
# Order: Fullbright first, Golden-Carrot, Fancy-Heart last (= top of Selected).
$entries = @("file/$FB_FILE", "file/$GC_FILE", "file/$FH_FILE")
if (Test-Path $optionsPath) {
    try {
        $lines = Get-Content $optionsPath
        $found = $false
        $newLines = foreach ($line in $lines) {
            if ($line -match '^resourcePacks:') {
                $found = $true
                $jsonPart = $line.Substring('resourcePacks:'.Length)
                try { $arr = [System.Collections.ArrayList]@($jsonPart | ConvertFrom-Json) } catch { $arr = [System.Collections.ArrayList]@() }
                # remove existing instances then append at end (= top of Selected)
                foreach ($e in $entries) { while ($arr.Contains($e)) { $arr.Remove($e) } }
                foreach ($e in $entries) { [void]$arr.Add($e) }
                "resourcePacks:" + ($arr | ConvertTo-Json -Compress)
            } else { $line }
        }
        if (-not $found) {
            $allEntries = @("vanilla") + $entries
            $newLines += 'resourcePacks:' + ($allEntries | ConvertTo-Json -Compress)
        }
        $newLines | Set-Content -Path $optionsPath -Encoding UTF8
        Ok "כל ה-packs פעילים בהגדרות"
    } catch { Write-Host "  ⚠ לא הצלחתי לעדכן את options.txt — הפעל ידנית ב-Options → Resource Packs" -ForegroundColor Yellow }
} else {
    Write-Host "  ⚠ options.txt לא נמצא — הפעל ידנית ב-Options → Resource Packs" -ForegroundColor Yellow
}

# Done
Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "  ✓ ההתקנה הסתיימה!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "`nעכשיו:"
Write-Host "1. פתח את Minecraft Launcher"
Write-Host "2. בחר את הפרופיל 'Elitzur Games (Fabric $MC_VERSION)'"
Write-Host "3. לחץ Play"
Write-Host "4. התחבר לשרת — אייקון מיקרופון בפינה, ובמערות תמיד יהיה אור (Fullbright)"
Write-Host "`nהחלון יישאר פתוח. סגור ידנית כשתסיים." -ForegroundColor Cyan
pause
