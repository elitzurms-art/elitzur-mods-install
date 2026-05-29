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
XAEROMAP="https://cdn.modrinth.com/data/1bokaNcj/versions/65OfA4xM/xaerominimap-fabric-26.1.2-25.3.14.jar"
SODIUM="https://cdn.modrinth.com/data/AANobbMI/versions/eRJU33Hp/sodium-fabric-0.8.12%2Bmc26.1.2.jar"
EMOTECRAFT="https://cdn.modrinth.com/data/pZ2wrerK/versions/ZkP5YEad/emotecraft-for-MC26.1.2-3.3.0-a.build.150.jar"
ZOOMIFY="https://cdn.modrinth.com/data/w7ThoJFB/versions/3zi0VJPK/zoomify-2.16.0%2B26.1.jar"
SODIUMEXTRA="https://cdn.modrinth.com/data/PtjYWJkn/versions/1bz3AMCV/sodium-extra-fabric-0.8.7%2Bmc26.1.1.jar"
LAMBDYN="https://cdn.modrinth.com/data/yBW8D80W/versions/UnhzVQJV/lambdynamiclights-4.10.2%2B26.1.2.jar"
# Dependencies for Emotecraft + Zoomify
PAL="https://cdn.modrinth.com/data/ha1mEyJS/versions/Cqy4sfYU/PlayerAnimationLibMerged-1.2.3%2Bmc.26.1.jar"
FABKOTLIN="https://cdn.modrinth.com/data/Ha28R6CL/versions/2i87JpYj/fabric-language-kotlin-1.13.11%2Bkotlin.2.3.21.jar"
YACL="https://cdn.modrinth.com/data/1eAoo2KR/versions/hzww5Tor/yet_another_config_lib_v3-3.9.3%2B26.1-fabric.jar"
FULLBRIGHT="https://cdn.modrinth.com/data/ItHr72Fy/versions/bjc4gBmv/Fullbright-UB-1.21%20fub-6.0.zip"
FB_FILE="Fullbright-UB-1.21 fub-6.0.zip"
GOLDCARROT="https://elitzurms-art.github.io/elitzur-mods-install/packs/Golden-Carrot%20Hunger%20Bar.zip"
GC_FILE="Golden-Carrot Hunger Bar.zip"
FANCYHEART="https://elitzurms-art.github.io/elitzur-mods-install/packs/fancy-heart-bar-1-21.zip"
FH_FILE="fancy-heart-bar-1-21.zip"

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
step 5 "מוריד את Fabric API + Voice Chat + Xaero's Minimap + Sodium..."
rm -f "$MODS_DIR"/fabric-api-*.jar "$MODS_DIR"/voicechat-fabric-*.jar "$MODS_DIR"/xaerominimap-*.jar "$MODS_DIR"/sodium-fabric-*.jar 2>/dev/null
curl -fsSL "$FABRIC_API" -o "$MODS_DIR/fabric-api-0.150.0+26.1.2.jar"
ok "Fabric API → fabric-api-0.150.0+26.1.2.jar"
curl -fsSL "$VOICECHAT" -o "$MODS_DIR/voicechat-fabric-2.6.18+26.1.2.jar"
ok "Voice Chat → voicechat-fabric-2.6.18+26.1.2.jar"
curl -fsSL "$XAEROMAP" -o "$MODS_DIR/xaerominimap-fabric-26.1.2-25.3.14.jar"
ok "Xaero's Minimap → xaerominimap-fabric-26.1.2-25.3.14.jar"
curl -fsSL "$SODIUM" -o "$MODS_DIR/sodium-fabric-0.8.12+mc26.1.2.jar"
ok "Sodium → sodium-fabric-0.8.12+mc26.1.2.jar"
rm -f "$MODS_DIR"/emotecraft-*.jar "$MODS_DIR"/zoomify-*.jar "$MODS_DIR"/sodium-extra-*.jar "$MODS_DIR"/lambdynamiclights-*.jar 2>/dev/null
curl -fsSL "$EMOTECRAFT" -o "$MODS_DIR/emotecraft-for-MC26.1.2-3.3.0-a.build.150.jar"
ok "Emotecraft → emotecraft-for-MC26.1.2-3.3.0-a.build.150.jar"
curl -fsSL "$ZOOMIFY" -o "$MODS_DIR/zoomify-2.16.0+26.1.jar"
ok "Zoomify → zoomify-2.16.0+26.1.jar"
curl -fsSL "$SODIUMEXTRA" -o "$MODS_DIR/sodium-extra-fabric-0.8.7+mc26.1.1.jar"
ok "Sodium Extra → sodium-extra-fabric-0.8.7+mc26.1.1.jar"
curl -fsSL "$LAMBDYN" -o "$MODS_DIR/lambdynamiclights-4.10.2+26.1.2.jar"
ok "LambDynamicLights → lambdynamiclights-4.10.2+26.1.2.jar"
# Dependencies
rm -f "$MODS_DIR"/PlayerAnimationLib*.jar "$MODS_DIR"/fabric-language-kotlin-*.jar "$MODS_DIR"/yet_another_config_lib_v3-*.jar 2>/dev/null
curl -fsSL "$PAL" -o "$MODS_DIR/PlayerAnimationLibMerged-1.2.3+mc.26.1.jar"
ok "Player Animation Library → PlayerAnimationLibMerged-1.2.3+mc.26.1.jar"
curl -fsSL "$FABKOTLIN" -o "$MODS_DIR/fabric-language-kotlin-1.13.11+kotlin.2.3.21.jar"
ok "Fabric Language Kotlin → fabric-language-kotlin-1.13.11+kotlin.2.3.21.jar"
curl -fsSL "$YACL" -o "$MODS_DIR/yet_another_config_lib_v3-3.9.3+26.1-fabric.jar"
ok "YACL → yet_another_config_lib_v3-3.9.3+26.1-fabric.jar"

