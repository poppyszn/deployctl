#!/usr/bin/env bash

##############################################################################
# deployctl – modular deployment helper
##############################################################################

usage() {
  cat <<EOF
Usage: $0 --config <file> [--stop|--start] [--dry-run]

Options
  --config <file>   Config file to source (required)
  --stop            Only run the STOP_COMMAND
  --start           Only run the START_COMMAND
  --dry-run         Print the commands instead of executing them
EOF
  exit 1
}

# ---------- Robust getopt parsing ----------
PARSED=$(getopt -o '' \
        --long config:,stop,start,dry-run,help \
        -n "$0" -- "$@")
# If getopt had a parsing error, bail out.
[[ $? -ne 0 ]] && usage
eval set -- "$PARSED"

CONFIG_FILE=''
MODE='deploy'
DRY_RUN=false

while true; do
  case "$1" in
    --config) CONFIG_FILE="$2"; shift 2 ;;
    --stop)   MODE='stop'; shift ;;
    --start)  MODE='start'; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help)   usage ;;
    --) shift; break ;;   # end of option list
    *) echo "Unknown option $1"; usage ;;
  esac
done

# ---------- Validation ----------
if [[ -z "$CONFIG_FILE" ]]; then
  echo "[✗] Error: --config is required."
  usage
elif [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[✗] Error: Config file '$CONFIG_FILE' not found (cwd=$(pwd))."
  exit 1
fi

# ---------- Load the user’s config ----------
source "$CONFIG_FILE"

# ---------- Default values ----------
CHECK_INTERVAL=${CHECK_INTERVAL:-3}

# ---------- Helper functions ----------
check_ports() {
  for port in $PORTS_TO_CHECK; do
    if ! ss -ltn | awk '{print $4}' | grep -q ":$port\$"; then
      return 1
    fi
  done
  return 0
}

run_or_dry() {
  if $DRY_RUN; then
    echo "[dry-run] $*"
  else
    eval "$@"
  fi
}

##############################################################################
# --- Main Logic -------------------------------------------------------------
##############################################################################
echo "[*] Using config: $CONFIG_FILE"
$DRY_RUN && echo "[*] DRY-RUN mode enabled"

case "$MODE" in
  stop)
    echo "[*] Stopping application…"
    run_or_dry "$STOP_COMMAND"
    ;;
  start)
    echo "[*] Starting application…"
    run_or_dry "$START_COMMAND"
    ;;
  deploy)
    echo "[*] Deploy flow: stop → wait → start"

    echo "  → Stopping"
    run_or_dry "$STOP_COMMAND"

    echo "  → Waiting for required ports ($PORTS_TO_CHECK) to open…"
    until check_ports; do
      $DRY_RUN && { echo "    [dry-run] Skipping wait loop"; break; }
      sleep "$CHECK_INTERVAL"
    done

    echo "  → Starting"
    run_or_dry "$START_COMMAND"
    ;;
  *)
    echo "[✗] Internal error: unknown MODE $MODE" ; exit 1 ;;
esac
