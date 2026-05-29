#!/bin/bash
# Elitzur Games — Voice Chat + Fullbright auto-installer (macOS / Linux)
# Installs Fabric + Fabric API + Simple Voice Chat + Fullbright UB resource pack for MC 26.1.2
# Run:
#   curl -fsSL https://elitzurms-art.github.io/elitzur-mods-install/install.sh | bash

set -e

MC_VERSION="26.1.2"
FABRIC_INST="https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.1.1/fabric-installer-1.1.1.jar"
FABRIC_API="https://cdn.modrinth.com/data/P7dR8mSH/versions/E1mjhYMF/fabric-api-0.150.0%2B26.1.2.jar"
VOICECHAT="https://cdn.modrinth.com/data/9eGKb6K1/versions/DpT86E4Q/voicechat-fabric-2.6.18%2B26.1.2.jar"
FULLBRIGHT="https://cdn.modrinth.com/data/ItHr72Fy/versions/bjc4gBmv/Fullbright-UB-1.21%20fub-6.0.zip"
FB_FILE="Fullbright-UB-1.21 fub-6.0.zip"

if [[ "$OSTYPE" == "darwin"* ]]; then
  MC_DIR="$HOME/Library/Application Support/minecraft"
else
  MC_DIR="$HOME/.minecraft"
fi
MODS_DIR="$MC_DIR/mods"
RP_DIR="$MC_DIR/resourcepacks"

step() { echo -e "\n\033[36m[$1] $2\033[0m"; }
ok()   { echo -e "  \033[32m✓ $1\033[0m"; }
fail() { echo -e "  \033[31m✗ $1\033[0m"; exit 1; }

echo -e "\033[33m==========================================\033[0m"
echo -e "\033[33m Elitzur Games — Voice Chat + Fullbright Installer\033[0m"
echo -e "\033[33m==========================================\033[0m"

# 1. Find Java
step 1 "מאתר Java..."
JAVA=""
if command -v java >/dev/null 2>&1; then JAVA=$(command -v java); fi
if [ -z "$JAVA" ]; then
  for cand in "$MC_DIR/runtime"/*/mac-os*/*/bin/java "$MC_DIR/runtime"/*/linux/*/bin/java "$MC_DIR/runtime"/*/*/jre.bundle/Contents/Home/bin/java; do
    [ -x "$cand" ] && JAVA="$cand" && break
  done
fi
[ -z "$JAVA" ] && fail "Java לא נמצא. הפעל את Minecraft פעם אחת קודם."
ok "Java: $JAVA"

# 2. Verify .minecraft folder
step 2 "מאתר תיקיית Minecraft..."
[ ! -d "$MC_DIR" ] && fail "תיקיית $MC_DIR לא קיימת. הפעל את Minecraft פעם אחת קודם."
mkdir -p "$MODS_DIR" "$RP_DIR"
ok "תיקיית Minecraft: $MC_DIR"

# 3. Download Fabric installer
step 3 "מוריד את Fabric installer..."
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT
INSTALLER="$TMP/fabric-installer.jar"
curl -fsSL "$FABRIC_INST" -o "$INSTALLER"
ok "Fabric installer הורד"

# 4. Run Fabric installer
step 4 "מתקין Fabric Loader עבור MC $MC_VERSION..."
"$JAVA" -jar "$INSTALLER" client -mcversion "$MC_VERSION" -dir "$MC_DIR" -noprofile >/dev/null 2>&1 || fail "Fabric installer נכשל"
ok "Fabric Loader הותקן"

# 4b. Create launcher profile
step 4b "יוצר פרופיל ב-launcher..."
FABRIC_VER=$(ls "$MC_DIR/versions" 2>/dev/null | grep "fabric-loader-.*$MC_VERSION$" | tail -1)
if [ -n "$FABRIC_VER" ] && [ -f "$MC_DIR/launcher_profiles.json" ]; then
  python3 -c "
import json, datetime
p = '$MC_DIR/launcher_profiles.json'
data = json.load(open(p))
data.setdefault('profiles', {})
now = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z')
data['profiles']['elitzur-fabric'] = {
    'name': 'Elitzur Games (Fabric $MC_VERSION)',
    'type': 'custom',
    'created': now, 'lastUsed': now,
    'icon': 'Furnace',
    'lastVersionId': '$FABRIC_VER'
}
json.dump(data, open(p, 'w'), indent=2)
" && ok "פרופיל נוצר: 'Elitzur Games (Fabric $MC_VERSION)'"
else
  echo "  ⚠ פרופיל לא נוצר אוטומטית — בחר fabric-loader ב-launcher ידנית"
fi

# 5. Download mods
step 5 "מוריד את Fabric API + Simple Voice Chat..."
rm -f "$MODS_DIR"/fabric-api-*.jar "$MODS_DIR"/voicechat-fabric-*.jar 2>/dev/null
curl -fsSL "$FABRIC_API" -o "$MODS_DIR/fabric-api-0.150.0+26.1.2.jar"
ok "Fabric API → fabric-api-0.150.0+26.1.2.jar"
curl -fsSL "$VOICECHAT" -o "$MODS_DIR/voicechat-fabric-2.6.18+26.1.2.jar"
ok "Voice Chat → voicechat-fabric-2.6.18+26.1.2.jar"

# 6. Download resource pack and enable
step 6 "מוריד את Fullbright UB resource pack..."
rm -f "$RP_DIR"/Fullbright-UB-*.zip 2>/dev/null
curl -fsSL "$FULLBRIGHT" -o "$RP_DIR/$FB_FILE"
ok "Fullbright UB → $FB_FILE"

step 6b "מפעיל את ה-resource pack ב-options.txt..."
OPTIONS="$MC_DIR/options.txt"
if [ -f "$OPTIONS" ]; then
  python3 - <<PYEOF && ok "Fullbright פעיל בהגדרות" || echo "  ⚠ לא הצלחתי להפעיל אוטומטית — תפעיל ידנית ב-Options → Resource Packs"
import json, re
p = "$OPTIONS"
fb = "file/$FB_FILE"
lines = open(p).read().splitlines()
found_rp = False
out = []
for line in lines:
    if line.startswith("resourcePacks:"):
        found_rp = True
        try:
            arr = json.loads(line[len("resourcePacks:"):])
        except Exception:
            arr = []
        if fb not in arr:
            arr.insert(0, fb)
        out.append("resourcePacks:" + json.dumps(arr, ensure_ascii=False))
    else:
        out.append(line)
if not found_rp:
    out.append('resourcePacks:["vanilla","'+fb+'"]')
open(p, "w").write("\n".join(out) + "\n")
PYEOF
else
  echo "  ⚠ options.txt לא נמצא — הפעלת Minecraft פעם אחת תיצור אותו, אז הפעל את ה-pack ידנית ב-Options"
fi

# Done
echo -e "\n\033[32m==========================================\033[0m"
echo -e "\033[32m  ✓ ההתקנה הסתיימה!\033[0m"
echo -e "\033[32m==========================================\033[0m"
echo
echo "עכשיו:"
echo "1. פתח את Minecraft Launcher"
echo "2. בחר את הפרופיל 'Elitzur Games (Fabric $MC_VERSION)'"
echo "3. לחץ Play"
echo "4. התחבר לשרת — תראה אייקון מיקרופון בפינת המסך,"
echo "   ובמערות תמיד יהיה אור (Fullbright)"
