# syv ⚡ Development Guide

This guide is for developers who want to modify the `syv` source code, add new features, or test changes locally before pushing to production.

## 🛠️ Local Environment Setup

Since `syv` relies entirely on Python's standard library, setup is extremely simple.

1. **Prerequisites:** Ensure you have Python 3.6 or higher installed.
2. **Clone the repo:**
   ```bash
   git clone [https://github.com/yourusername/syv.git](https://github.com/yourusername/syv.git)
   cd syv
   ```
3. **Make it executable:**
   ```bash
   chmod +x syv
   ```
4. **Run it locally:** Instead of installing it globally, run it directly from the folder during development using `./syv`.
   ```bash
   ./syv help
   ```

## 🧪 Testing Your Changes

You don't need a complex backend to test `syv`. You can simulate both the SSG and SPA environments using basic terminal commands.

### Testing SSG Mode (HTML Scraper)
1. Open a new terminal tab and start a dummy Python web server:
   ```bash
   mkdir dummy_backend && cd dummy_backend
   echo "<h1>Hello from the backend</h1>" > index.html
   python3 -m http.server 8080
   ```
2. Go back to your `syv` terminal and run the scraper:
   ```bash
   ./syv run update -p 8080
   ```
3. Verify that `./syv_cache/index.html` and `manifest.json` were created successfully and contain the correct byte sizes.

### Testing SPA Mode (Compression)
1. Create a dummy frontend directory with heavy text files:
   ```bash
   mkdir -p test_dist/js test_dist/css
   # Create a 1MB dummy JS file
   head -c 1000000 /dev/urandom | base64 > test_dist/js/app.js
   ```
2. Run the build command:
   ```bash
   ./syv build ./test_dist
   ```
3. Verify that `app.js.gz` was created, check its compressed size, and ensure `build_manifest.json` contains the correct MD5 hash.

## 🧩 Extending the Router

If you are adding a new core command (e.g., `syv watch`), you need to update the router in the `main()` function.

1. **Write your function:** Add your logic above the `# --- Router Logic ---` section.
2. **Add to `main()`:** Parse the `sys.argv` array.
   ```python
   elif command == "watch":
       target_dir = args[1] if len(args) > 1 else "./dist"
       log_info("Initializing watch mode...")
       # Call your function here
   ```
3. **Update `print_help()`:** Don't forget to document your new command in the help menu!

## 📜 Coding Style Guidelines
* **PEP 8:** Follow standard Python PEP 8 formatting.
* **Error Handling:** Never let the script crash with a raw Python traceback. Wrap operations in `try/except` blocks and use `log_warn()` to output user-friendly error messages.
* **Type Hinting:** While not strictly enforced, adding standard Python type hints to new functions is highly encouraged for readability.
