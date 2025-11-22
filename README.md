**Project**: Docker setup for running a Paper Minecraft server (PaperMC) using `Dockerfile` and `compose.yml`.

**Files**:
- **`Dockerfile`**: Builds the server image, downloads the Paper jar at build-time (via `ARG jarDownloadLink`), creates `eula.txt`, and starts the server with configurable RAM via environment variables.
- **`compose.yml`**: Compose service for `paper-server` with build args, runtime environment vars, ports, and persistent volumes for world data, plugins, and config files.

**Quick Start**
- **Build (docker)**: Build locally and optionally override the jar link:
```powershell
docker build --build-arg jarDownloadLink="https://example.com/paper.jar" -t paper-server:local .
```
- **Run (docker)**: Run the built image and override runtime RAM env vars:
```powershell
docker run -d -p 25565:25565 -e minRamEnv=2G -e maxRamEnv=3G --name paper-server paper-server:local
```
- **Run (docker compose)**: Use the repository `compose.yml` (file is named `compose.yml` in this repo):
```powershell
docker compose -f compose.yml up --build -d
docker compose -f compose.yml logs -f paper-server
```

**Configuration**
- **Build args**: You can change the jar that gets downloaded at build time using the build-arg `jarDownloadLink`.
  - Example: `--build-arg jarDownloadLink="https://.../paper.jar"`.
- **RAM settings**:
  - Build-time ARGs: `minRam` and `maxRam` provide defaults at build time.
  - Runtime ENVs: `minRamEnv` and `maxRamEnv` are used by the container to set `-Xms` and `-Xmx` when starting Java. These can be overridden via `docker run -e` or in `compose.yml` `environment`.
- **Volumes**: The `compose.yml` maps persistent folders to container paths:
  - World data: `./server-data/server-world:/minecraft/world` (and nether/end equivalents)
  - Plugins: `./server-data/server-plugins:/minecraft/plugins`
  - Config files: `./server.properties` and `./server-data/whitelist.json` are mapped so your server settings persist across container restarts.

**Notes & Recommendations**
- **ARG placement**: If you see `wget` downloading the literal string `$jarDownloadLink`, ensure `ARG jarDownloadLink` is declared after `FROM` in the `Dockerfile`. Build-time ARGs declared before `FROM` are not available to later build instructions.
- **EULA**: This setup creates `eula.txt` with `eula=true` at build time so the server can start automatically. By including this file you are asserting acceptance of Mojang's EULA — review it before publishing or distributing images that include `eula=true`.
- **Base image suggestion**: Alpine can be compact but sometimes complicates Java installs. Consider `openjdk:21-jdk-slim` for more predictable Java support and fewer package name differences.
- **Security**: For production, consider running the server as a non-root user inside the container and carefully review file permissions on volume mounts.
- **Variable naming**: You may prefer uppercase env var names (e.g., `MIN_RAM`, `MAX_RAM`) for consistency with environment conventions.
- **Restart policy**: Add `restart: unless-stopped` to `compose.yml` if you want the container to auto-restart on failure or host reboot.

**Troubleshooting**
- If `wget` saved a file named `$jarDownloadLink` (literal), confirm the `ARG` is declared after `FROM` and that the `RUN wget "$jarDownloadLink"` line sees the expanded value. Rebuild after changing the `Dockerfile`:
```powershell
docker build --no-cache -t paper-server:local .
```
- If Java packages fail to install on Alpine (`apk add openjdk21`), switch to a Debian-based OpenJDK image or check the correct package name for the Alpine repositories you are using.

**Publishing to GitHub**
- Include this `README.md`, `Dockerfile`, and `compose.yml` in the repository root.
- Do NOT commit server world data or plugin jars (large binaries). Add a `.gitignore` that excludes the `server-data` folder if you want to avoid accidental commits:
```gitignore
server-data/
```

**License & attribution**
- This repository contains scripts to fetch PaperMC artifacts. Ensure you respect PaperMC and Mojang distribution terms. Add a LICENSE file if you intend to publish code under a specific license.

If you'd like, I can:
- convert env var names to uppercase and update `CMD` accordingly;
- switch the `Dockerfile` to `openjdk:21-jdk-slim` and create a non-root user;
- add a `.gitignore` and a minimal `LICENSE` file template.

---
Last updated: 2025-11-22
