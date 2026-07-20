# Cursor Desktop — AppImage oficial (https://cursor.com/download)
# Versão fixada; para atualizar: curl 'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable'
{ pkgs, lib, ... }:

let
  version = "3.12.10";
  commit = "24a12dbd9cabf48956ce5bb3dbd234e41385b3df";
in
pkgs.code-cursor-fhs.overrideAttrs (_old: {
  inherit version;
  src = pkgs.fetchurl {
    url = "https://downloads.cursor.com/production/${commit}/linux/x64/Cursor-${version}-x86_64.AppImage";
    hash = "sha256-WlRnU/zDWYl4qrwf85dwPrktquG/HD7sg1/d8kUOhA0=";
  };
  meta = (pkgs.code-cursor-fhs.meta or { }) // {
    description = "Cursor AI code editor (desktop, official AppImage)";
    homepage = "https://cursor.com";
  };
})
