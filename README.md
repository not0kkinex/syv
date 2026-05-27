# syv ⚡ 
**Unified Optimization Daemon (v4.0)**

`syv` is a lightweight, zero-dependency Python Command Line Interface (CLI) designed to drastically reduce web application load times. It bridges the gap between raw development code and production web servers without the bloat of massive frameworks.

## 🧠 The Philosophy of `syv`
Modern web development is plagued by dependency hell. Tools like Webpack or Next.js download gigabytes of `node_modules` just to compress a file. `syv` was built on a different philosophy:
1. **Zero-Dependency:** Written purely in standard Python 3. You can drop it into any Linux, macOS, or Android/Termux environment and it runs instantly. No `pip install`, no `npm install`.
2. **Do One Thing Perfectly:** It doesn't try to be a web framework. It sits *on top* of your existing stack to handle **SSG HTML Caching** and **SPA Payload Compression** natively and efficiently.
3. **Cyber-Aesthetic:** Designed for terminal hackers. Clean outputs, millisecond precision, and a strictly functional architecture.

---

## ✨ Features
* **Multi-Threaded Build:** Uses all available CPU cores via `concurrent.futures` to crush hundreds of JS/CSS files into `.gz` payloads in seconds.
* **Watch Mode Daemon:** Detects file saves in real-time and recompiles individual assets in milliseconds.
* **Configurable:** Uses a simple `syv.json` file for routing and ignore patterns.
* **Debug Mode:** Use the `--debug` flag for low-level execution logs and thread tracking.

## 📦 Installation
```bash
chmod +x syv
sudo mv syv /usr/local/bin/ # For Linux/macOS
# OR
mv syv $PREFIX/bin/ # For Termux
```

## 🛠️ Usage

### 1. SPA Build Optimizer (Frontend)
Compress your React, Vue, or Vanilla JS/CSS files and generate a cache-busting `build_manifest.json`.
```bash
syv build ./dist          # Standard build
syv watch ./dist          # Live development watch mode
syv build ./dist --debug  # Build with verbose timings
```

### 2. SSG Caching Mode (Backend)
Scrape your dynamic server and freeze it into an instant-load static HTML file.
```bash
syv run update -p 3000
syv force run update
```

## 🤖 CI/CD Pipeline (GitHub Actions)
You can easily automate `syv` for your production deployments. Create `.github/workflows/syv-build.yml`:
```yaml
name: syv Optimization Pipeline
on:
  push:
    branches: [ "main" ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build JS/CSS
        run: npm run build
        
      - name: Optimize with syv
        run: |
          chmod +x syv
          ./syv build ./dist
          
      - name: Deploy to Server
        run: echo "Add deployment scripts here"
```
