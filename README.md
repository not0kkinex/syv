# syv ⚡ 
**Unified Optimization Daemon**

`syv` is a lightweight, zero-dependency Python Command Line Interface (CLI) designed to drastically reduce web application load times. It acts as a bridge between your raw code and your production server, offering two powerful optimization protocols: 

1. **SSG HTML Caching:** Scrapes dynamic backends and locks them into static HTML files for instant delivery.
2. **SPA Payload Compression:** Scans your frontend directories, crushes JavaScript/CSS bundles with Gzip, and generates MD5 hashes for flawless browser cache-busting.

## ✨ Features

* **Zero Dependencies:** Runs on standard Python 3. No `pip install` required.
* **Dual Architecture:** Handles both traditional multi-page sites and modern Single Page Applications (React, Vue, Next.js).
* **Termux Native:** Fully compatible with Android/Termux environments, utilizing `$PREFIX` paths perfectly.
* **Manifest Generation:** Automatically writes `manifest.json` metadata files so your backend knows exactly when to serve the cache and when to rebuild.
* **Cyber-Aesthetic CLI:** Crisp, color-coded terminal outputs for clear system monitoring.

---

## 📦 Installation (Termux / Linux / macOS)

1. Download or clone the `syv` script.
2. Make the script executable and move it to your system's binary folder.

**For Termux:**
```bash
chmod +x syv
mv syv $PREFIX/bin/
```

**For Linux / macOS:**
```bash
chmod +x syv
sudo mv syv /usr/local/bin/
```

Verify the installation by running:
```bash
syv help
```

---

## 🛠️ Usage

### 1. SSG Caching Mode (HTML Scraper)
Use this for traditional websites, blogs, or APIs where you want to cache the final output of a localhost server.

* **Standard Update:** Scrapes the default port (8080) and saves the HTML payload to `./syv_cache/index.html`.
  ```bash
  syv run update
  ```
* **Target Specific Port:** Scrape a different localhost port (e.g., your dev server on 3000).
  ```bash
  syv run update -p 3000
  ```
* **Force Rebuild:** Bypass TTL warnings and force a hard scrape.
  ```bash
  syv force run update -p 3000
  ```

### 2. SPA Build Optimizer (JS/CSS Compression)
Use this before deploying a React, Vue, or heavily interactive frontend application.

* **Compress & Hash:** Scans the target directory for `.js` and `.css` files, compresses them to `.gz`, and generates a `build_manifest.json` with MD5 hashes.
  ```bash
  syv build ./dist
  ```
*(If no directory is provided, it defaults to `./dist`)*

---

## 🔌 Backend Integration Guide

`syv` does the heavy lifting, but your web server (Express, Flask, Nginx) needs to be configured to take advantage of the optimized files. Pass these instructions to your backend developer (or AI) to complete the setup.

### Integration 1: For SSG Caching
When `syv run update` runs, it generates `./syv_cache/index.html` and `./syv_cache/manifest.json`.
* **Backend Middleware Logic:** On incoming GET requests, check if `index.html` exists. If it does, read `manifest.json` to check the `generated_at` timestamp. If the cache is fresh (under your TTL limit), serve the static HTML immediately and bypass the database. If it is expired, serve the dynamic route and run a background shell command (`syv run update`) to refresh the cache.

### Integration 2: For SPA Payloads
When `syv build ./dist` runs, it generates compressed `.gz` files and a `build_manifest.json` containing file hashes (e.g., `{"app.js": "app.js?v=e3b0c442"}`).
* **Backend Shell Logic:** Read `build_manifest.json` and dynamically inject the hashed filenames into your base `index.html` file before sending it to the user.
* **Server Routing:** Configure your server (e.g., Nginx or Express static middleware) to look for `.gz` variants of requested JavaScript or CSS files. If a compressed version exists, serve it with the `Content-Encoding: gzip` header.

---
*Built for terminal hackers and performance obsessives.*
