# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] – 2025-11-04
### 🚀 Major Release – Stable & Modular
- Complete overhaul to a modular structure
- Installer refactored (`install.sh`, `restore.sh`)
- Theme setup split into `installer/`, `shared/`, `plugins/`, `themes/`
- Auto-installation of Zsh plugins:
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - zsh-autocomplete
  - bgnotify
  - zsh-fzf-history-search
- Custom banner, colors, termux.properties & fonts
- Animated progress bars during installation
- Restore script to revert Termux to default

## [1.0.0] – 2025-10-10
### ⚠️ Initial Release (Beta)
- Single-file installer (`i.sh`) for quick theme setup
- Basic custom Zsh prompt and color palette
- Included logo-ls integration
- Auto-installation of essential Termux utilities
- **Beta** release, intended for testing & preview
