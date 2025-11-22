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

