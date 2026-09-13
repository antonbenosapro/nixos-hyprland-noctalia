# NixOS VM (Hyprland + Noctalia) Developer Guide

A complete guide for administering, customizing, and developing within the **NixOS 26.05 (Scallop)** virtual machine environment featuring **Hyprland**, the **Noctalia Desktop Shell**, and a curated developer toolchain.

---

## 1. System Overview & Architecture

The NixOS development environment runs as an isolated, hardware-accelerated QEMU/KVM virtual machine hosted on your primary Omarchy workstation.

```
┌────────────────────────────────────────────────────────┐
│             Omarchy Workstation (Host)                 │
│  IP: 192.168.122.1 (virbr0)                            │
│  SSH Key: ~/.ssh/ledgerq_devbox                        │
└───────────────────────────┬────────────────────────────┘
                            │ QEMU/KVM Virtual Network
┌───────────────────────────▼────────────────────────────┐
│             NixOS VM: `anton-nix` (Guest)              │
│  IP: 192.168.122.195                                   │
│  User: anton | Pass: grillme123                        │
│  ────────────────────────────────────────────────────  │
│  • NixOS: 26.05 (Scallop)                              │
│  • Window Manager: Hyprland (0.55+ with Lua config)    │
│  • Desktop Shell: Noctalia 5.0.1 (Wayland C++ shell)   │
│  • Display Manager: SDDM (Catppuccin Mocha Mauve)      │
│  • Theme & Cursor: Catppuccin Dark + Bibata Modern     │
└────────────────────────────────────────────────────────┘
```

### Access Methods

- **Headless SSH Access (Host Terminal):**
  ```bash
  ssh -i ~/.ssh/ledgerq_devbox anton@192.168.122.195
  # Or via standard password:
  ssh anton@192.168.122.195
  ```
- **Wayland Graphical Desktop:**
  - Launch via `virt-manager` or `virt-viewer -c qemu:///system anton-nix`
  - Login via the SDDM Catppuccin greeter.

---

## 2. NixOS Configuration & Declarative Workflow

NixOS is fully declarative. Unlike traditional Linux distributions where software is installed imperatively into `/usr/bin`, all system packages, services, and system daemons are defined in configuration files and compiled into immutable closures in `/nix/store/`.

### Core Configuration Files

| Path | Purpose |
|---|---|
| `/etc/nixos/configuration.nix` | Primary system-level configuration (services, users, packages, SDDM, Hyprland). |
| `/etc/nixos/hardware-configuration.nix` | Auto-generated disk partitions, filesystems, and kernel modules. |
| `~/.bashrc` | User environment, shell aliases, PATH additions. |
| `~/.config/hypr/hyprland.lua` | Hyprland compositor settings, bindings, and rules (Lua parser). |
| `~/.config/noctalia/config.toml` | Noctalia desktop bar, widgets, launcher, and control center. |

---

### Daily NixOS Rebuild Workflow

Whenever you modify `/etc/nixos/configuration.nix`, apply changes with:

```bash
# 1. Edit system configuration
sudo nvim /etc/nixos/configuration.nix

# 2. Rebuild and switch immediately (alias: nrs)
sudo nixos-rebuild switch

# Alternatively, test changes without adding a new bootloader entry:
sudo nixos-rebuild test
```

> [!TIP]
> A shell alias **`nrs`** is configured in `~/.bashrc`. Simply run `nrs` to trigger `sudo nixos-rebuild switch`.

---

### ⚡ Automated Package Installation: `nx-install`

You can search and install packages with a single command using `nx-install`:

```bash
# Interactive installation (searches repo, confirms, edits config, runs nrs)
nx-install vlc

# Automatic mode (auto-picks exact match and switches)
nx-install -y htop

# Search only (explore packages and descriptions without installing)
nx-install --search discord
```

**How `nx-install` works under the hood:**
1. **Repository Search:** Instant query against the official NixOS search index to verify attribute names, versions, and descriptions.
2. **Duplicate Detection:** Checks if the package is already configured in `/etc/nixos/configuration.nix`.
3. **Local Nix Evaluation:** Evaluates `pkgs.<name>` against local `<nixpkgs>` to ensure it will build without errors.
4. **Safe Configuration Edit:** Creates a timestamped backup of `/etc/nixos/configuration.nix`, inserts the package into `environment.systemPackages`, and verifies the Nix AST syntax using `nix-instantiate --parse`.
5. **Rebuild & Switch:** Automatically runs `sudo nixos-rebuild switch` (`nrs`). If the rebuild fails, it prompts to restore your previous configuration.

