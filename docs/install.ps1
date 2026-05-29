# Elitzur Games — Voice Chat + Fullbright auto-installer (Windows)
# Installs Fabric + Fabric API + Simple Voice Chat + Fullbright UB resource pack for MC 26.1.2
# Run from PowerShell:
#   Set-ExecutionPolicy -Scope Process Bypass -Force; irm https://elitzurms-art.github.io/elitzur-mods-install/install.ps1 | iex

$ErrorActionPreference = 'Stop'
$MC_VERSION   = '26.1.2'
$FABRIC_INST  = 'https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.1.1/fabric-installer-1.1.1.jar'
$FABRIC_API   = 'https://cdn.modrinth.com/data/P7dR8mSH/versions/E1mjhYMF/fabric-api-0.150.0%2B26.1.2.jar'
$VOICECHAT    = 'https://cdn.modrinth.com/data/9eGKb6K1/versions/DpT86E4Q/voicechat-fabric-2.6.18%2B26.1.2.jar'
$FULLBRIGHT   = 'https://cdn.modrinth.com/data/ItHr72Fy/versions/bjc4gBmv/Fullbright-UB-1.21%20fub-6.0.zip'
$FB_FILE      = 'Fullbright-UB-1.21 fub-6.0.zip'
$MC_DIR       = "$env:APPDATA\.minecraft"
$MODS_DIR     = "$MC_DIR\mods"
$RP_DIR       = "$MC_DIR\resourcepacks"

function Step($n,$t) { Write-Host "`n[$n] $t" -ForegroundColor Cyan }
function Ok($t)      { Write-Host "  ✓ $t" -ForegroundColor Green }
function Fail($t)    { Write-Host "  ✗ $t" -ForegroundColor Red; exit 1 }

Write-Host "==========================================" -ForegroundColor Yellow
Write-Host " Elitzur Games — Voice Chat + Fullbright Installer" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

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
$args = @('-jar', $installerJar, 'client', '-mcversion', $MC_VERSION, '-dir', $MC_DIR, '-noprofile')
$p = Start-Process -FilePath $java -ArgumentList $args -PassThru -Wait -WindowStyle Hidden
if ($p.ExitCode -ne 0) { Fail "Fabric installer נכשל (exit $($p.ExitCode))" }
Ok "Fabric Loader הותקן"

# 4b. Create launcher profile
Step '4b' 'יוצר פרופיל ב-launcher...'
$profilesPath = "$MC_DIR\launcher_profiles.json"
if (Test-Path $profilesPath) {
    try {
        $profiles = Get-Content $profilesPath -Raw | ConvertFrom-Json
        if (-not $profiles.profiles) { $profiles | Add-Member -NotePropertyName 'profiles' -NotePropertyValue (New-Object PSObject) -Force }
        $fabricVer = Get-ChildItem "$MC_DIR\versions" -Directory | Where-Object { $_.Name -like "fabric-loader-*-$MC_VERSION" } | Select-Object -Last 1
        if ($fabricVer) {
            $newProfile = [PSCustomObject]@{
                name = "Elitzur Games (Fabric $MC_VERSION)"
                type = 'custom'
                created = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                lastUsed = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                icon = 'Furnace'
                lastVersionId = $fabricVer.Name
            }
            $profiles.profiles | Add-Member -NotePropertyName 'elitzur-fabric' -NotePropertyValue $newProfile -Force
            $profiles | ConvertTo-Json -Depth 10 | Set-Content -Path $profilesPath -Encoding UTF8
            Ok "פרופיל נוצר: 'Elitzur Games (Fabric $MC_VERSION)'"
        }
    } catch { Write-Host "  ⚠ פרופיל לא נוצר אוטומטית — בחר fabric-loader ב-launcher ידנית" -ForegroundColor Yellow }
}

# 5. Download mods
Step 5 'מוריד את Fabric API + Simple Voice Chat...'
$apiPath = "$MODS_DIR\fabric-api-0.150.0+26.1.2.jar"
$vcPath  = "$MODS_DIR\voicechat-fabric-2.6.18+26.1.2.jar"
Get-ChildItem "$MODS_DIR\fabric-api-*.jar","$MODS_DIR\voicechat-fabric-*.jar" -ErrorAction SilentlyContinue | Remove-Item -Force
Invoke-WebRequest -Uri $FABRIC_API -OutFile $apiPath -UseBasicParsing
Ok "Fabric API → $apiPath"
Invoke-WebRequest -Uri $VOICECHAT  -OutFile $vcPath  -UseBasicParsing
Ok "Voice Chat → $vcPath"

# 6. Download resource pack
Step 6 'מוריד את Fullbright UB resource pack...'
$rpPath = "$RP_DIR\$FB_FILE"
Get-ChildItem "$RP_DIR\Fullbright-UB-*.zip" -ErrorAction SilentlyContinue | Remove-Item -Force
Invoke-WebRequest -Uri $FULLBRIGHT -OutFile $rpPath -UseBasicParsing
Ok "Fullbright UB → $rpPath"

# 6b. Enable in options.txt
Step '6b' 'מפעיל את ה-resource pack ב-options.txt...'
$optionsPath = "$MC_DIR\options.txt"
$fbEntry = "file/$FB_FILE"
if (Test-Path $optionsPath) {
    try {
        $lines = Get-Content $optionsPath
        $found = $false
        $newLines = foreach ($line in $lines) {
            if ($line -match '^resourcePacks:') {
                $found = $true
                $jsonPart = $line.Substring('resourcePacks:'.Length)
                try { $arr = [System.Collections.ArrayList]@($jsonPart | ConvertFrom-Json) } catch { $arr = [System.Collections.ArrayList]@() }
                if ($arr -notcontains $fbEntry) { $arr.Insert(0, $fbEntry) }
                "resourcePacks:" + ($arr | ConvertTo-Json -Compress)
            } else { $line }
        }
        if (-not $found) { $newLines += 'resourcePacks:["vanilla","' + $fbEntry + '"]' }
        $newLines | Set-Content -Path $optionsPath -Encoding UTF8
        Ok "Fullbright פעיל בהגדרות"
    } catch { Write-Host "  ⚠ לא הצלחתי לעדכן את options.txt — הפעל ידנית ב-Options → Resource Packs" -ForegroundColor Yellow }
} else {
    Write-Host "  ⚠ options.txt לא נמצא — הפעלת Minecraft פעם אחת תיצור אותו, אז הפעל את ה-pack ידנית" -ForegroundColor Yellow
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
