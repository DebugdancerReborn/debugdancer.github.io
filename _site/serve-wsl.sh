#!/usr/bin/env bash
# serve-wsl.sh — First-time setup and local serve for Jekyll on WSL (Ubuntu/Debian)
# Run from the repo root: bash serve-wsl.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEMFILE="$REPO_DIR/Gemfile"

# ── Colours ────────────────────────────────────────────────────────────────────
green()  { echo -e "\033[32m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }
red()    { echo -e "\033[31m$*\033[0m"; }

# ── 1. System packages ─────────────────────────────────────────────────────────
yellow "==> Updating apt and installing Ruby + build tools..."
sudo apt-get update -qq
sudo apt-get install -y ruby-full build-essential zlib1g-dev
green "    Ruby: $(ruby --version)"

# ── 2. User gem directory (avoids sudo for every gem) ─────────────────────────
GEMS_DIR="$HOME/gems"
if ! grep -q 'GEM_HOME.*gems' "$HOME/.bashrc" 2>/dev/null; then
    yellow "==> Adding GEM_HOME to ~/.bashrc..."
    {
        echo ''
        echo '# Ruby gems (added by serve-wsl.sh)'
        echo "export GEM_HOME=\"$GEMS_DIR\""
        echo 'export PATH="$GEM_HOME/bin:$PATH"'
    } >> "$HOME/.bashrc"
fi
export GEM_HOME="$GEMS_DIR"
export PATH="$GEM_HOME/bin:$PATH"

# ── 3. Bundler ─────────────────────────────────────────────────────────────────
if ! command -v bundle &>/dev/null; then
    yellow "==> Installing Bundler..."
    gem install bundler
fi
green "    Bundler: $(bundle --version)"

# ── 4. Gemfile ─────────────────────────────────────────────────────────────────
if [[ ! -f "$GEMFILE" ]]; then
    yellow "==> No Gemfile found — creating one..."
    cat > "$GEMFILE" <<'EOF'
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
gem "jekyll-include-cache"
EOF
    green "    Gemfile created."
fi

# ── 5. Bundle install ──────────────────────────────────────────────────────────
cd "$REPO_DIR"
yellow "==> Running bundle install (slow on first run)..."
bundle install
green "    Gems ready."

# ── 6. Serve ───────────────────────────────────────────────────────────────────
echo ""
green "==> Starting Jekyll at http://localhost:4000"
echo "    Open that URL in your Windows browser."
echo "    Press Ctrl+C to stop."
echo ""
bundle exec jekyll serve --livereload
