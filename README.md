# syv ⚡ 
**The Zero-Dependency Optimization Daemon (v5.0 Ultimate)**

[![Python 3.6+](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-0-brightgreen.svg)]()
[![Platform: Linux | macOS | Windows | Termux](https://img.shields.io/badge/platform-POSIX%20%7C%20NT-lightgrey.svg)]()
[![CI/CD Ready](https://img.shields.io/badge/CI%2FCD-Ready-success.svg)]()

`syv` is a hyper-lightweight, multi-threaded optimization engine designed to sit between your raw development code and your production web servers. By natively handling **Single Page Application (SPA) payload compression** and **Static Site Generation (SSG) caching**, `syv` drastically reduces Time-To-First-Byte (TTFB) and network latency without the bloat of modern JS frameworks.

---

## 🧠 The Philosophy of `syv`

Modern web development suffers from dependency fatigue. Tools like Webpack, Vite, or Next.js are incredibly powerful, but they often require downloading gigabytes of `node_modules` just to perform basic file compression or routing. 

`syv` was built in defiance of this trend, strictly adhering to the following tenets:
1. **The Zero-Dependency Oath:** Written entirely in standard Python 3. No `pip install`, no `npm install`, no virtual environments. You drop the binary into your system, and it runs instantly.
2. **The UNIX Philosophy:** Do one thing, and do it perfectly. `syv` is not a web server. It is a file-generation middleware that generates mathematically hashed payloads and manifests for your actual server (Nginx, Express, FastAPI) to serve.
3. **Bare-Metal Performance:** By utilizing `concurrent.futures` for multi-threading and low-level `os.path` polling for file watching, it maximizes hardware utilization (from 8-core desktop CPUs to ARM-based Termux environments).
4. **Enterprise Reliability:** Built-in dry-runs, strict exit codes (`sys.exit(1)`), and silent modes make `syv` a bulletproof addition to any CI/CD pipeline.

---

## ✨ Core Capabilities

### 1. Multi-Core Payload Compression (SPA)
When dealing with hundreds of heavy JavaScript and CSS files, sequential compression is a bottleneck. `syv` maps your build directory to a `ThreadPoolExecutor`, utilizing 100% of available CPU cores to calculate MD5 hashes and generate `.gz` gzip streams simultaneously.

### 2. Live Watch Daemon (Developer Experience)
Instead of relying on heavy third-party filesystem event libraries (like `watchdog`), `syv watch` utilizes a highly optimized `os.path.getmtime` polling loop. It detects file saves in milliseconds, recompiling only the mutated asset and seamlessly rewriting the `build_manifest.json` without blocking the thread.

### 3. Dynamic API Freezing & Multi-Page SSG
Database queries are the enemy of speed. `syv run update` acts as a localized web crawler. In v5.0, it automatically detects `/sitemap.xml` and utilizes multi-threading to concurrently scrape and freeze your entire dynamic backend into a flat `./syv_cache/` directory alongside a Time-To-Live (TTL) metadata manifest.

### 4. System Lifecycle Management
Keep your environments clean. Automatically generate safe configurations using `syv init` and purge all optimization artifacts (`.gz`, manifests, caches) with a single `syv clean` command. 

---

## 📦 Installation

Since `syv` is a standalone Python script, installation is simply making it executable and moving it to your system's PATH.

**For Linux / macOS:**
```bash
curl -O [https://raw.githubusercontent.com/kyrtstn/syv/main/syv](https://raw.githubusercontent.com/kyrtstn/syv/main/syv)
chmod +x syv
sudo mv syv /usr/local/bin/
```

**For Android / Termux:**
```bash
curl -O [https://raw.githubusercontent.com/kyrtstn/syv/main/syv](https://raw.githubusercontent.com/kyrtstn/syv/main/syv)
chmod +x syv
mv syv $PREFIX/bin/
```

**For Windows (CMD / PowerShell):**
`syv` is 100% Windows compatible (including native ANSI colors).
1. Download `syv` via browser or `Invoke-WebRequest`.
2. Place it in your project folder.
3. Run directly via Python: `python syv help`
*(Optional: Create a `syv.bat` file in your Windows PATH containing `@python %~dp0\syv %*` for global execution).*

Verify the daemon is active:
```bash
syv help
```

---

## ⚙️ Configuration (`syv.json`)

`syv` can be controlled entirely via CLI arguments, but for enterprise projects, it respects a `syv.json` file placed in the project root. You can instantly generate a template using `syv init`.

```json
{
  "port": 3000,
  "ignore": [
    "node_modules",
    ".git",
    ".venv",
    "tests",
    "syv_cache"
  ],
  "ttl": 3600,
  "silent_mode": false
}
```

* **`ignore`:** Saves CPU cycles by pruning branch traversal during directory walking.
* **`ttl`:** Establishes the Time-To-Live contract (in seconds) for the SSG cache.
* **`silent_mode`:** When set to `true`, `syv` mutes all aesthetic logs (`[+]`, `[~]`) and only prints fatal errors, perfect for clean CI/CD logs.

---

## 🛠️ CLI Reference

### Global Utility
Manage the daemon state and workspace safely.
```bash
syv init                  # Generate default syv.json template
syv clean ./dist          # Purge .gz files, manifests, and local cache
syv build ./dist --dry-run # Simulate operations without disk I/O
```

### SPA Operations (Frontend Bundles)
Target your build directory to generate `.gz` files and the cache-busting manifest.
```bash
syv build ./dist          # Standard multi-threaded build
syv watch ./dist          # Initialize the live-reload daemon
syv build ./dist --debug  # Enable millisecond thread execution logs
```

### SSG Operations (Backend Endpoints)
Scrape the localhost port (and `sitemap.xml`) to generate static HTML cache.
```bash
syv run update            # Scrapes default port (8080 or config port)
syv run update -p 5000    # Scrape specific port
syv force run update      # Bypass TTL checks and force hard rebuild
```

---

## 🤖 CI/CD Automation (GitHub Actions)

`syv` is designed to run in headless CI environments. It utilizes strict POSIX exit codes (`sys.exit(1)`) to ensure failing builds stop the deployment pipeline immediately. 

Below is a standard `.yaml` pipeline to automate your payload optimization before deployment.

```yaml
name: syv Optimization Pipeline
on:
  push:
    branches: [ "main" ]
jobs:
  build-and-optimize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Compile Source Code
        run: npm run build
        
      - name: Optimize Payloads with syv
        run: |
          chmod +x ./syv
          # Use silent mode in syv.json or stick to default logs
          ./syv build ./dist
          
      - name: Deploy to Production
        run: echo "Insert rsync, AWS S3, or Docker deployment here"
```
