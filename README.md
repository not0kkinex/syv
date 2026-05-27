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
