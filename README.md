# NixOS + Hyprland + Noctalia Desktop Shell

[![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?logo=nixos&logoColor=white)](https://nixos.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-0.55+-00c8ff?logo=archlinux&logoColor=white)](https://hyprland.org)
[![Theme](https://img.shields.io/badge/Theme-Catppuccin%20Mocha-fab387)](https://github.com/catppuccin/catppuccin)
[![Shell](https://img.shields.io/badge/Shell-Noctalia%205.0.1-b4befe)](https://github.com/noctalia-dev/noctalia)

A turnkey, reproducible, and beautifully themed developer workstation setup for **NixOS**. Combines **Hyprland** (native Lua engine), the **Noctalia** C++ Wayland desktop shell, **Catppuccin Mocha** theming, **Bibata** cursors, and an audited developer toolchain.

---

## ⚡ 1-Line Quickstart

To install this setup on any fresh NixOS machine:

```bash
curl -sSL https://raw.githubusercontent.com/antonbenosapro/nixos-hyprland-noctalia/main/install.sh | bash
```

Or clone and inspect before running:

```bash
git clone https://github.com/antonbenosapro/nixos-hyprland-noctalia.git
cd nixos-hyprland-noctalia
./install.sh
```

---

## 🌟 What's Included

- **Compositor:** Hyprland 0.55+ configured with native Lua (`hyprland.lua`), 0 keybinding conflicts, and smooth animations.
- **Desktop Shell:** Noctalia 5.0.1 (Top bar panel, workspace switcher, system tray, control center, and notification center).
- **Display Manager:** SDDM with Catppuccin Mocha Mauve greeter (`catppuccin-sddm`).
- **Theming & Cursors:** Bibata Modern Classic (24px) configured across Hyprland, GTK3, GTK4, X11, and GNOME schemas.
- **Wallpapers:** Curated collection of 15 high-res Catppuccin & NixOS wallpapers with instant animated switching (`Super + W`).
- **Developer Suite:**
  - **Terminals:** Ghostty & Kitty pre-configured with Catppuccin Mocha palettes and JetBrains Mono Nerd Font.
  - **Editor:** Neovim (`~/.config/nvim/init.lua`) with Wayland clipboard integration.
  - **Multiplexer:** Tmux (`~/.tmux.conf`) with Vim navigation and `Ctrl-a` prefix.
  - **CLI Tools:** `ripgrep`, `fd`, `fzf`, `jq`, `fastfetch`, `btop`, `yazi`, `grim`, `slurp`.
- **Package Automation (`nx-install`):** 1-step package search, automatic Nix evaluation, syntax-checked insertion into `configuration.nix`, and system rebuild (`nrs`).

---

## ⌨️ Keybindings Cheatsheet

### Applications & Shell Triggers

| Shortcut | Action | Destination |
|---|---|---|
| <kbd>Super</kbd> + <kbd>Return</kbd> | Launch Primary Terminal | **Ghostty** |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Return</kbd> | Launch Secondary Terminal | **Kitty** |
| <kbd>Super</kbd> + <kbd>Space</kbd> or <kbd>Super</kbd> + <kbd>D</kbd> | Toggle App Launcher | **Noctalia Launcher** |
| <kbd>Super</kbd> + <kbd>N</kbd> | Toggle Control Center | **Noctalia Control Center** |
| <kbd>Super</kbd> + <kbd>W</kbd> | Random Wallpaper Switch | **Noctalia Wallpaper Manager** |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>L</kbd> | Lock Screen | **Noctalia Lockscreen** |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd> | Lock Screen (Alternate) | **Noctalia Lockscreen** |
| <kbd>Print</kbd> | Screenshot (Fullscreen) | `grim` to `~/Pictures/Screenshots/` |
| <kbd>Shift</kbd> + <kbd>Print</kbd> | Screenshot (Region) | `grim -g "$(slurp)"` |

### Window Management & Focus

| Shortcut | Action |
|---|---|
| <kbd>Super</kbd> + <kbd>Q</kbd> | Close / Kill focused window |
| <kbd>Super</kbd> + <kbd>F</kbd> | Toggle Fullscreen |
| <kbd>Super</kbd> + <kbd>V</kbd> | Toggle Floating mode |
| <kbd>Super</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Focus Left / Down / Up / Right |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Move window Left / Down / Up / Right |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Resize window (Vim directions) |
| <kbd>Super</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Switch to Workspace 1 to 9 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Move window to Workspace 1 to 9 |

---

## ⚡ `nx-install`: 1-Step Package Manager

Add any package to your NixOS system without manually editing configuration files:

```bash
# Search and install interactively
nx-install vlc

# Automatic mode (auto-selects best match and switches)
nx-install -y htop

# Search-only mode (view package descriptions and versions)
nx-install --search discord
```

### What `nx-install` does:
1. Searches the official Nix repository instantly via Elasticsearch API.
2. Checks if the package is already listed in `/etc/nixos/configuration.nix`.
3. Validates the attribute locally with `builtins.tryEval (pkgs.<pkg>)`.
4. Creates a timestamped backup of `/etc/nixos/configuration.nix`.
5. Inserts the package into `environment.systemPackages` and runs `nix-instantiate --parse` to prevent syntax corruption.
6. Rebuilds the system with `sudo nixos-rebuild switch`.

---

## 📁 Repository Structure

```
.
├── install.sh                  # All-in-one automated installer & updater
├── README.md                   # Project documentation & quickstart
├── .gitignore
├── bin/
│   └── nx-install              # Smart package search & installation CLI
├── dotfiles/
│   ├── hypr/
│   │   └── hyprland.lua        # Hyprland 0.55+ Lua configuration
│   ├── noctalia/
│   │   └── config.toml         # Noctalia shell settings & widgets
│   ├── kitty/
│   │   └── kitty.conf          # Kitty terminal profile
│   ├── ghostty/
│   │   └── config              # Ghostty terminal profile
│   ├── nvim/
│   │   └── init.lua            # Neovim Lua config & clipboard integration
│   ├── tmux/
│   │   └── .tmux.conf          # Tmux config with Ctrl-a & Vim bindings
│   ├── bash/
│   │   └── .bashrc             # Shell environment & aliases
│   └── gtk/                    # GTK3/4 themes and cursor settings
├── nixos/
│   └── configuration.nix       # Base declarative system configuration
├── wallpapers/                 # 15 Catppuccin & NixOS high-resolution wallpapers
└── docs/
    └── nixos-hyprland-noctalia-guide.md
```

---

## 🛠️ Installer Options

The `install.sh` script supports multiple flags for flexibility:

```bash
# Run unattended with default confirmations:
./install.sh --yes

# Deploy dotfiles, themes, wallpapers, and nx-install ONLY (without touching /etc/nixos/):
./install.sh --dotfiles-only

# Deploy all files without rebuilding immediately:
./install.sh --no-rebuild
```

---

## 🛡️ Safety & Rollbacks

- **Safety Backups:** The installer automatically backs up existing dotfiles (`~/.config/backup-dotfiles-<timestamp>`) and existing NixOS configurations (`/etc/nixos/configuration.nix.pre-noctalia.<timestamp>`).
- **Preserves Target Hardware & Bootloader:** Automatically detects if the destination machine already has a bootloader (e.g. `systemd-boot` or `grub`) and preserves it, while keeping `hardware-configuration.nix` untouched.
- **One-Command Rollback:** If you ever need to revert a system build:
  ```bash
  sudo nixos-rebuild switch --rollback
  ```

---

## 👤 Author

Maintained by **Anton Benosa** ([@antonbenosapro](https://github.com/antonbenosapro)).
