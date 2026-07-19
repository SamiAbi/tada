<p align="center"><img src="icon.png" width="128" alt="Tada"></p>

<h1 align="center">Tada 🎉</h1>

<p align="center"><b>Your terminal cockpit for macOS.</b><br>
Terminal first, workspaces like VS Code, git &amp; PRs built in — one fast native window.</p>

---

## Download

**[⬇ Download Tada for macOS](https://github.com/SamiAbi/tada/releases/latest/download/Tada.dmg)** (Apple Silicon)

This repository hosts releases of Tada. The app is built with Tauri and Rust.

## Install

1. Open `Tada.dmg` and drag **Tada** into **Applications**.
2. First launch: macOS will say *"Tada is damaged and can't be opened"* — it isn't. That's Gatekeeper flagging an app that isn't notarized by Apple yet. Run this once, then open Tada normally:
   ```sh
   xattr -cr /Applications/Tada.app
   ```

## Make the terminal beautiful (optional)

One command installs Maple Mono NF, Oh My Zsh, Powerlevel10k, autosuggestions and syntax highlighting — scoped to Tada sessions only; your other terminals stay untouched:

```sh
curl -fsSL https://raw.githubusercontent.com/SamiAbi/tada/main/setup-terminal.sh | bash
```

## Features

- ⚡️ GPU-rendered terminal with a lean single-line Powerlevel10k prompt
- 🗂 VS Code-style workspaces — pick on launch, pin favorites, switch with ⌘⇧O
- 🌿 Git panel: stage, commit, branch, safe remote checkouts
- 🔍 GitHub-style split diffs with word-level highlights and syntax colors
- 🔀 Pull requests: list, check out, and merge from inside the app
- 📝 CodeMirror editor and file explorer with Material icons
