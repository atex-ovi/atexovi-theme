#!/usr/bin/env bash
# i7-restore.sh — Build 7: Generate restore.sh safely

set -euo pipefail

BASE="$HOME/atexovi-theme"
RESTORE_SH="$HOME/restore.sh"
PREFIX=${PREFIX:-/data/data/com.termux/files/usr}

info()    { printf "\e[1;36m[*]\e[0m %s\n" "$1"; }
success() { printf "\e[1;32m[✓]\e[0m %s\n" "$1"; }
warn()    { printf "\e[1;33m[!]\e[0m %s\n" "$1"; }

info "Preparing restore module (Build 7)..."
sleep 0.5

cat > "$RESTORE_SH" <<'RESTORE_EOF'
#!/usr/bin/env bash
# =====================================================
# restore.sh — Restore Termux to default clean state
# Atexovi Build 7 (clean, safe backup)
# =====================================================

set -euo pipefail
PREFIX=${PREFIX:-/data/data/com.termux/files/usr}

info()    { printf "\e[1;36m[*]\e[0m %s\n" "$1"; }
success() { printf "\e[1;32m[✓]\e[0m %s\n" "$1"; }

clear
info "Starting Termux restoration process..."
sleep 1

# -----------------------------------------------------
# Ensure bash as default shell
# -----------------------------------------------------
if [ -x "$PREFIX/bin/bash" ]; then
    chsh -s "$PREFIX/bin/bash" >/dev/null 2>&1 || true
fi

# -----------------------------------------------------
# Backup atexovi-theme before restore
# -----------------------------------------------------
if [ -d "$HOME/atexovi-theme" ]; then
    BACKUP="$HOME/atexovi-theme.bak"
    info "Backing up atexovi-theme → atexovi-theme.bak"
    rm -rf "$BACKUP" 2>/dev/null || true
    cp -r "$HOME/atexovi-theme" "$BACKUP"
fi

# -----------------------------------------------------
# Remove custom configs
# -----------------------------------------------------
info "Removing user configurations..."
rm -rf "$HOME/.zshrc" \
       "$HOME/.zsh_history" \
       "$HOME/.oh-my-zsh" \
       "$HOME/.zlogin" \
       "$HOME/.zprofile" \
       "$HOME/.bashrc" \
       "$HOME/.profile" \
       "$HOME/.bash_profile" \
       "$HOME/.autostart" \
       "$HOME/.aliases" \
       "$HOME/atexovi-theme"

# -----------------------------------------------------
# Restore default bash.bashrc
# -----------------------------------------------------
info "Restoring default /etc/bash.bashrc..."
mkdir -p "$PREFIX/etc"

cat > "$PREFIX/etc/bash.bashrc" <<'BASHRC'
# =====================================================
# Termux Default bash.bashrc
# =====================================================
if [ "$TERM" != "dumb" ]; then
    PS1='~ $ '
fi

echo
echo "Welcome to Termux!"
echo
echo "Docs:       https://termux.dev/docs"
echo "Donate:     https://termux.dev/donate"
echo "Community:  https://termux.dev/community"
echo
echo "Commands:"
echo "  pkg search <query>"
echo "  pkg install <package>"
echo "  pkg upgrade"
echo
echo "Repos:"
echo "  pkg install root-repo"
echo "  pkg install x11-repo"
echo
echo "If repo broken: termux-change-repo"
echo "Report issues: https://termux.dev/issues"
BASHRC

# -----------------------------------------------------
# Reset ~/.termux to default
# -----------------------------------------------------
info "Resetting ~/.termux..."
rm -rf "$HOME/.termux"
mkdir -p "$HOME/.termux"

cat > "$HOME/.termux/termux.properties" <<'PROP'
# Default Termux Configuration
extra-keys = [ ['ESC','TAB','CTRL','ALT','UP','DOWN','LEFT','RIGHT'] ]
PROP

termux-reload-settings >/dev/null 2>&1 || true

# -----------------------------------------------------
# Reinstall essentials
# -----------------------------------------------------
info "Reinstalling essential Termux packages..."
pkg reinstall -y bash coreutils termux-tools >/dev/null 2>&1 || true

# -----------------------------------------------------
# Cleanup cache
# -----------------------------------------------------
info "Clearing cache..."
rm -rf "$PREFIX/var/cache"/* >/dev/null 2>&1 || true

# -----------------------------------------------------
# Final
# -----------------------------------------------------
success "Termux restored to default clean state."
echo -e "\e[1;32mDefault prompt:\e[0m ~ \$"
echo -e "\e[1;33mClose and reopen Termux.\e[0m"
RESTORE_EOF

chmod +x "$RESTORE_SH"
success "Restore module created successfully!"
