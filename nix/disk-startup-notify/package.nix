{
  lib,
  pkgs,
  lowSpaceThresholdGb ? 15,
  mountPoint ? "/",
  dunstWaitSeconds ? 3,
}:

let
  inherit (pkgs) writeShellApplication coreutils findutils nix systemd libnotify dunst rofi gawk;

  diskCleanupRoot = writeShellApplication {
    name = "disk-cleanup-root";
    runtimeInputs = [
      coreutils
      nix
      systemd
    ];
    text = builtins.readFile ./src/disk-cleanup-root.sh;
  };

  diskCleanup = writeShellApplication {
    name = "disk-cleanup";
    runtimeInputs = [
      coreutils
      findutils
      gawk
      libnotify
      dunst
      diskCleanupRoot
    ];
    text =
      let
        base = builtins.readFile ./src/disk-cleanup.sh;
      in
      ''
        export DISK_CLEANUP_MOUNT="${mountPoint}"
        export DISK_CLEANUP_ROOT="${diskCleanupRoot}/bin/disk-cleanup-root"
        ${base}
      '';
  };

  diskStartupNotify = writeShellApplication {
    name = "disk-startup-notify";
    runtimeInputs = [
      coreutils
      dunst
      libnotify
      rofi
      diskCleanup
    ];
    text = ''
      export DISK_STARTUP_NOTIFY_THRESHOLD_GB="${toString lowSpaceThresholdGb}"
      export DISK_STARTUP_NOTIFY_MOUNT="${mountPoint}"
      export DISK_STARTUP_NOTIFY_DUNST_WAIT="${toString dunstWaitSeconds}"
      export DISK_CLEANUP="${diskCleanup}/bin/disk-cleanup"
      ${builtins.readFile ./src/disk-startup-notify.sh}
    '';
  };
in
{
  inherit diskCleanupRoot diskCleanup diskStartupNotify;
}
