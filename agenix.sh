#!/nix/store/1xhds5s320nfp2022yjah1h7dpv8qqns-bash-5.2p32/bin/bash
set -euo pipefail

function die() { echo "[1;31merror:[m $*" >&2; exit 1; }
function show_help() {
  echo 'Usage: agenix <OPTIONS> [COMMAND]'
  echo "Edit, generate or rekey secrets for agenix."
  echo "Add help or --help to a subcommand to view a command specific help."
  echo ""
  echo 'COMMANDS:'
  echo '  rekey                   Re-encrypts secrets for hosts that require them.'
  echo '  edit                    Create/edit age secret files with $EDITOR and your master identity'
  echo '  generate                Automatically generates secrets that have generators'
  echo ""
  echo 'OPTIONS:'
  echo '  --show-trace            Show the trace for agenix-rekey.  This must be provided before the'
  echo '                            subcommand or it will be provided to the subcommand.'
  echo '  --extra-flake-params    Extra flake parameters to pass to the "nix run" invocation, such as'
  echo '                            "\?submodules=1" to enable submodule support.'
}

USER_GIT_TOPLEVEL=$(realpath -e "$(git rev-parse --show-toplevel 2>/dev/null || pwd)") \
  || die "Could not determine current working directory. Something went very wrong."
USER_FLAKE_DIR=$(realpath -e "$(pwd)") \
  || die "Could not determine current working directory. Something went very wrong."

# Search from $(pwd) upwards to $USER_GIT_TOPLEVEL until we find a flake.nix
while [[ ! -e "$USER_FLAKE_DIR/flake.nix" ]] && [[ "$USER_FLAKE_DIR" != "$USER_GIT_TOPLEVEL" ]] && [[ "$USER_FLAKE_DIR" != "/" ]]; do
  USER_FLAKE_DIR="$(dirname "$USER_FLAKE_DIR")"
done

[[ -e "$USER_FLAKE_DIR/flake.nix" ]] \
  || die "Could not determine location of your project's flake.nix. Please run this at or below your main directory containing the flake.nix."
cd "$USER_FLAKE_DIR"

[[ $# -gt 0 ]] || {
  show_help
  exit 1
}

APP=""
SHOW_TRACE_ARG=""
FLAKE_PARAMS=""
# Various Bash versions treat empty arrays as unset, which then trigger
# unbound variable errors.
PASS_THRU_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    "help"|"--help"|"-help"|"-h")
      if [[ "$APP" == "" ]]; then
        show_help
        exit 1
      else
        PASS_THRU_ARGS+=("$1")
        shift
      fi
      ;;
    "--show-trace")
      # It is potentially desirable to use --show-trace in the subcommand as
      # well as this command.  To do so, the --show-trace argument must be
      # provided before (agenix) or after (subcommand) to indicate which one
      # is to be used.  We account for this here.
      if [[ "$APP" == "" ]]; then
        SHOW_TRACE_ARG='--show-trace'
      else
        PASS_THRU_ARGS+=('--show-trace')
      fi
      shift
      ;;
    "--extra-flake-params")
      if [[ "$APP" == "" ]]; then
        FLAKE_PARAMS="$2"
      fi
      shift
      ;;
    edit|generate|rekey)
      APP="$1"
      shift
      ;;
    *)
      PASS_THRU_ARGS+=("$1")
      shift
      ;;
  esac
done
if [[ "$APP" == "" ]]; then
  show_help
  exit 1
fi
echo "Collecting information about hosts. This may take a while..."
exec nix run $SHOW_TRACE_ARG \
  ."${FLAKE_PARAMS}"#agenix-rekey.'x86_64-linux'."$APP" \
   -- "${PASS_THRU_ARGS[@]}"

