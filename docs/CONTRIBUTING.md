# Contributing to syv ⚡

First off, thank you for considering contributing to `syv`! It's people like you that make open-source tools powerful and accessible. 

This document outlines the process for contributing to the project, whether you are reporting a bug, suggesting a feature, or writing code.

## 🐛 Reporting Bugs
If you find a bug, please open an issue on GitHub. Include as much detail as possible:
* **OS / Environment:** (e.g., Termux on Android 13, Ubuntu 22.04, macOS Ventura)
* **Python Version:** (e.g., Python 3.10)
* **Steps to reproduce:** What exactly did you type into the terminal?
* **Expected vs. Actual behavior:** What did you expect to happen, and what actually happened?
* **Error Logs:** Paste any Python tracebacks or terminal outputs.

## 💡 Suggesting Enhancements
Have an idea to make `syv` faster or add a new optimization protocol? Open an issue and use the **Feature Request** label. 
* Explain *why* this feature is needed.
* Provide an example of how the terminal command would look.
* Detail how it interacts with the existing backend architecture.

## 👨‍💻 Pull Request Process

If you want to write code and submit a Pull Request (PR), please follow these steps:

1. **Fork the repository** and clone it to your local machine.
2. **Create a new branch** for your feature or bugfix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Keep the "Zero-Dependency" philosophy:** `syv` is designed to run anywhere without `pip install`. Do NOT add external libraries to the imports. Rely strictly on Python's standard library.
4. **Maintain the single-file structure:** For ease of installation, `syv` remains a single executable file. Do not split it into multiple modules unless absolutely necessary for a major V4.0 rewrite.
5. **Follow the aesthetic:** If adding terminal outputs, use the `log_info()`, `log_warn()`, and `log_sys()` functions to maintain the cyber-security terminal aesthetic.
6. **Commit your changes** with clear, descriptive commit messages.
7. **Push to your fork** and submit a Pull Request against the `main` branch.

## 🧑‍⚖️ Code of Conduct
By participating in this project, you agree to maintain a respectful, inclusive, and harassment-free environment for everyone. Be kind to other contributors.
