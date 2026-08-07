{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./filesystems.nix
  ];

  # Menu de boot visível por alguns segundos; Linux continua sendo o padrão.
  # Windows usa outro ESP (/dev/sdb3), então não aparece automaticamente no systemd-boot.
  boot.loader = {
    timeout = 8;
    systemd-boot = {
      enable = true;
      # Keep a few generations while swapping GPU drivers (nouveau → nvidia).
      configurationLimit = 5;
      windows."11" = {
        title = "Windows";
        # ESP de 100MB em sdb3. Se não bootar, habilite edk2-uefi-shell e rode `map -c`.
        efiDeviceHandle = "HD1c3";
      };
    };
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.blueman.enable = true;

  time.timeZone = "America/Cuiaba";
  services.timesyncd.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.gtk.enable = true;
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        polybar
        i3status
        i3blocks
        rofi
      ];
    };
    xkb = {
      layout = "us";
      variant = "";
    };

    # teclado: comeca a repetir rapido ao segurar tecla
    autoRepeatDelay = 150;
    autoRepeatInterval = 10;
  };

  services.displayManager = {
    gdm.enable = false;
    defaultSession = "none+i3";
    autoLogin.enable = false;
    autoLogin.user = "yuuki";
  };

  services.desktopManager.gnome.enable = true;

  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
    };
  };

  programs.i3lock.enable = true;

  # Evita suspender sozinho ao ficar inativo (tela preta sem acordar)
  services.logind.settings.Login = {
    IdleAction = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  powerManagement.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-57-6.12.41"
    ];
    packageOverrides = pkgs: {
      polybar = pkgs.polybar.override { i3Support = true; };
    };
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.pam.services.sudo.u2fAuth = true;

  services.printing.enable = true;
  services.fwupd.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  users.users.yuuki = {
    isNormalUser = true;
    description = "yuuki";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    shell = pkgs.fish;
  };

  programs = {
    firefox.enable = true;
    fish.enable = true;
    tmux.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Pi 0.80+ em ~/.pi/agent — use ~/.local/bin/pi (wrapper) em vez do binário cru.
  programs.fish.interactiveShellInit = lib.mkAfter ''
    if test -x $HOME/.local/bin/pi
      fish_add_path -m $HOME/.local/bin
    end
  '';

  programs.bash.interactiveShellInit = lib.mkAfter ''
    # ~/.local/bin/pi → pi.sh (exporta CURSOR_API_KEY); node_modules/.bin/pi pula o wrapper.
    if [[ -x "$HOME/.local/bin/pi" ]]; then
      export PATH="$HOME/.local/bin:$PATH"
    fi
    if [[ -x "$HOME/Projects/dotfiles/scripts/pi-cursor-env.sh" ]]; then
      # shellcheck disable=SC1091
      source "$HOME/Projects/dotfiles/scripts/pi-cursor-env.sh"
    fi
  '';


  environment.variables = {
    TERMINAL = "ghostty";
    EDITOR = "nvim";
    DOTFILES = "/home/yuuki/Projects/dotfiles";
  };

  # bashbunni packages + ghostty/herdr/thorium (suas preferências)
  environment.systemPackages =
    with pkgs;
    [
      wget
      git
      python3
      jdk21
      vim
      neovim
      stow
      ripgrep
      fd
      discord
      vesktop
      chromium
      flameshot
      kitty
      ghostty
      picom
      herdr
      lazygit
      nodejs
      tmux
      fish
      emacs
      rofi
      yubikey-agent
      keepassxc
      xss-lock
      xautolock
      i3lock-color
      networkmanagerapplet
      playerctl
      pavucontrol
      lolcat
      xkill
      xclip
      coreutils
      element-web
      zed-editor
      bluez
      nautilus
      obsidian
      copyq
      libnotify
      inputs.custom-packages.packages.${pkgs.stdenv.hostPlatform.system}.thorium-avx2
      cursor-desktop
      emacsPackages.pbcopy
      emacsPackages.vterm
      libvterm
      libtool
      gcc
      glibc
      libcxx
      gdb
      cmake
      gnumake
      libgcc
      pam_u2f
      ispell
      gopls
      haskell-language-server
      jetbrains.rust-rover
      rustup
      go
      greetd
      tuigreet
      lxappearance
      lightdm
      autorandr
      fwupd
      kdePackages.kdenlive
      obs-studio
      mesa
      gum
      curl
      btop
      brightnessctl
      xdotool
      feh
      yaru-theme
      ntfs3g
    ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.terminess-ttf
      nerd-fonts.blex-mono
      nerd-fonts.fantasque-sans-mono
      ibm-plex
      openmoji-color
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "IBM Plex Sans" ];
        serif = [ "IBM Plex Serif" ];
        monospace = [ "Terminess Nerd Font" ];
        emoji = [ "OpenMoji Color" ];
      };
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # RTX 3060 (GA106): proprietary driver. nouveau GSP/DP-2 errors correlated with
  # hard black-screen hangs after idle (keyboard/mouse dead until reboot).
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true; # Ampere+: NixOS recommends open kernel modules on Turing+
    nvidiaSettings = true;
  };

  services.disk-startup-notify = {
    enable = true;
    cleanupUser = "yuuki";
    lowSpaceThresholdGb = 15;
    mountPoint = "/";
    dunstWaitSeconds = 3;
  };

  system.stateVersion = "26.05";
}
