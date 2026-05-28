# syv ⚡ Development & Debugging Guide

This guide is for developers who want to modify the `syv` source code, add new features, or test changes locally before pushing to production. Since we do not rely on heavy testing frameworks like `pytest`, we utilize a manual, highly effective sandbox testing strategy.

## 🛠️ Local Environment Setup

Since `syv` relies entirely on Python's standard library, the setup is extremely simple and cross-platform.

1. **Prerequisites:** Ensure you have Python 3.6 or higher installed.
2. **Clone the repo:**
   ```bash
   git clone [https://github.com/kyrtstn/syv.git](https://github.com/kyrtstn/syv.git)
   cd syv
   ```
3. **Make it executable (POSIX - Linux/macOS/Termux):**
   ```bash
   chmod +x syv
   ```
4. **Windows Setup (Optional but recommended):**
   If developing on Windows CMD/PowerShell, create a `syv.bat` file in the root directory containing:
   ```bat
   @python %~dp0\syv %*
   ```
5. **Run it locally:** Instead of installing it globally, run it directly from the folder during development using `./syv` (or just `syv` if using the `.bat` wrapper on Windows).
   ```bash
   ./syv help
   ```

---

## 🧪 Testing Your Changes (The Sandbox)

You don't need a complex React app or a live database to test `syv`. You can simulate both the SSG and SPA environments using basic bash commands.

### 1. Testing SSG Mode (HTML Scraper)
1. Open a new terminal tab and start a dummy Python web server to simulate a backend:
   ```bash
   mkdir dummy_backend && cd dummy_backend
   echo "<h1>Hello from the simulated backend</h1>" > index.html
   python3 -m http.server 8080
   ```
2. Go back to your main `syv` terminal and run the scraper:
   ```bash
   ./syv run update -p 8080
   ```
3. Verify that `./syv_cache/index.html` and `./syv_cache/manifest.json` were created successfully and contain the correct byte sizes and timestamps.

### 2. Testing SPA Mode (Multi-Threaded Compression)
1. Create a dummy frontend directory with massive text files to test thread performance:
   ```bash
   mkdir -p test_dist/js test_dist/css
   # Generate 5MB of random data pretending to be JavaScript
   head -c 5000000 /dev/urandom | base64 > test_dist/js/heavy_bundle.js
   head -c 2000000 /dev/urandom | base64 > test_dist/css/heavy_styles.css
   ```
2. Run the build command with the debug flag to watch the threads in action:
   ```bash
   ./syv build ./test_dist --debug
   ```
3. Verify that `heavy_bundle.js.gz` was created, check its compressed size, and ensure `build_manifest.json` contains the correct MD5 hash.

### 3. Testing Config & Watch Mode Daemon
1. Create a dummy configuration file in the project root:
   ```bash
   echo '{"ignore": ["ignore_me"]}' > syv.json
   ```
2. Create an ignored directory and add a test file:
   ```bash
   mkdir test_dist/ignore_me
   echo "console.log('test')" > test_dist/app.js
   ```
3. Start the watch daemon:
   ```bash
   ./syv watch ./test_dist --debug
   ```
4. In another terminal, modify `app.js` to trigger a recompile. The daemon should detect the change in milliseconds:
   ```bash
   echo "console.log('update')" >> test_dist/app.js
   ```

### 4. Testing Multi-Page SSG (Sitemap Discovery)
1. In your `dummy_backend` directory, create a dummy `sitemap.xml` file to test the regex extraction:
   ```bash
   echo '<urlset><url><loc>[http://127.0.0.1:8080/about.html](http://127.0.0.1:8080/about.html)</loc></url><url><loc>[http://127.0.0.1:8080/contact/](http://127.0.0.1:8080/contact/)</loc></url></urlset>' > sitemap.xml
   echo "<h1>About Page</h1>" > about.html
   mkdir contact && echo "<h1>Contact Page</h1>" > contact/index.html
   ```
2. Run the update command:
   ```bash
   ./syv run update -p 8080
   ```
3. Verify that `syv_cache` now contains nested directories reflecting the sitemap URLs (e.g., `syv_cache/about.html` and `syv_cache/contact/index.html`).

### 5. Testing Safety Mechanisms (Dry-Run & Clean)
1. Generate the initial configuration template:
   ```bash
   ./syv init
   ```
2. Test the destructive `clean` command using the `--dry-run` flag to ensure it doesn't actually delete anything:
   ```bash
   ./syv clean ./test_dist --dry-run
   ```
3. Remove the `--dry-run` flag to perform the actual purge and check if `.gz` files and the `syv_cache` are destroyed properly.

---

## 🧩 Extending the Router

If you are adding a new core command (e.g., `syv analyze`), you need to update the router in the `main()` function safely.

1. **Write your core function:** Add your logic above the `# --- Router Logic ---` section. Keep it modular.
2. **Update the `main()` execution block:** Parse the `sys.argv` array. Remember that `--debug` and `--dry-run` are stripped out globally before this point.
   ```python
   elif command == "analyze":
       target_dir = args[1] if len(args) > 1 else "./dist"
       log_sys(f"Initializing deep analysis on {target_dir}...")
       # Call your new function here
       # analyze_payloads(target_dir)
   ```
3. **Update `print_help()`:** Don't forget to document your new command syntax in the help menu so other developers know it exists!

---

## 📜 Coding Style & Engineering Guidelines

* **The Zero-Dependency Oath:** NEVER add external libraries via `pip`. If a feature requires XML parsing (like sitemaps), use standard library `re` (Regex) instead of external parsers like `lxml` or `BeautifulSoup`.
* **CI/CD Reliability (Exit Codes):** Never let the script crash with a raw Python traceback, but DO NOT swallow fatal errors. Use `try/except` blocks to catch exceptions, output user-friendly error messages using `log_warn()`, and **always terminate with `sys.exit(1)`** so CI/CD pipelines (like GitHub Actions) know the build failed.
* **PEP 8:** Follow standard Python PEP 8 formatting.
* **Thread Safety:** When modifying the `compress_payloads` or `scrape_localhost` functions, you are working with concurrent threads. Ensure all heavy IO operations remain inside the `ThreadPoolExecutor` context. Exceptions within a background thread must be caught locally so they do not silently crash the worker.
* **Type Hinting:** While not strictly enforced, adding standard Python type hints (`def process(filepath: str) -> dict:`) to new functions is highly encouraged for readability.

## 🎨 Terminal Aesthetic Standards

`syv` is designed for terminal hackers. Maintain the established color-coding structure for all console outputs. Note that `--dry-run` mode will automatically prefix these with `[DRY-RUN]`.

* **`C_GREEN`** (`log_info`): Use for successful operations, completions, and positive states.
* **`C_CYAN`** (`log_sys`): Use for system initialization, directory scanning, and neutral daemon states.
* **`C_ORANGE`** (`log_warn`): Use for non-fatal errors, missing directories, thread exceptions, and connection failures.
* **`C_MAGENTA`** (`log_debug`): Use for deep system telemetry, millisecond timings, and raw variable dumps (only visible when `--debug` is active).
