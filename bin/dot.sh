#!/usr/bin/env bash

set -euo pipefail

source "$DOTFILES_PATH/scripts/core/_main.sh"

##? Execute all scripts inside this dotfiles. Inspired by denisidoro/dotfiles.
#?? 1.0.0
##?
##? Usage:
##?    dot
##?    dot <context>
##?    dot <context> <cmd> [<args>...]

list_command_paths() {
  find "$DOTFILES_PATH/scripts" -maxdepth 2 -perm +111 -type f |
    grep -v core |
    sort
}

fzf_prompt() {
  local paths="$1"

  match="$(echo "$paths" |
    xargs -I % sh -c 'echo "$(basename $(dirname %)) $(basename %)"' |
    fzf --height 100% --preview 'dot $(echo {} | cut -d" " -f 1) $(echo {} | cut -d" " -f 2) -h | bat --style=numbers')"
  printf "$match "
  read args
  if coll::is_empty "$args"; then
    dot $match
  else
    dot $match "$args"
  fi
}

if args::has_no_args "$@"; then
  fzf_prompt "$(list_command_paths)"
elif args::total_is 1 "$@"; then
  fzf_prompt "$(list_command_paths | grep "/$1/")"
else
  context="$1"
  command="$2"

  shift 2
  export DOT_TRACE=${TRACE:-false}

  "${DOTFILES_PATH}/scripts/${context}/${command}" "$@"
fi