---

### Package Management

#### 1. Permanent System Packages (Manual Editing)
Add packages directly to the `environment.systemPackages` list inside `/etc/nixos/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  git
  tmux
  neovim
  ripgrep
  noctalia
  ghostty
  kitty
];
```
Then run `nrs`.

#### 2. Temporary / Ephemeral Packages (Ad-hoc)
Run any tool immediately without installing it permanently:
```bash
# Start a subshell with the tool available
nix-shell -p htop

# Run a single command directly
nix run nixpkgs#htop
```

#### 3. Generations & Instant Rollbacks
Every rebuild creates a numbered **generation**. If a build causes an issue, roll back instantly:

```bash
# List all generations
nixos-rebuild list-generations

# Roll back to the previous working generation
sudo nixos-rebuild switch --rollback

# Or roll back to a specific generation number (e.g. generation 42)
sudo nixos-rebuild switch --generation 42
```
Generations are also selectable directly from the systemd-boot / GRUB boot menu.

---

## 3. Desktop Shell: Noctalia

The VM uses **Noctalia** (v5.0.1), a modern C++ Wayland desktop shell providing a top panel, application launcher, notifications, wallpaper selector, and control center.

### Configuration (`~/.config/noctalia/config.toml`)
- **Top Bar:** Workspaces indicator, active window title, system tray, clock/calendar, audio/network status, control center toggle.
- **Launcher:** Quick search for installed applications with fuzzy filtering.
- **Wallpaper Manager:** Integrated folder monitoring pointing to `~/Pictures/Wallpapers/`.

### Noctalia IPC Commands
You can trigger any Noctalia module from keybindings, scripts, or the terminal using `noctalia msg`:

| Command | Action |
|---|---|
| `noctalia msg panel-toggle launcher` | Toggle the application launcher |
| `noctalia msg panel-toggle control-center` | Toggle the Control Center & Quick Settings |
| `noctalia msg wallpaper-random` | Switch to a random wallpaper from `~/Pictures/Wallpapers/` |
| `noctalia msg lockscreen-lock` | Lock the screen |
| `noctalia msg settings-toggle` | Open Noctalia settings UI |

---

## 4. Hyprland Keybindings Cheatsheet

The VM runs Hyprland with the **native Lua configuration engine** (`~/.config/hypr/hyprland.lua`). All keybindings have been audited for zero conflicts.

> **Legend:**  
> `<Super>` = Windows / Command key | `<Return>` = Enter key

### Applications & Shell Triggers

| Keybinding | Action | Target / Command |
|---|---|---|
| <kbd>Super</kbd> + <kbd>Return</kbd> | Launch Primary Terminal | **Ghostty** |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Return</kbd> | Launch Secondary Terminal | **Kitty** |
| <kbd>Super</kbd> + <kbd>Space</kbd> or <kbd>Super</kbd> + <kbd>D</kbd> | Toggle App Launcher | **Noctalia Launcher** |
| <kbd>Super</kbd> + <kbd>N</kbd> | Toggle Control Center | **Noctalia Control Center** |
| <kbd>Super</kbd> + <kbd>W</kbd> | Cycle Wallpaper | **Noctalia Random Wallpaper** |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>L</kbd> | Lock Screen | **Noctalia Lockscreen** |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd> | Lock Screen (Alternate) | **Noctalia Lockscreen** |
| <kbd>Print</kbd> | Screenshot (Fullscreen) | `grim ~/Pictures/Screenshots/...` |
| <kbd>Shift</kbd> + <kbd>Print</kbd> | Screenshot (Region Selection) | `grim -g "$(slurp)" ...` |

---

### Window Management & Focus

| Keybinding | Action |
|---|---|
| <kbd>Super</kbd> + <kbd>Q</kbd> | Close / Kill focused window |
| <kbd>Super</kbd> + <kbd>F</kbd> | Toggle Fullscreen |
| <kbd>Super</kbd> + <kbd>V</kbd> | Toggle Floating mode |
| <kbd>Super</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Focus Left / Down / Up / Right |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Move window Left / Down / Up / Right |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Resize window (Vim directions) |
| <kbd>Super</kbd> + Left Click + Drag | Move window (Floating) |
| <kbd>Super</kbd> + Right Click + Drag | Resize window (Floating) |

---

### Workspaces Navigation

| Keybinding | Action |
|---|---|
| <kbd>Super</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Switch to Workspace 1 to 9 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Move active window to Workspace 1 to 9 |
| <kbd>Super</kbd> + Mouse Scroll | Switch to next / previous workspace |

