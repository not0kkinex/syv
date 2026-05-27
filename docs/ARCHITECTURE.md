# System Architecture: syv (Unified Optimization Daemon) v4.0

## 1. High-Level System Overview
`syv` is a zero-dependency, multi-threaded optimization daemon and static asset compiler. Written entirely in standard Python 3, it acts as a high-performance middleware layer bridging raw development environments and production web servers.

The v4.0 architecture moves away from a simple linear script and introduces a highly concurrent, state-aware engine divided into three primary execution domains:
1. **Global Configuration State:** Dynamic runtime configuration and environment parsing.
2. **SPA Compiler (Multi-Threaded):** High-throughput, CPU-bound compression and hashing pipeline.
3. **SSG Scraper (Network IO):** Dynamic-to-static HTML caching engine with Time-To-Live (TTL) metadata generation.

---

## 2. Global State & Configuration Management

Before executing any specific module, `syv` initializes a global context to dictate execution parameters.

### Configuration Lifecycle
1. **Instantiation:** The system loads a default fallback dictionary (`CONFIG`).
2. **Parsing:** It attempts to locate and read `syv.json` in the current working directory.
3. **Merging:** If found, user-defined parameters gracefully override the defaults. 

### The Ignore Mechanism (O(N) Path Pruning)
To prevent the daemon from wasting CPU cycles or falling into recursive loops (e.g., compressing files inside `.git` or `node_modules`), `syv` utilizes a path-pruning algorithm during its `os.walk()` traversal. 
* By modifying the `dirs` array in-place (`dirs[:] = [d for d in dirs if not is_ignored(...)]`), the engine completely ignores branch execution for blacklisted directories, maintaining high traversal speed even in massive repositories.

---

## 3. Module 1: The SPA Compiler (`compress_payloads`)

The SPA Compiler is designed to handle CPU-bound workloads (calculating MD5 hashes and Gzip compression) by maxing out the host machine's hardware capabilities.

### Multi-Threading Architecture
* **Thread Pool Executor:** `syv` imports `concurrent.futures` to bypass the linear execution bottleneck. 
* **Worker Allocation:** The engine dynamically polls the host OS for logical core counts (`os.cpu_count()`). If indeterminate, it safely falls back to `4` workers.
* **Thread Isolation:** Each file is passed to an isolated worker thread (`process_single_file`). The worker reads the binary, calculates the MD5 hash (used for aggressive browser cache-busting), and writes the `.gz` payload.
* **Error Boundaries:** Exceptions within a single thread (e.g., file permission errors) are caught and logged independently. A single corrupted file will *not* crash the entire build process.

### The Build Manifest
As threads complete their tasks, they return their generated hash URLs to the main thread, which constructs the `build_manifest.json`. This acts as the routing table for the backend server.

---

## 4. Module 1B: Watch Daemon (`watch_payloads`)

To provide a modern developer experience, `syv` includes a continuous execution loop that monitors the filesystem for changes.

### Polling Mechanism
Instead of relying on heavy, third-party filesystem event libraries (like `watchdog`), `syv` uses a lightweight, highly optimized polling loop.
* It stores the last modified timestamp (`os.path.getmtime`) of all valid files in memory.
* The daemon sleeps for `1` second intervals, then executes a fast directory traversal.
* If a file's `mtime` is newer than the memory state, it triggers a localized, single-file recompile and updates the manifest instantly.

---

## 5. Module 2: The SSG Scraper (`scrape_localhost`)

The SSG Scraper handles Network I/O-bound tasks, designed to eliminate database query times by converting dynamic API endpoints into flat `.html` files.

### Execution Flow
1. **Target Acquisition:** Constructs the target URL based on the injected `--port` or `syv.json` config.
2. **Request Masking:** Sets a strict `User-Agent: SYV-Terminal-CLI/4.0`. This allows the backend server to specifically identify and authorize the scraper.
3. **Payload Extraction:** Extracts the raw HTML and measures the exact byte payload.
4. **Metadata Generation (The TTL Contract):** Writes `manifest.json` alongside the HTML, recording the exact UNIX timestamp (`generated_at`). This mathematical timestamp is the cornerstone of the caching strategy.

---

## 6. The Backend Integration Contract (Data Flow)

`syv` generates the optimized files, but relies on a strict "Contract" with the hosting web server (Node.js, Nginx, Python ASGI) to serve them. 

### Data Flow A: Single Page Application (SPA)
1. **The Generator:** `syv` builds `.gz` files and `build_manifest.json`.
2. **The Server Contract:** The backend server MUST read `build_manifest.json` and dynamically inject the hashed URLs (e.g., `app.js?v=e3b0c442`) into the client's `index.html`. 
3. **The Header Contract:** The server MUST intercept `.js`/`.css` requests, check for the `.gz` equivalent, and serve it with the `Content-Encoding: gzip` HTTP header.

### Data Flow B: Static Site Generation (SSG)
1. **The Generator:** `syv` builds `./syv_cache/index.html` and `./syv_cache/manifest.json`.
2. **The Middleware Contract:** On incoming standard GET requests, the backend MUST check the `manifest.json` timestamp. 
3. **Validation:** * IF `(current_time - generated_at) < TTL`: Serve `./syv_cache/index.html` directly (HTTP 200).
   * IF expired: Serve the live dynamic route, and spawn `syv run update` in a non-blocking background thread to regenerate the cache.

---

## 7. System & Resource Requirements

* **Runtime:** Python 3.6+
* **Dependencies:** None. Standard Library ONLY (`os`, `sys`, `time`, `urllib`, `json`, `gzip`, `hashlib`, `concurrent.futures`, `datetime`).
* **Environment Compatibility:** Fully POSIX-compliant. Tested on Linux, macOS, and Termux (Android).
* **Memory Footprint:** Highly efficient. Utilizes chunked binary reads to ensure memory usage remains stable even when compressing massive (50MB+) payloads.
