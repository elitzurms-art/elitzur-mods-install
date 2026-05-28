# Elitzur Games — Mods Installer

Auto-installs Fabric + Fabric API + Simple Voice Chat for players joining the Elitzur Games Minecraft network (MC 26.1.2).

## Hosting on GitHub Pages

1. Create a GitHub repo named `elitzur-mods-install` (or any name) under your user.
2. Push this entire directory to the repo.
3. In repo Settings → Pages, set source to **branch: main, folder: /docs**.
4. After ~1 min, the site will be live at `https://<USERNAME>.github.io/elitzur-mods-install/`.
5. **Edit two URLs** to match your GitHub username:
   - `docs/index.html` — replace `REPLACE_USER` with your GitHub username (2 places)
   - In-game Skript message — same replacement
6. The installer scripts at `scripts/install.ps1` and `scripts/install.sh` must be served from the GitHub raw URLs (referenced from `docs/index.html`).
   - **Actually**, GitHub Pages serves only files under `/docs`. Move the scripts into `/docs` too so they're hosted at the same URL. The directory structure should be:
     ```
     docs/
       index.html
       install.ps1
       install.sh
     ```

## Updating mod versions

Edit constants at the top of `install.ps1` and `install.sh`:
- `MC_VERSION` — Minecraft version
- `FABRIC_INST` — Fabric installer .jar URL (from https://fabricmc.net/use/installer/)
- `FABRIC_API` — Fabric API .jar URL (from Modrinth)
- `VOICECHAT` — Simple Voice Chat fabric .jar URL (from Modrinth)

Also update the manual download links in `docs/index.html`.