---

## 5. Developer Environment & Toolchain

### Pre-installed Developer Tools
- **Multiplexer:** `tmux` with Vim navigation and `Ctrl-a` prefix (`~/.tmux.conf`).
- **Editor:** `neovim` with Lua configuration (`~/.config/nvim/init.lua`) and Wayland clipboard synchronization (`wl-clipboard`).
- **Terminals:** `ghostty` and `kitty` pre-themed with Catppuccin Mocha.
- **Search & Navigation:** `ripgrep` (`rg`), `fd`, `fzf`, `jq`, `tree`.
- **System Monitoring:** `btop`, `fastfetch`.

### Helpful Shell Aliases (`~/.bashrc`)

| Alias | Command | Purpose |
|---|---|---|
| `nrs` | `sudo nixos-rebuild switch` | Apply NixOS configuration changes |
| `v` | `nvim` | Open Neovim |
| `g` | `git` | Git shortcut |
| `ll` | `ls -lah --color=auto` | Detailed file listing |
| `reboot` | `sudo reboot` | Reboot VM |
| `poweroff` | `sudo poweroff` | Shutdown VM |

---

## 6. Theming, Cursors & Wallpapers

### SDDM Display Manager
The login screen runs **SDDM** with the **Catppuccin Mocha Mauve** theme.
- Defined in `/etc/nixos/configuration.nix` under `services.displayManager.sddm.theme = "catppuccin-mocha-mauve"`.
- Alternative themes installed: `sddm-astronaut-theme`.

### Mouse Cursor
- Theme: **Bibata-Modern-Classic** (size: 24).
- Configured across:
  - Hyprland: `hl.opt.env = { "XCURSOR_THEME,Bibata-Modern-Classic", "XCURSOR_SIZE,24" }`
  - GTK3/GTK4: `~/.config/gtk-3.0/settings.ini` & `~/.config/gtk-4.0/settings.ini`
  - X11 Fallback: `~/.icons/default/index.theme`
  - GSettings / GNOME Schema: `org.gnome.desktop.interface cursor-theme`

### Wallpapers
A collection of 11 high-definition Catppuccin and NixOS wallpapers is stored in:
```
~/Pictures/Wallpapers/
```
- Click the wallpaper icon on the Noctalia top bar to select from a visual gallery.
- Or press <kbd>Super</kbd> + <kbd>W</kbd> for an instant random animated wallpaper transition.

---

## 7. System Maintenance & Troubleshooting

### Cleaning Old Generations (Disk Space Recovery)
Nix stores older package generations so you can roll back. To free up disk space:

```bash
# Delete all generations older than 7 days
sudo nix-collect-garbage --delete-older-than 7d

# Or delete all historical generations (except the active one)
sudo nix-collect-garbage -d

# Optimize Nix store (hardlink deduplication)
nix-store --optimize
```

### Restarting the Noctalia Desktop Shell
If you modify `~/.config/noctalia/config.toml` and want to reload or restart Noctalia manually:
```bash
killall noctalia
nohup noctalia >/dev/null 2>&1 &
```

### Hyprland Lua Configuration Notes
Hyprland on NixOS uses the native Lua engine (`hyprland.lua`). 
- When triggering native actions inside Lua, always use the `hl.dsp` namespace (e.g., `hl.dsp.window.move`, `hl.dsp.window.resize`, `hl.dsp.window.fullscreen`).
- Avoid passing raw shell strings through `hyprctl dispatch movewindow` as Lua will evaluate string arguments as Lua variables.

---

## 8. Summary Quick-Reference Card

| Task | Action |
|---|---|
| **Install App / Package** | `nx-install <package-name>` |
| **Search Package** | `nx-install --search <query>` |
| **Edit System Config** | `sudo nvim /etc/nixos/configuration.nix` |
| **Apply System Config** | `nrs` (or `sudo nixos-rebuild switch`) |
| **Rollback Config** | `sudo nixos-rebuild switch --rollback` |
| **Edit Hyprland** | `nvim ~/.config/hypr/hyprland.lua` |
| **Edit Noctalia** | `nvim ~/.config/noctalia/config.toml` |
| **Open Ghostty** | <kbd>Super</kbd> + <kbd>Return</kbd> |
| **Open Kitty** | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Return</kbd> |
| **Open App Launcher** | <kbd>Super</kbd> + <kbd>Space</kbd> |
| **Cycle Wallpaper** | <kbd>Super</kbd> + <kbd>W</kbd> |
| **Lock Screen** | <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>L</kbd> |
