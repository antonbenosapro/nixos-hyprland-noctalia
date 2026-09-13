# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  environment.sessionVariables = {
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    LIBGL_ALWAYS_SOFTWARE = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    st
    dmenu
    neovim 
    feh
    firefox
    slstatus
    ghostty
    lf
    pcmanfm
    kitty
    wofi
    quickshell
    noctalia
    nerd-fonts.jetbrains-mono
    playerctl
    brightnessctl
    wireplumber
    libnotify
    tmux
    btop
    ripgrep
    fd
    fzf
    jq
    wget
    tree
    unzip
    wl-clipboard
    fastfetch
    grim
    slurp
    bibata-cursors
    spotify
    cliamp
    yazi
    catppuccin-cursors.mochaDark
    (catppuccin-sddm.override {
      flavor = "mocha";
      font = "JetBrainsMono Nerd Font";
    })
    sddm-astronaut
    bat
    libreoffice
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs.hyprland.enable = true;

  networking.hostName = "anton-nix"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_PH.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fil_PH";
    LC_IDENTIFICATION = "fil_PH";
    LC_MEASUREMENT = "fil_PH";
    LC_MONETARY = "fil_PH";
    LC_NAME = "fil_PH";
    LC_NUMERIC = "fil_PH";
    LC_PAPER = "fil_PH";
    LC_TELEPHONE = "fil_PH";
    LC_TIME = "fil_PH";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ph";
    variant = ""; 
  };
  services.xserver.enable = true;
  services.xserver.windowManager.dwm.enable = true;

  # SDDM Display Manager & Theme
  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha-mauve";
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtmultimedia
      qtvirtualkeyboard
    ];
  };

  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  services.openssh.enable = true;
  services.upower.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  security.sudo.wheelNeedsPassword = false;

  users.users."anton" = {
    isNormalUser = true;
    description = "anton";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
