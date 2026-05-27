# System Architecture: syv (Unified Optimization Daemon)

## 1. High-Level Overview
`syv` is a zero-dependency, dual-protocol optimization engine written in Python. It is designed to act as a middleware bridge between raw development code and production web servers. 

The system routes user commands into one of two isolated execution environments:
* **Module 1 (SPA Protocol):** A static asset compiler that prepares client-side bundles (React, Vue) for maximum network efficiency.
* **Module 2 (SSG Protocol):** A dynamic-to-static HTML scraper that freezes backend API outputs into flat files.

## 2. Core Components

### A. The CLI Router (`main()`)
* **Purpose:** Intercepts system arguments (`sys.argv`) and routes them to the appropriate functional block.
* **Error Handling:** Catches `KeyboardInterrupt` (Ctrl+C) for graceful exits and handles missing arguments without throwing raw Python tracebacks.

### B. Module 1: The Build Optimizer (`compress_payloads`)
* **Purpose:** Reduces network transfer time and manages browser caching strategies.
* **Process:**
    1.  Recursively walks the target directory (e.g., `./dist`).
    2.  Identifies `.js` and `.css` files.
    3.  Reads the binary payload and generates an MD5 hash (`generate_file_hash`).
    4.  Compresses the payload using the `gzip` standard library.
    5.  Writes a `build_manifest.json` mapping original filenames to their cache-busting URLs (e.g., `app.js -> app.js?v=a1b2c3d4`).

### C. Module 2: The SSG Scraper (`scrape_localhost`)
* **Purpose:** Eliminates database query time by pre-rendering dynamic routes.
* **Process:**
    1.  Targets a specified localhost port using `urllib`.
    2.  Executes a GET request using a custom User-Agent (`SYV-Terminal-CLI/3.0`).
    3.  Extracts the raw HTML and HTTP status code.
    4.  Writes the HTML payload to `./syv_cache/index.html`.
    5.  Generates a machine-readable `manifest.json` (`write_manifest`) containing UNIX timestamps and byte sizes to establish a Time-To-Live (TTL) contract with the backend server.

## 3. Data Flow & The Integration Contract

`syv` is strictly a file-generator. It relies on a "Contract" with the hosting web server (Express, Nginx, etc.) to achieve actual speed improvements.

### Data Flow: Single Page Application (SPA)
1.  **Input:** Developer runs `syv build ./dist`.
2.  **Operation:** `syv` generates `.gz` files and `build_manifest.json`.
3.  **The Contract:** The backend server MUST read `build_manifest.json` and inject the hashed URLs into the client's `index.html`. The server MUST route requests for `.js` to the `.gz` files with the `Content-Encoding: gzip` header.

### Data Flow: Static Site Generation (SSG)
1.  **Input:** Developer runs `syv run update`.
2.  **Operation:** `syv` generates `./syv_cache/index.html` and `./syv_cache/manifest.json`.
3.  **The Contract:** The backend server MUST intercept incoming GET requests. It checks the `manifest.json` timestamp. If valid, it serves `./syv_cache/index.html`. If expired, it serves the dynamic route and spawns `syv run update` in a background thread.

## 4. System Requirements
* Python 3.6+
* Standard Library dependencies only (`os`, `sys`, `time`, `urllib`, `json`, `gzip`, `hashlib`, `datetime`).
* Compatible with POSIX environments (Linux, macOS, Termux/Android).
