#!/usr/bin/env bash

# i.sh
# One-shot installer for Termux UI "AtexOvi Theme"
# by Atex Ovi | Automatic Termux Customization

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

BASE="$HOME/atexovi-theme"
PLUGINS_DIR="$BASE/plugins"
TERMUX_DIR="$HOME/.termux"

#---------------------------
# Helper functions
#---------------------------
info(){ printf "\e[1;36m[*]\e[0m %s\n" "$1"; }
warn(){ printf "\e[1;33m[!]\e[0m %s\n" "$1"; }
err(){ printf "\e[1;31m[-]\e[0m %s\n" "$1"; }

#---------------------------
# Progress bar animation
#---------------------------
progress_bar() {
    local task="$1"
    local duration="${2:-2}"
    local width=40
    local char="█"

    local YELLOW=$'\033[1;33m'
    local GREEN=$'\033[1;32m'
    local RESET=$'\033[0m'

    local term_width=$(tput cols)

    for i in $(seq 0 100); do
        local step=$((i * width / 100))
        local bar=$(printf "%0.s$char" $(seq 1 $step))
        local space=$(printf "%0.s " $(seq 1 $((width - step))))
        local color="$YELLOW"
        (( i == 100 )) && color="$GREEN"

        local prog_text="[$bar$space] $i%"
        local pad=$((term_width - ${#task} - ${#prog_text} - 5))
        ((pad<0)) && pad=0
        local padding=$(printf "%*s" "$pad" "")

        printf "\r[*] %s%s%s%s" "$task" "$padding" "$color" "$prog_text$RESET"

        sleep "$(awk "BEGIN {print $duration/100}")"
    done
    echo
}
#--------------------------- 
# Install figlet quietly & display centered ASCII banner with color 
#--------------------------- 
FIGLET_LOG="$HOME/.cache/atexovi/figlet.log"
mkdir -p "$(dirname "$FIGLET_LOG")"
rm -f "$FIGLET_LOG"

clear
( pkg install -y figlet >>"$FIGLET_LOG" 2>&1 ) & pid=$!
echo -n "Checking system"
while kill -0 "$pid" 2>/dev/null; do
  for dot in {1..3}; do
    echo -n "."
    sleep 0.4
  done
  echo -ne "\rChecking system$(printf '.%.0s' $(seq 1 3))"
done
wait "$pid"
rc=$?
echo -e "\rChecking system: Done!      "

if [ $rc -eq 0 ]; then
  echo -e "\n[*] System ready.\n"
  clear
  RED="\033[1;31m"
  GREEN="\033[1;32m"
  YELLOW="\033[1;33m"
  BLUE="\033[1;34m"
  MAGENTA="\033[1;35m"
  CYAN="\033[1;36m"
  RESET="\033[0m"
  cols=$(tput cols)
  figlet -f standard "Atex - Ovi" | awk -v width="$cols" -v r="$RED" -v g="$GREEN" -v y="$YELLOW" -v b="$BLUE" -v m="$MAGENTA" -v c="$CYAN" -v reset="$RESET" '{ colors[1]=r; colors[2]=g; colors[3]=y; colors[4]=b; colors[5]=m; colors[6]=c; color=colors[(NR-1)%6+1]; len=length($0); pad=int((width-len)/2); printf "%s%*s%s%s\n", color, pad, "", $0, reset; }'
else
  echo -e "\033[1;33m[WARN] Installation failed. Check $FIGLET_LOG\033[0m"
fi
printf "\n\n"

#---------------------------
# Install base packages
#---------------------------
info "Preparing environment..."
progress_bar "Refreshing repositories" 2

if apt update -o Acquire::http::Timeout=10 -o Acquire::Retries=1 -qq >/dev/null 2>&1; then
    echo -e "\e[1;32m[✓]\e[0m Repositories refreshed successfully!"
    echo -e "\e[1;32m[✓]\e[0m All packages are up to date!"
else
    warn "Repository refresh failed — check your connection."
fi

info "Installing core packages..."
progress_bar "Installing core utilities" 3

if pkg install -y --no-upgrade bash coreutils curl git zsh termux-tools >/dev/null 2>&1; then
    echo -e "\e[1;32m[✓]\e[0m Core packages installed successfully!"
else
    warn "Failed to install core packages."
fi

#---------------------------
# Install extra utilities
#---------------------------
info "Installing extra utilities..."
progress_bar "Installing extra tools" 3

# Ensure Go installed
if ! command -v go >/dev/null 2>&1; then
    echo -e "\e[1;33m[!]\e[0m Go not found — installing..."
    if pkg install -y golang >/dev/null 2>&1; then
        echo -e "\e[1;32m[✓]\e[0m Go installed successfully."
    else
        warn "Failed to install Go. Please install manually."
    fi
else
    echo -e "\e[1;32m[✓]\e[0m Go already installed."
fi

# Clone or update logo-ls repo
LOGOLS_DIR="$HOME/tmp-logo-ls"
if [ -d "$LOGOLS_DIR" ]; then
    echo -e "\e[1;34m[*]\e[0m Updating existing logo-ls repo..."
    git -C "$LOGOLS_DIR" pull --quiet >/dev/null 2>&1 && \
    echo -e "\e[1;32m[✓]\e[0m logo-ls repository updated!" || \
    warn "Failed to update logo-ls repository."
else
    echo -e "\e[1;34m[*]\e[0m Cloning logo-ls repository..."
    git clone --quiet https://github.com/Yash-Handa/logo-ls.git "$LOGOLS_DIR" >/dev/null 2>&1 && \
    echo -e "\e[1;32m[✓]\e[0m logo-ls repository cloned successfully!" || \
    warn "Failed to clone logo-ls repo."
fi

# Build logo-ls binary
cd "$LOGOLS_DIR" || exit 1
echo -e "\e[1;34m[*]\e[0m Building logo-ls binary..."
if go build -o "$PREFIX/bin/logo-ls" >/dev/null 2>&1; then
    chmod +x "$PREFIX/bin/logo-ls"
    echo -e "\e[1;32m[✓]\e[0m logo-ls installed successfully!"
else
    warn "Build failed. Please check Go installation."
    exit 1
fi

# Add alias to Zsh
ZSHRC="$HOME/.zshrc"
grep -q "alias ls='logo-ls'" "$ZSHRC" 2>/dev/null || {
    echo -e "\e[1;34m[*]\e[0m Adding alias to Zsh..."
    {
        echo "alias ls='logo-ls'"
        echo "alias els='logo-ls'"
    } >> "$ZSHRC"
    echo -e "\e[1;32m[✓]\e[0m Aliases added to .zshrc!"
}

echo -e "\e[1;32m[✓]\e[0m Utilities installed successfully!"

#---------------------------
# Prepare directories
#---------------------------
info "Setting up directories..."
progress_bar "Creating directory structure" 1.5
mkdir -p "$BASE/scripts/toys" "$PLUGINS_DIR" "$TERMUX_DIR" >/dev/null 2>&1

#---------------------------
# Install Zsh Plugins
#---------------------------
info "Installing Zsh plugins..."
declare -A PLUGINS=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    [zsh-autocomplete]="https://github.com/marlonrichert/zsh-autocomplete.git"
    [bgnotify]="https://github.com/t413/zsh-background-notify.git"
    [zsh-fzf-history-search]="https://github.com/joshskidmore/zsh-fzf-history-search.git"
)

for plugin in "${!PLUGINS[@]}"; do
    dest="$PLUGINS_DIR/$plugin"
    if [ -d "$dest" ]; then
        info "Plugin $plugin already exists, skipping..."
    else
        progress_bar "Cloning $plugin" 2
        git clone --depth=1 "${PLUGINS[$plugin]}" "$dest" >/dev/null 2>&1 || warn "Failed $plugin"
    fi
done

#---------------------------
# Colors and termux.properties
#---------------------------
info "Writing colors.properties"
progress_bar "Applying color scheme" 1
cat > "$TERMUX_DIR/colors.properties" <<'EOF'
color0=#2f343f
color1=#fd6b85
color2=#63e0be
color3=#fed270
color4=#67d4f2
color5=#ff8167
color6=#63e0be
color7=#eeeeee
color8=#4f4f5b
color9=#fd6b85
color10=#63e0be
color11=#fed270
color12=#67d4f2
color13=#ff8167
color14=#63e0be
color15=#eeeeee
background=#2a2c3a
foreground=#eeeeee
cursor=#fd6b85
EOF

info "Writing termux.properties"
progress_bar "Applying terminal configuration" 1
cat > "$TERMUX_DIR/termux.properties" <<'EOF'
extra-keys = [ \
['F1','ESC','CTRL','ALT','TAB',{key: KEYBOARD, popup: DRAWER},'HOME','UP','END'], \
['DELETE','{}','()','[]','$','BACKSLASH','LEFT','DOWN','RIGHT'] \
]
allow-external-apps = true
terminal-cursor-blink-rate=600
EOF

#---------------------------
# Font installation
#---------------------------
info "Downloading Font..."
progress_bar "Installing custom font" 3
FONT_URL="https://raw.githubusercontent.com/atex-ovi/font-bold/main/font.ttf"

if curl -L --silent --show-error --fail -o "$TERMUX_DIR/font.ttf" "$FONT_URL"; then
    info "Font installed successfully!"
else
    warn "Failed to download font. Please manually place font.ttf in ~/.termux/"
fi

#---------------------------
# Banner, Zsh setup, Restore script
#---------------------------
progress_bar "Generating theme scripts" 2
RXFETCH_SH="$BASE/scripts/toys/atex-ovi.sh"
info "Creating banner script atex-ovi.sh"
cat > "$RXFETCH_SH" <<'EOF'
#!/usr/bin/env bash
# atex-ovi.sh — custom banner by Atex Ovi

magenta="\033[1;35m"
green="\033[1;32m"
white="\033[1;37m"
blue="\033[1;34m"
red="\033[1;31m"
black="\033[1;40;30m"
yellow="\033[1;33m"
cyan="\033[1;36m"
reset="\033[0m"
bgyellow="\033[1;43;33m"
bgwhite="\033[1;47;37m"

c0=${reset}; c1=${magenta}; c2=${green}; c3=${white}; c4=${blue}
c5=${red}; c6=${yellow}; c7=${cyan}; c8=${black}; c9=${bgyellow}; c10=${bgwhite}

getCodeName(){ codename="$(getprop ro.product.board)"; }
getClientBase(){ client_base="$(getprop ro.com.google.clientidbase)"; }
getModel(){ model="$(getprop ro.product.brand) $(getprop ro.product.model)"; }
getDistro(){ os="Android $(getprop ro.build.version.release)"; }
getKernel(){ kernel="$(uname -r)"; }
getDeviceStatus() {
    if command -v su >/dev/null 2>&1; then
        if su -c whoami >/dev/null 2>&1; then
            device_status="Rooted"
        else
            device_status="Non-Root"
        fi
    else
        device_status="Non-Root"
    fi
}
getShell(){ shell=$(ps -o comm= -p $$); }
getUptime(){ uptime="$(uptime --pretty | sed 's/up //')"; }
getMemoryUsage(){
    line=$(free --mega | grep Mem:)
    total=$(echo $line | awk '{print $2}')
    used=$(echo $line | awk '{print $3}')
    memory="${used}MB / ${total}MB"
}
getDiskUsage(){
    line=$(df -h /data | tail -1)
    size=$(echo $line | awk '{print $2}')
    used=$(echo $line | awk '{print $3}')
    avail=$(echo $line | awk '{print $4}')
    usep=$(echo $line | awk '{print $5}')
    storage="${used}B / ${size}B = ${avail}B (${usep})"
}

getCodeName; getClientBase; getModel; getDistro; getKernel
getDeviceStatus
getShell; getUptime; getMemoryUsage; getDiskUsage

echo -e "\n"
echo -e "  ┏━━━━━━━━━━━━━━━━━━━━━━┓"
echo -e "  ┃ ${c1}a${c2}t${c7}e${c4}x${c5}-${c6}o${c7}v${c1}i${c0}     ${c5}${c0}  ${c6}${c0}  ${c7}${c0} ┃  ${codename}${c5}@${c0}${client_base}"
echo -e "  ┣━━━━━━━━━━━━━━━━━━━━━━┫"
echo -e "  ┃                      ┃  ${c1}phone${c0}  ${model}"
echo -e "  ┃          ${c3}•${c8}${c3}•${c0}          ┃  ${c2}os${c0}     ${os}"
echo -e "  ┃          ${c8}${c0}${c9}oo${c0}${c8}|${c0}         ┃  ${c7}ker${c0}    ${kernel}"
echo -e "  ┃         ${c8}/${c0}${c10} ${c0}${c8}'\\'${c0}        ┃  ${c4}Device${c0} ${device_status}"
echo -e "  ┃        ${c9}(${c0}${c8}\\_;/${c0}${c9})${c0}        ┃  ${c5}sh${c0}     ${shell}"
echo -e "  ┃                      ┃  ${c6}up${c0}     ${uptime}"
echo -e "  ┃   Powered ${c1}by${c0} Linux   ┃  ${c1}ram${c0}    ${memory}"
echo -e "  ┃                      ┃  ${c2}disk${c0}   ${storage}"
echo -e "  ┗━━━━━━━━━━━━━━━━━━━━━━┛  ${c1}━━━${c2}━━━${c3}━━━${c4}━━━${c5}━━━${c6}━━━${c7}━━━"
echo -e "\n"
EOF
chmod +x "$RXFETCH_SH"

# ---------------------------
# ~/.zshrc — AtexOvi Theme
# ---------------------------

ZSHRC="$HOME/.zshrc"
cat > "$ZSHRC" <<'EOF'
# PATH & TERM
clear
export PATH="$PREFIX/bin:$HOME/.local/bin:$PATH"
export TERM=xterm-256color

# Enable Zsh Completion safely
if [ ! -z "${ZSH_VERSION-}" ]; then
    autoload -Uz compinit
    compinit
    zstyle ':completion:*' menu select
    bindkey '^I' expand-or-complete

    # FZF integration
    if command -v fzf >/dev/null 2>&1; then
        FZF_KEYBINDINGS="$PREFIX/share/doc/fzf/examples/key-bindings.zsh"
        [ -f "$FZF_KEYBINDINGS" ] && source "$FZF_KEYBINDINGS"
    fi

    # Plugins
    PLUGINS_DIR="$HOME/atexovi-theme/plugins"
    [ -d "$PLUGINS_DIR/zsh-autocomplete" ] && source "$PLUGINS_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
    for plugin in zsh-autosuggestions bgnotify zsh-fzf-history-search zsh-syntax-highlighting; do
        [ -d "$PLUGINS_DIR/$plugin" ] && source "$PLUGINS_DIR/$plugin/$plugin.zsh" 2>/dev/null || true
    done

    # Aliases
    alias c='clear'
    alias q='exit'
    alias sd='cd /sdcard'
    alias dl='cd /sdcard/Download'
    alias pacupg='pkg upgrade'
    alias pacupd='pkg update'
    alias neo='neofetch'

    # Modern ls alias
    if command -v els >/dev/null 2>&1; then
        alias ls='els'
        alias ll='els -l'
    else
        alias ls='ls -lh --color=auto'
        alias ll='ls -la --color=auto'
    fi

    # Prompt
    PROMPT='%F{white}   ❯_%f '
fi

# Banner (runs only when opening Zsh)
RXFETCH_SH="$HOME/atexovi-theme/scripts/toys/atex-ovi.sh"
[ -x "$RXFETCH_SH" ] && source "$RXFETCH_SH"
EOF

# ---------------------------
# Set Zsh as default shell safely
# ---------------------------
info "Setting Zsh as default shell..."
ZSH_PATH=$(command -v zsh || true)

if [ -n "$ZSH_PATH" ]; then
    # Pastikan ~/.zshrc ada
    [ -f "$HOME/.zshrc" ] || touch "$HOME/.zshrc"

    # Tambahkan alias ls jika belum ada
    grep -q "alias ls='logo-ls'" "$HOME/.zshrc" 2>/dev/null || {
        echo "alias ls='logo-ls'" >> "$HOME/.zshrc"
        echo "alias els='logo-ls'" >> "$HOME/.zshrc"
    }

    # Set Zsh di Termux otomatis via ~/.profile
    PROFILE="$HOME/.profile"
    grep -q "exec zsh" "$PROFILE" 2>/dev/null || echo "exec zsh" >> "$PROFILE"

    info "Your shell will switch to Zsh after restarting Termux."
fi

# ---------------------------
# Create restore script (r.sh)
# ---------------------------
RESTORE_SH="$HOME/r.sh"
info "Creating restore script..."

cat > "$RESTORE_SH" <<'RESTORE_EOF'
#!/usr/bin/env bash
# restore-termux-default.sh
# Restore Termux to original default clean state (English messages)

clear
set -euo pipefail

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${YELLOW}[!] Restoring Termux to default clean state...${RESET}"

# Ensure default shell is bash
export SHELL="$PREFIX/bin/bash"
if [ -x "$PREFIX/bin/bash" ]; then
    chsh -s "$PREFIX/bin/bash" >/dev/null 2>&1 || true
fi

# Remove all Zsh and custom startup configurations
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

# Restore default Termux bash.bashrc (always shows welcome message)
cat > "$PREFIX/etc/bash.bashrc" <<'BASHRC'
# /etc/bash.bashrc — Termux default (English)

if [ "$TERM" != "dumb" ]; then
    PS1='~ $ '
fi

# Always show welcome message every session
echo "Welcome to Termux!"
echo
echo "Docs:       https://termux.dev/docs"
echo "Donate:     https://termux.dev/donate"
echo "Community:  https://termux.dev/community"
echo
echo "Working with packages:"
echo "Search: pkg search <query>"
echo "Install: pkg install <package>"
echo "Upgrade: pkg upgrade"
echo
echo "Subscribing to additional repositories:"
echo "Root: pkg install root-repo"
echo "X11:  pkg install x11-repo"
echo
echo "For fixing any repository issues, try 'termux-change-repo' command."
echo "Report issues at https://termux.dev/issues"
BASHRC

# Reset .termux folder to default
rm -rf "$HOME/.termux"
mkdir -p "$HOME/.termux"

cat > "$HOME/.termux/termux.properties" <<'TERMUXPROP_EOF'
# Default Termux Configuration
extra-keys = [ ['ESC','TAB','CTRL','ALT','UP','DOWN','LEFT','RIGHT'] ]
TERMUXPROP_EOF

# Reload Termux settings silently
termux-reload-settings >/dev/null 2>&1 || true

# Reinstall essential Termux packages
echo -e "${YELLOW}[*] Reinstalling core packages (bash, coreutils, pkg, curl)...${RESET}"
pkg reinstall -y bash termux-tools coreutils >/dev/null 2>&1 || true

# Clear package cache
echo -e "${YELLOW}[*] Clearing package cache...${RESET}"
rm -rf "$PREFIX/var/cache"/* >/dev/null 2>&1 || true

# Final message
echo -e "\n${GREEN}[✓] Termux has been restored to its default state.${RESET}"
echo -e "${GREEN}Default prompt: ~ \$${RESET}"
echo -e "${GREEN}Please close and reopen Termux.${RESET}"
RESTORE_EOF

chmod +x "$RESTORE_SH"
info "Restore script r.sh created successfully!"

#---------------------------
# Final message with centered table
#---------------------------
printf "\n\n\n"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
GREEN="\033[1;32m"
RESET="\033[0m"

COL1=28
COL2=60
TABLE_WIDTH=$((COL1 + COL2 + 3)) # 3 = 1

crop() {
  local str="$1"
  local width="$2"
  printf '%-*.*s' "$width" "$width" "$str"
}

# Center table
print_center_table() {
  local term_width=$(tput cols 2>/dev/null || echo 80)
  local pad=$(( (term_width - TABLE_WIDTH)/2 ))
  (( pad < 0 )) && pad=0

  lines=(
    "┌$(printf '─%.0s' $(seq 1 $COL1))┬$(printf '─%.0s' $(seq 1 $COL2))┐"
    "│$(printf '%-*s' $COL1 " SECTION")│$(printf '%-*s' $COL2 " DESCRIPTION")│"
    "├$(printf '─%.0s' $(seq 1 $COL1))┼$(printf '─%.0s' $(seq 1 $COL2))┤"
    "│$(printf '%-*s' $COL1 " Theme Path")│$(printf '%-*s' $COL2 " $BASE")│"
    "│$(printf '%-*s' $COL1 " Restore Command")│$(printf '%-*s' $COL2 " bash r.sh")│"
    "│$(printf '%-*s' $COL1 " Apply Changes")│$(printf '%-*s' $COL2 " Close and reopen Termux")│"
    "└$(printf '─%.0s' $(seq 1 $COL1))┴$(printf '─%.0s' $(seq 1 $COL2))┘"
  )
  for line in "${lines[@]}"; do
    printf "%*s%s\n" "$pad" "" "$line"
  done
}

# Title
term_width=$(tput cols 2>/dev/null || echo 80)
title="WELCOME TO YOUR NEW ATEX-OVI THEME!"
pad=$(( (term_width - ${#title})/2 ))
printf "%*s${CYAN}%s${RESET}\n\n" "$pad" "" "$title"

# Cetak tabel
print_center_table

# Footer
footer1="Your Termux is ready with the new Atex-Ovi theme!"
footer2="Have fun customizing and exploring!"
pad=$(( (term_width - ${#footer1})/2 ))
printf "%*s${GREEN}%s${RESET}\n" "$pad" "" "$footer1"
pad=$(( (term_width - ${#footer2})/2 ))
printf "%*s${GREEN}%s${RESET}\n\n" "$pad" "" "$footer2"