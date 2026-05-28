# System Architecture: syv (Unified Optimization Daemon) v5.0 Ultimate

## 1. High-Level System Overview
`syv` is a zero-dependency, multi-threaded optimization daemon and static asset compiler. Written entirely in standard Python 3, it acts as a high-performance middleware layer bridging raw development environments and production web servers.

The v5.0 Ultimate architecture transitions the tool from a local development script into an enterprise-grade CI/CD utility. The engine is divided into four primary execution domains:
1. **Global Configuration & Safety State:** Dynamic runtime configuration, dry-run simulation, and strict POSIX exit codes.
2. **SPA Compiler (Multi-Threaded):** High-throughput, CPU-bound compression and hashing pipeline.
3. **SSG Scraper (Network IO & Discovery):** Concurrent multi-page HTML caching engine with automated `sitemap.xml` discovery.
4. **Lifecycle Management:** Automated workspace initialization and artifact purging.

---

## 2. Global State, Configuration & Safety

Before executing any specific module, `syv` initializes a global context (`CONFIG`) and determines the safety execution limits.

### Configuration Lifecycle
1. **Instantiation (`syv init`):** The system can automatically generate a safe `syv.json` template in the working directory.
2. **Parsing:** The daemon attempts to locate and read `syv.json`. It utilizes a strict whitelist (`allowed_keys`) to safely merge user settings (like `ttl` and `silent_mode`) without injecting malformed data into the global state.
3. **Dry-Run Simulation:** If the `--dry-run` flag is passed, the engine sets a global boolean. All subsequent modules bypass disk writing (`os.remove`, `gzip.open(wb)`, `shutil.rmtree`), allowing developers to simulate massive file operations safely.
4. **CI/CD Exit Codes:** All fatal exceptions are caught and explicitly terminate the daemon with `sys.exit(1)` to ensure automated pipelines fail immediately upon error.

### The Ignore Mechanism (O(N) Path Pruning)
To prevent the daemon from wasting CPU cycles, `syv` utilizes a path-pruning algorithm during its `os.walk()` traversal. By modifying the `dirs` array in-place (`dirs[:] = [d for d in dirs if not is_ignored(...)]`), the engine completely ignores branch execution for blacklisted directories like `node_modules` and `syv_cache`.

---

## 3. Module 1: The SPA Compiler (`compress_payloads`)

The SPA Compiler handles CPU-bound workloads (calculating MD5 hashes and Gzip compression) by maxing out the host machine's hardware capabilities.

### Multi-Threading Architecture
* **Thread Pool Executor:** `syv` imports `concurrent.futures` to bypass the linear execution bottleneck. 
* **Worker Allocation:** The engine dynamically polls the host OS for logical core counts (`os.cpu_count()`).
* **Thread Isolation:** Each file is passed to an isolated worker thread. The worker reads the binary, calculates the MD5 hash (for aggressive cache-busting), and writes the `.gz` payload.
* **Error Boundaries:** Exceptions within a single thread are caught and logged independently. A single corrupted file will *not* crash the entire build process.

---

## 4. Module 1B: Watch Daemon (`watch_payloads`)

To provide a modern developer experience, `syv` includes a continuous execution loop that monitors the filesystem for changes.

### Polling Mechanism
Instead of relying on heavy third-party event libraries, `syv` uses a lightweight, highly optimized polling loop.
* It stores the last modified timestamp (`os.path.getmtime`) of all valid files in memory.
* The daemon sleeps for `1` second intervals, then executes a fast directory traversal.
* If a file's `mtime` is newer than the memory state, it triggers a localized, single-file recompile and updates the manifest instantly.

---

## 5. Module 2: The SSG Scraper (`scrape_localhost`)

The v5.0 SSG Scraper has been completely overhauled from a single-page fetcher into a highly concurrent, multi-page Static Site Generation (SSG) engine.

### Execution Flow & Sitemap Discovery
1. **Target Acquisition:** Constructs the target base URL.
2. **Sitemap Discovery:** Executes a preliminary request to `/sitemap.xml`. If found, it parses the XML utilizing a zero-dependency Regex (`re.findall`) approach to extract all `<loc>` URLs, bypassing the need for heavy external XML libraries.
3. **Concurrent Network Fetching:** Spawns a secondary `ThreadPoolExecutor`. Hundreds of internal routes are scraped concurrently, drastically reducing overall generation time.
4. **Path Resolution:** Reconstructs the URL paths locally (e.g., `http://127.0.0.1/about` -> `./syv_cache/about/index.html`).
5. **The TTL Contract:** Writes `manifest.json` alongside the HTML, recording the exact UNIX timestamp (`generated_at`) and combined byte sizes.

---

## 6. The Backend Integration Contract (Data Flow)

`syv` generates optimized files but relies on a strict "Contract" with the hosting web server to serve them. 

### Data Flow A: Single Page Application (SPA)
1. **The Generator:** `syv build` generates `.gz` files and `build_manifest.json`.
2. **The Server Contract:** The backend server MUST read `build_manifest.json` and dynamically inject the hashed URLs (e.g., `app.js?v=e3b0c442`) into the client's `index.html`. 
3. **The Header Contract:** The server MUST intercept `.js`/`.css` requests, check for the `.gz` equivalent, and serve it with the `Content-Encoding: gzip` HTTP header.

### Data Flow B: Static Site Generation (SSG)
1. **The Generator:** `syv run update` builds the `./syv_cache/` directory structure.
2. **The Middleware Contract:** On incoming standard GET requests, the backend MUST check the `manifest.json` timestamp. 
3. **Validation:** * IF `(current_time - generated_at) < TTL`: Serve the matching file from `./syv_cache/` directly (HTTP 200).
   * IF expired: Serve the live dynamic route, and spawn `syv run update` in a background thread to regenerate the cache.

---

## 7. System & Resource Requirements

* **Runtime:** Python 3.6+
* **Dependencies:** None. Standard Library ONLY (`os`, `sys`, `time`, `urllib`, `json`, `gzip`, `hashlib`, `concurrent.futures`, `datetime`, `shutil`, `re`).
* **Environment Compatibility:** Fully Cross-Platform. Native POSIX (Linux, macOS, Termux) and Windows (NT) support including ANSI color injection.
* **Memory Footprint:** Highly efficient chunked binary reads ensure memory usage remains stable even when compressing massive payloads concurrently.
