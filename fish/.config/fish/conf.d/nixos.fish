# NixOS rebuild a partir dos dotfiles (rode no Ghostty/tty, não no terminal do Cursor).
function nixr --description 'NixOS rebuild from dotfiles (switch)'
    $HOME/Projects/dotfiles/scripts/nixos-rebuild.sh $argv
end

function nixrb --description 'NixOS rebuild build-only (no switch)'
    $HOME/Projects/dotfiles/scripts/nixos-rebuild.sh --build $argv
end
