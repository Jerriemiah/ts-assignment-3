#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# Optional: source helper scripts or define functions here

subcommand="${1:-}"

case "$subcommand" in
    system-info)
        # Run system-info logic
        # Either:
        #   - call a function: do_system_info
        #   - or: /app/system-info.sh
        "$SCRIPT_DIR/system-info.sh"
        ;;

    network)
        host="${2:-}"
        if [[ -z "$host" ]]; then
            echo "Error: network subcommand requires a host"
            exit 2
        fi
        # Run network-check logic for $host
        # Either via function or by calling /app/network-check.sh "$host"
        "$SCRIPT_DIR/network-check.sh" "$host"
        ;;

    disk)
        # Run disk-info logic
        # Either via function or by calling a disk script
        threshold=$2
        if [[ -z "$threshold" ]]; then
            echo "Error: disk subcommand requires a threshold"
            exit 2
        fi
        "$SCRIPT_DIR/disk-check.sh" "$threshold"
        ;;

    help|--help|-h)
        # Print usage information:
        # diagnostic system
        # diagnostic network <host>
        # diagnostic disk
        # diagnostic help
        cat "$SCRIPT_DIR/help.txt"
        ;;

    "")
        echo "Error: no subcommand provided"
        echo "Use 'diagnostic help' for usage."
        exit 2
        ;;

    *)
        echo "Error: unknown subcommand '$subcommand'"
        echo "Use 'diagnostic help' for usage."
        exit 2
        ;;
esac