#!/bin/bash
# Tada terminal setup — reproduces Sami's shell environment on a new Mac.
# Idempotent: safe to re-run; existing pieces are skipped, ~/.zshrc is backed
# up before the Tada block is (re)written.
#
# Installs, scoped so ONLY Tada sessions get the fancy prompt:
#   - Maple Mono NF (Homebrew cask) — the app's font, incl. prompt glyphs
#   - Oh My Zsh + Powerlevel10k + zsh-autosuggestions + zsh-syntax-highlighting
#   - The canonical single-line p10k config (scripts/p10k.zsh) — single-line
#     prompts redraw cleanly on window resize (multi-line ones duplicate)
#   - A TADA-gated block in ~/.zshrc (other terminals stay untouched)
#
# Run:  bash setup-terminal.sh
# Or without the repo:
#   curl -fsSL https://raw.githubusercontent.com/SamiAbi/tada/main/setup-terminal.sh | bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd || true)"

step() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

# --- font ---
if [[ -n "$(ls "$HOME/Library/Fonts"/MapleMono-NF-* 2>/dev/null)" ]]; then
  step "Maple Mono NF already installed"
elif command -v brew >/dev/null 2>&1; then
  step "Installing Maple Mono NF (brew cask)"
  brew install --cask font-maple-mono-nf
else
  step "SKIP font: Homebrew not found — install Maple Mono NF manually (brew install --cask font-maple-mono-nf)"
fi

# --- oh my zsh ---
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  step "Oh My Zsh already installed"
else
  step "Installing Oh My Zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- theme + plugins ---
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] || {
  step "Installing Powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
}
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || {
  step "Installing zsh-autosuggestions"
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
}
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || {
  step "Installing zsh-syntax-highlighting"
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
}

# --- p10k config (canonical single-line lean) ---
if [[ -f "$SCRIPT_DIR/p10k.zsh" ]]; then
  P10K_SRC="$SCRIPT_DIR/p10k.zsh"
else
  step "Fetching canonical p10k config from GitHub"
  P10K_SRC="$(mktemp)"
  curl -fsSL https://raw.githubusercontent.com/SamiAbi/tada/main/p10k.zsh -o "$P10K_SRC"
fi
if [[ -f "$HOME/.p10k.zsh" ]]; then
  cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup-tada"
  step "Existing ~/.p10k.zsh backed up to ~/.p10k.zsh.backup-tada"
fi
cp "$P10K_SRC" "$HOME/.p10k.zsh"
step "Installed single-line p10k config"

# --- TADA block in ~/.zshrc ---
MARK_BEGIN="# >>> tada shell (managed by setup-terminal.sh) >>>"
MARK_END="# <<< tada shell <<<"
touch "$HOME/.zshrc"
cp "$HOME/.zshrc" "$HOME/.zshrc.backup-tada"
# strip a previous managed block (incl. the legacy termdeck-era one), then append
python3 - "$HOME/.zshrc" "$MARK_BEGIN" "$MARK_END" <<'PYEOF'
import sys
path, begin, end = sys.argv[1], sys.argv[2], sys.argv[3]
begins = {begin, "# >>> termdeck shell (managed by setup-terminal.sh) >>>"}
ends = {end, "# <<< termdeck shell <<<"}
lines = open(path).read().split("\n")
out, skip = [], False
for ln in lines:
    if ln.strip() in begins: skip = True; continue
    if ln.strip() in ends: skip = False; continue
    if not skip: out.append(ln)
open(path, "w").write("\n".join(out).rstrip("\n") + "\n")
PYEOF
cat >> "$HOME/.zshrc" <<EOF
$MARK_BEGIN
# Fancy shell (Oh My Zsh + Powerlevel10k + plugins) ONLY inside Tada —
# other terminals stay plain. Tada sets TADA=1 for its sessions.
if [[ -n "\$TADA" ]]; then
  if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
    source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
  fi
  export ZSH="\$HOME/.oh-my-zsh"
  ZSH_THEME="powerlevel10k/powerlevel10k"
  plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
  source "\$ZSH/oh-my-zsh.sh"
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  # Belt-and-braces: never redraw the prompt on window resize.
  TRAPWINCH() {}
fi
$MARK_END
EOF
step "Tada block written to ~/.zshrc (backup: ~/.zshrc.backup-tada)"

step "Done. Open a new Tada session (Cmd+T) to see the prompt."
