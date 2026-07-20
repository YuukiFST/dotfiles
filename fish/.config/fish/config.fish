# Paths
set -gx GOPATH $HOME/Developer/Go
set -gx NVIM_PATH (command -v nvim)
set -gx TERM xterm-256color
set -gx DOTFILES $HOME/Projects/dotfiles

set -gx EMACSDIR $HOME/.config/emacs
set -gx NIXPKGS_ALLOW_UNFREE 1

alias g++="g++ -std=c++17"

if test -f $HOME/.config/fish/env.fish
    source $HOME/.config/fish/env.fish
end

# Herdr (agent multiplexer, replaces tmux)
function ta
    herdr
end
function herd
    herdr
end

# Go
set -gx gomt "go mod tidy"
set -gx got "go test ./... -v"
set -gx gor "go run"
set -gx GOPROXY direct
set -gx GOSUMDB off
set -gx GOPRIVATE off

set -x GPG_TTY (tty)
set -x EDITOR nvim

# git
alias g="git"
alias gd="git diff"
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git pull"
alias latest="git describe --tags --abbrev=0"

# Custom prompt
set fish_greeting
set fish_prompt

function fish_prompt
    echo (set_color 87d7af)(date +%H:%M:%S) (set_color 87d7ff)(prompt_pwd) (set_color ffafff)(fish_git_prompt) (set_color ffafff)'→ '
end

function fish_greeting
end

if status is-interactive
    # Start Herdr automatically in interactive shells inside Ghostty
    if test "$TERM_PROGRAM" = ghostty; and not set -q HERDR_SESSION
        # Only auto-launch when not already inside herdr
        if not pgrep -u (id -u) -x herdr >/dev/null 2>&1
            # leave manual control; use `ta` or Mod+Return in i3
        end
    end
end

# SSH keys are loaded at i3 startup via scripts/start-ssh-agent.sh (gpg-agent SSH).
