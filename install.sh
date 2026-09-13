#!/usr/bin/env bash
# ==============================================================================
# NixOS + Hyprland + Noctalia Desktop Shell Installer
# Repository: https://github.com/antonbenosapro/nixos-hyprland-noctalia
# ==============================================================================
set -e

REPO_URL="https://github.com/antonbenosapro/nixos-hyprland-noctalia.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

# ANSI formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Check if piped from curl/stdin (self-bootstrap)
if [ ! -f "$SCRIPT_DIR/dotfiles/hypr/hyprland.lua" ]; then
    echo -e "${BLUE}${BOLD}==> Bootstrapping installer from GitHub...${NC}"
    TMP_CLONE="/tmp/nixos-hyprland-noctalia-$(date +%s)"
    rm -rf "$TMP_CLONE"
    git clone "$REPO_URL" "$TMP_CLONE"
    exec bash "$TMP_CLONE/install.sh" "$@"
fi

banner() {
    cat << "EOF"
  _   _ _       ___  ____    _   _                 _                 _ 
 | \ | (_)_  __/ _ \/ ___|  | | | |_   _ _ __  _ __| | __ _ _ __   __| |
 |  \| | \ \/ / | | \___ \  | |_| | | | | '_ \| '__| |/ _` | '_ \ / _` |
 | |\  | |>  <| |_| |___) | |  _  | |_| | |_) | |  | | (_| | | | | (_| |
 |_| \_|_/_/\_\\___/|____/  |_| |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|
                                   |___/|_|                             
   + Noctalia Desktop Shell + Developer Suite
EOF
}

banner

# Parse CLI options
ASSUME_YES=0
DOTFILES_ONLY=0
NO_REBUILD=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        --dotfiles-only)
            DOTFILES_ONLY=1
            shift
            ;;
        --no-rebuild)
            NO_REBUILD=1
            shift
            ;;
        -h|--help)
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -y, --yes          Run unattended with default confirmations"
            echo "  --dotfiles-only    Install user dotfiles, themes, and nx-install only"
            echo "  --no-rebuild       Deploy files but skip nixos-rebuild switch"
            echo "  -h, --help         Display this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# 1. Verify NixOS
if [ ! -e "/etc/NIXOS" ] && ! command -v nixos-rebuild &>/dev/null; then
    echo -e "${RED}${BOLD}❌ Error: This installer is intended for NixOS systems.${NC}"
    echo -e "Could not find /etc/NIXOS or nixos-rebuild."
    exit 1
fi

# 2. Determine target user & home directory
if [ -n "$SUDO_USER" ]; then
    TARGET_USER="$SUDO_USER"
else
    TARGET_USER="$USER"
fi

if [ "$TARGET_USER" = "root" ]; then
    echo -e "${YELLOW}Warning: Running directly as root.${NC}"
    read -r -p "Enter username to configure dotfiles for [anton]: " INPUT_USER
    TARGET_USER="${INPUT_USER:-anton}"
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ] || [ ! -d "$TARGET_HOME" ]; then
    TARGET_HOME="/home/$TARGET_USER"
fi

echo -e "${CYAN}Target User:${NC} ${BOLD}$TARGET_USER${NC} (Home: $TARGET_HOME)"

# 3. Detect Virtualization vs Bare Metal
IS_VM=0
if command -v systemd-detect-virt &>/dev/null; then
    VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "none")
    if [ "$VIRT_TYPE" != "none" ]; then
        IS_VM=1
        echo -e "${CYAN}Environment:${NC} Virtual Machine detected (${VIRT_TYPE})"
    else
        echo -e "${CYAN}Environment:${NC} Bare-metal hardware detected"
    fi
fi

if [ "$ASSUME_YES" -ne 1 ]; then
    echo ""
    echo -e "This script will configure:"
    if [ "$DOTFILES_ONLY" -eq 0 ]; then
        echo -e "  • ${BOLD}/etc/nixos/configuration.nix${NC} (Hyprland, Noctalia, SDDM Catppuccin theme, dev tools)"
    fi
    echo -e "  • ${BOLD}Dotfiles${NC} (Hyprland Lua config, Noctalia shell, Ghostty, Kitty, Neovim, Tmux)"
    echo -e "  • ${BOLD}Theming${NC} (Bibata Modern cursors, GTK3/4, Catppuccin Mocha)"
    echo -e "  • ${BOLD}Wallpapers${NC} (15 curated wallpapers in ~/Pictures/Wallpapers)"
    echo -e "  • ${BOLD}nx-install${NC} (Instant package installer CLI in ~/.local/bin)"
    echo ""
    read -r -p "Proceed with installation? [Y/n]: " PROCEED
    if [[ "$PROCEED" =~ ^[nN]([oO])?$ ]]; then
        echo "Installation aborted."
        exit 0
    fi
