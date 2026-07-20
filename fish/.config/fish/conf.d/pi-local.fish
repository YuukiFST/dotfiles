# Pi 0.80+ local — extensions do my-pi-setup; FFF override via pi.sh wrapper.
set -gx PI_FFF_MODE override

# pi-cursor-sdk needs CURSOR_API_KEY before pi starts (not only at fish login).
if not set -q CURSOR_API_KEY
    set -l _pi_cursor_key ($HOME/Projects/dotfiles/scripts/pi-cursor-env.sh --print)
    if test -n "$_pi_cursor_key"
        set -gx CURSOR_API_KEY $_pi_cursor_key
    end
end

function pi --description 'Pi coding agent (local 0.80+, lean tool surface)'
    set -l pi_wrapper $HOME/Projects/dotfiles/scripts/pi.sh
    if test -x $pi_wrapper
        $pi_wrapper $argv
    else
        set -l pi_bin $HOME/.pi/agent/node_modules/.bin/pi
        if test -x $pi_bin
            $pi_bin $argv
        else
            echo "pi local não instalado. Rode: ~/Projects/dotfiles/scripts/setup-pi.sh" >&2
            return 1
        end
    end
end
