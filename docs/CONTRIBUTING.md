# Contributing to syv ⚡

First off, thank you for taking the time to contribute! `syv` is built by and for developers who value speed, simplicity, and terminal aesthetics. 

This document outlines the strict guidelines we follow to maintain the integrity of the project, especially as we scale for enterprise CI/CD environments.

## ⚖️ The Zero-Dependency Oath (CRITICAL)

The defining characteristic of `syv` is that it requires **zero external packages**. 
* You **MUST NOT** add `import requests`, `import bs4`, `import watchdog`, or any other library that requires `pip install`.
* If a feature cannot be built using Python's standard library (`urllib`, `os`, `sys`, `concurrent.futures`, `hashlib`, `re`, etc.), the feature will not be merged.
* When dealing with complex data structures (e.g., our `sitemap.xml` parser), you must utilize built-in modules like Regex (`re`) instead of relying on external parsers.
* `syv` must remain a single-file executable to preserve its drop-in nature. Do not break the architecture into multiple `.py` files.

## 🐛 Reporting Bugs

A good bug report saves hours of debugging. If you encounter an issue, please open a GitHub Issue using the following blueprint:

1. **Environment:** OS (Ubuntu 22.04, Windows 11 CMD, Termux, macOS), CPU architecture, and Python version (e.g., Python 3.10.12).
2. **The Command:** What exactly did you type? (e.g., `syv build ./frontend --debug`).
3. **The Configuration:** Paste your `syv.json` if you are using one.
4. **The Debug Log:** You MUST run the failing command with the `--debug` flag and paste the raw terminal output. This exposes thread crashes and timing limits.
5. **Dry-Run Check:** If the bug involves file generation or deletion (like `syv clean`), please state if the issue persists when using the `--dry-run` flag.

## 🚀 Proposing Features

We love new optimization protocols, but they must align with the UNIX philosophy and our Enterprise CI/CD goals. Open an issue first to discuss the architecture before writing code. If you want to add a feature:
* Explain the bottleneck it solves.
* Propose the CLI syntax.
* Prove it can be done without external dependencies.
* Detail how the feature will respect the `--dry-run` and `silent_mode` safety mechanisms.

## 👨‍💻 The Pull Request (PR) Lifecycle

1. **Fork** the repository and clone it locally.
2. **Branch** off `main` (`git checkout -b feat/your-feature-name`).
3. **Write Code (Aesthetics & Safety):** Maintain the cyber-security terminal aesthetic by using the internal `log_info()`, `log_sys()`, and `log_warn()` wrappers. Do not use raw `print()` statements unless modifying the progress bar.
4. **Respect Dry-Run:** If your code writes, deletes, or modifies files, you MUST wrap the I/O execution in a `if not DRY_RUN_MODE:` block.
5. **CI/CD Reliability:** Never let the daemon swallow fatal errors. Use `try/except` blocks to catch exceptions, output user-friendly warnings, and strictly use `sys.exit(1)` for failures and `sys.exit(0)` for success so automated pipelines do not deploy broken builds.
6. **Handle Threads Safely:** If adding IO operations to the SPA or SSG modules, ensure they are executed within the `ThreadPoolExecutor` context and handle exceptions locally so the main daemon does not crash.
7. **Commit:** Write clear, descriptive commit messages.
8. **Submit:** Open a PR against `main`. Maintainers will review the code for standard library compliance, cross-platform (POSIX/Windows) compatibility, and performance regressions.