fi

# 4. Deploy User Dotfiles & Wallpapers
echo -e "\n${BLUE}${BOLD}==> [1/3] Deploying dotfiles and themes...${NC}"

BACKUP_DIR="$TARGET_HOME/.config/backup-dotfiles-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_and_copy() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ]; then
        mv "$dest" "$BACKUP_DIR/" 2>/dev/null || true
    fi
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
    chown -R "$TARGET_USER:" "$dest" 2>/dev/null || true
}

# Deploy configs
backup_and_copy "$SCRIPT_DIR/dotfiles/hypr" "$TARGET_HOME/.config/hypr"
backup_and_copy "$SCRIPT_DIR/dotfiles/noctalia" "$TARGET_HOME/.config/noctalia"
backup_and_copy "$SCRIPT_DIR/dotfiles/kitty" "$TARGET_HOME/.config/kitty"
backup_and_copy "$SCRIPT_DIR/dotfiles/ghostty" "$TARGET_HOME/.config/ghostty"
backup_and_copy "$SCRIPT_DIR/dotfiles/nvim" "$TARGET_HOME/.config/nvim"
backup_and_copy "$SCRIPT_DIR/dotfiles/gtk/gtk-3.0" "$TARGET_HOME/.config/gtk-3.0"
backup_and_copy "$SCRIPT_DIR/dotfiles/gtk/gtk-4.0" "$TARGET_HOME/.config/gtk-4.0"
backup_and_copy "$SCRIPT_DIR/dotfiles/icons/default" "$TARGET_HOME/.icons/default"
backup_and_copy "$SCRIPT_DIR/dotfiles/tmux/.tmux.conf" "$TARGET_HOME/.tmux.conf"

# Replace username path in noctalia config.toml
sed -i "s|/home/[^/\"']*/Pictures/Wallpapers|$TARGET_HOME/Pictures/Wallpapers|g" "$TARGET_HOME/.config/noctalia/config.toml"

# Deploy Wallpapers
mkdir -p "$TARGET_HOME/Pictures/Wallpapers"
cp -n "$SCRIPT_DIR/wallpapers/"* "$TARGET_HOME/Pictures/Wallpapers/" 2>/dev/null || true
chown -R "$TARGET_USER:" "$TARGET_HOME/Pictures"

# Deploy nx-install
mkdir -p "$TARGET_HOME/.local/bin"
cp "$SCRIPT_DIR/bin/nx-install" "$TARGET_HOME/.local/bin/nx-install"
chmod +x "$TARGET_HOME/.local/bin/nx-install"
chown -R "$TARGET_USER:" "$TARGET_HOME/.local"

# Update bashrc
BASHRC="$TARGET_HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    if ! grep -q "\.local/bin" "$BASHRC"; then
        sed -i "1i export PATH=\"\$HOME/.local/bin:\$PATH\"\n" "$BASHRC"
    fi
    if ! grep -q "alias nrs" "$BASHRC"; then
        echo "alias nrs='sudo nixos-rebuild switch'" >> "$BASHRC"
    fi
    if ! grep -q "alias nx-install" "$BASHRC"; then
        echo "alias nx-install=\"\$HOME/.local/bin/nx-install\"" >> "$BASHRC"
    fi
else
    cp "$SCRIPT_DIR/dotfiles/bash/.bashrc" "$BASHRC"
    chown "$TARGET_USER:" "$BASHRC"
fi

echo -e "${GREEN}✓ Dotfiles and wallpapers deployed successfully.${NC}"
echo -e "  ${DIM}(Prior configs backed up to $BACKUP_DIR)${NC}"

