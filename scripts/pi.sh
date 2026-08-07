#!/usr/bin/env bash
# Pi local 0.80+ — FFF override + lean tool surface for lower prefix tokens.
set -euo pipefail

PI_AGENT="${PI_AGENT:-$HOME/.pi/agent}"
PI_BIN="$PI_AGENT/node_modules/.bin/pi"

# pi-cursor-sdk reads CURSOR_API_KEY at process start and on each Cursor turn.
# shellcheck disable=SC1091
source "$HOME/Projects/dotfiles/scripts/pi-cursor-env.sh"

# Belt-and-suspenders: hide tools from extensions we keep disabled (see extensions-disabled/).
PI_EXCLUDE_TOOLS="${PI_EXCLUDE_TOOLS:-fd,rg,fffind,ffgrep,crawl,scrape,search,workflow,subagent_spawn,subagent_wait,subagent_cancel,subagent_check,subagent_list,cursor_ask_question}"

export PI_FFF_MODE="${PI_FFF_MODE:-override}"

# --exclude-tools before a subcommand breaks its flags (e.g. update --extensions).
pi_cli_subcmd="${1-}"
case "$pi_cli_subcmd" in
  install|remove|uninstall|update|list|config)
    exec "$PI_BIN" "$@"
    ;;
esac

exec "$PI_BIN" --exclude-tools "$PI_EXCLUDE_TOOLS" "$@"
