# Discos compartilhados com Windows (dual-boot)
{ config, lib, ... }:

{
  boot.supportedFilesystems = [ "ntfs" "ntfs3" ];

  fileSystems."/mnt/Others" = {
    device = "/dev/disk/by-label/Others";
    fsType = "ntfs3";
    options = [
      "uid=1000"
      "gid=100"
      "umask=022"
      "nofail"
      # Windows Fast Startup deixa o volume "dirty" — sem isso o mount falha
      "force"
    ];
  };
}