# 5. Configure NixOS System Configuration
if [ "$DOTFILES_ONLY" -eq 0 ]; then
    echo -e "\n${BLUE}${BOLD}==> [2/3] Configuring /etc/nixos/configuration.nix...${NC}"

    TARGET_CONF="/etc/nixos/configuration.nix"
    CONF_BACKUP="/etc/nixos/configuration.nix.pre-noctalia.$(date +%Y%m%d_%H%M%S)"

    # Preserve existing bootloader from current configuration
    EXISTING_BOOTLOADER=""
    if [ -f "$TARGET_CONF" ]; then
        echo -e "${BLUE}Backing up existing configuration to ${CONF_BACKUP}...${NC}"
        sudo cp "$TARGET_CONF" "$CONF_BACKUP"
        
        # Extract existing boot.loader block
        EXISTING_BOOTLOADER=$(grep -E '^[[:space:]]*boot\.loader\.' "$TARGET_CONF" || true)
    fi

    # Generate merged configuration
    TMP_NIX=$(mktemp /tmp/nixos-conf.XXXXXX)

    # Read base template
    cat "$SCRIPT_DIR/nixos/configuration.nix" > "$TMP_NIX"

    # Adapt target username
    sed -i "s/users.users.\"anton\"/users.users.\"$TARGET_USER\"/g" "$TMP_NIX"
    sed -i "s/description = \"anton\"/description = \"$TARGET_USER\"/g" "$TMP_NIX"

    # If target already had a bootloader configured (e.g. systemd-boot on UEFI), preserve it!
    if [ -n "$EXISTING_BOOTLOADER" ]; then
        echo -e "${CYAN}Preserving target machine's bootloader configuration...${NC}"
        # Remove template grub lines
        sed -i '/boot\.loader\.grub/d' "$TMP_NIX"
        # Insert target bootloader configuration
        sed -i "/# Use the GRUB 2 boot loader./a \\$EXISTING_BOOTLOADER" "$TMP_NIX"
    fi

    # Adjust VM vs Bare Metal settings
    if [ "$IS_VM" -eq 0 ]; then
        echo -e "${CYAN}Optimizing configuration for bare-metal hardware...${NC}"
        # Disable software rendering overrides on physical GPUs
        sed -i '/WLR_RENDERER_ALLOW_SOFTWARE/d' "$TMP_NIX"
        sed -i '/LIBGL_ALWAYS_SOFTWARE/d' "$TMP_NIX"
        # Disable QEMU guest daemons
        sed -i '/services\.qemuGuest\.enable/d' "$TMP_NIX"
        sed -i '/services\.spice-vdagentd\.enable/d' "$TMP_NIX"
    fi

    # Validate syntax before applying
    if ! nix-instantiate --parse "$TMP_NIX" >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Generated configuration failed Nix syntax parsing.${NC}"
        rm -f "$TMP_NIX"
        exit 1
    fi

    sudo cp "$TMP_NIX" "$TARGET_CONF"
    rm -f "$TMP_NIX"
    echo -e "${GREEN}✓ /etc/nixos/configuration.nix updated and validated.${NC}"
fi

# 6. Rebuild & Switch
if [ "$DOTFILES_ONLY" -eq 0 ] && [ "$NO_REBUILD" -eq 0 ]; then
    echo -e "\n${BLUE}${BOLD}==> [3/3] Rebuilding NixOS system...${NC}"
    echo -e "${MAGENTA}${BOLD}Running: sudo nixos-rebuild switch${NC}\n"
    
    if sudo nixos-rebuild switch; then
        echo -e "\n${GREEN}${BOLD}======================================================${NC}"
        echo -e "${GREEN}${BOLD}🎉 Installation Complete!${NC}"
        echo -e "${GREEN}${BOLD}======================================================${NC}\n"
        echo -e "You can now log into ${BOLD}Hyprland${NC} via the Catppuccin SDDM login screen."
        echo ""
        echo -e "Quick shortcuts to try once logged in:"
        echo -e "  • ${CYAN}Super + Return${NC}        -> Ghostty terminal"
        echo -e "  • ${CYAN}Super + Shift + Return${NC}-> Kitty terminal"
        echo -e "  • ${CYAN}Super + Space${NC}         -> Noctalia App Launcher"
        echo -e "  • ${CYAN}Super + N${NC}             -> Noctalia Control Center"
        echo -e "  • ${CYAN}Super + W${NC}             -> Random Wallpaper transition"
        echo -e "  • ${CYAN}nx-install <pkg>${NC}      -> Search and install packages"
        echo ""
    else
        echo -e "\n${RED}❌ System rebuild failed.${NC}"
        if [ -n "$CONF_BACKUP" ] && [ -f "$CONF_BACKUP" ]; then
            read -r -p "Restore previous configuration.nix backup? [Y/n]: " REVERT
            if [[ ! "$REVERT" =~ ^[nN]([oO])?$ ]]; then
                sudo cp "$CONF_BACKUP" "/etc/nixos/configuration.nix"
                sudo nixos-rebuild switch
                echo "Restored previous configuration."
            fi
        fi
        exit 1
    fi
else
    echo -e "\n${GREEN}${BOLD}======================================================${NC}"
    echo -e "${GREEN}${BOLD}🎉 Setup files deployed!${NC}"
    echo -e "${GREEN}${BOLD}======================================================${NC}\n"
    echo -e "To apply system changes at any time, run: ${BOLD}nrs${NC} or ${BOLD}sudo nixos-rebuild switch${NC}"
fi
