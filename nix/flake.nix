{
  description = "yuuki NixOS configuration (bashbunni-style + Ghostty + Herdr)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    herdr.url = "github:ogulcancelik/herdr/v0.8.0";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    custom-packages.url = "github:Rishabh5321/custom-packages-flake";
    disk-startup-notify.url = "path:./disk-startup-notify";
  };

  outputs =
    { self, nixpkgs, herdr, emacs-overlay, ... }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          inputs.disk-startup-notify.nixosModules.default
          {
            nixpkgs.overlays = [
              herdr.overlays.default
              emacs-overlay.overlay
              (final: prev: {
                cursor-desktop = final.callPackage ./packages/cursor-desktop.nix { };
              })
            ];
          }
        ];
      };
    };
}