# 6. Download resource packs and enable
step 6 "מוריד resource packs (Fullbright + Golden-Carrot + Fancy-Heart)..."
rm -f "$RP_DIR/$FB_FILE" "$RP_DIR/$GC_FILE" "$RP_DIR/$FH_FILE" 2>/dev/null
curl -fsSL "$FULLBRIGHT" -o "$RP_DIR/$FB_FILE"
ok "Fullbright UB"
curl -fsSL "$GOLDCARROT" -o "$RP_DIR/$GC_FILE"
ok "Golden-Carrot Hunger Bar"
curl -fsSL "$FANCYHEART" -o "$RP_DIR/$FH_FILE"
ok "Fancy Heart Bar"

step 6b "מפעיל את ה-resource packs ב-options.txt..."
OPTIONS="$MC_DIR/options.txt"
if [ -f "$OPTIONS" ]; then
  FB="$FB_FILE" GC="$GC_FILE" FH="$FH_FILE" python3 - <<'PYEOF' && ok "כל ה-packs פעילים בהגדרות" || echo "  ⚠ לא הצלחתי להפעיל אוטומטית — תפעיל ידנית ב-Options → Resource Packs"
import json, os
p = os.environ.get("OPTIONS", "options.txt")
import sys
PYEOF
  # actual logic
  FB="$FB_FILE" GC="$GC_FILE" FH="$FH_FILE" OPT="$OPTIONS" python3 - <<'PYEOF' && ok "כל ה-packs פעילים בהגדרות" || echo "  ⚠ לא הצלחתי להפעיל אוטומטית"
import json, os
p = os.environ["OPT"]
# Order matters: in options.txt the END of the array = TOP of Selected GUI (highest priority).
# We want Fancy-Heart at very top, then Golden-Carrot, then Fullbright underneath.
ours = ["file/" + os.environ["FB"], "file/" + os.environ["GC"], "file/" + os.environ["FH"]]
lines = open(p).read().splitlines()
found = False
out = []
for line in lines:
    if line.startswith("resourcePacks:"):
        found = True
        try:
            arr = json.loads(line[len("resourcePacks:"):])
        except Exception:
            arr = []
        for o in ours:
            while o in arr:
                arr.remove(o)
        arr.extend(ours)  # append at end = top of Selected
        out.append("resourcePacks:" + json.dumps(arr, ensure_ascii=False))
    else:
        out.append(line)
if not found:
    out.append('resourcePacks:' + json.dumps(["vanilla"] + ours, ensure_ascii=False))
open(p, "w").write("\n".join(out) + "\n")
PYEOF
else
  echo "  ⚠ options.txt לא נמצא — הפעל ידנית ב-Options → Resource Packs"
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
