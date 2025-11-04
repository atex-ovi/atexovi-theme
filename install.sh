#!/usr/bin/env bash
clear
set -euo pipefail

export BASE="$HOME/atexovi-theme"
INSTALLER_DIR="$BASE/installer"
SHARED_DIR="$BASE/shared"

bash "$INSTALLER_DIR/env/i1-env.sh"
bash "$INSTALLER_DIR/core/i2-core.sh"
bash "$INSTALLER_DIR/extra/i3-extra.sh"
bash "$INSTALLER_DIR/plugins/i4-plugins.sh"
bash "$INSTALLER_DIR/theme/i5-theme.sh"
bash "$INSTALLER_DIR/shell/i6-shell.sh"
bash "$INSTALLER_DIR/restore/i7-restore.sh"
bash "$INSTALLER_DIR/final/i8-final.sh"