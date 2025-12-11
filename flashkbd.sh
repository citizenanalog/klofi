#!/bin/bash
# flashkbd — flash corne (crkbd) with optional custom .hex file
# Usage: flashkbd                → uses default crkbd_rev1_klofi.hex
#        flashkbd -f foo.hex     → uses foo.hex (must be in ~/qmk_firmware)
#        flashkbd --f bar.hex    → same

set -euo pipefail   # safer script

# Default firmware
DEFAULT_HEX="crkbd_rev1_klofi.hex"
HEX_FILE="$DEFAULT_HEX"

# Parse optional argument
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--f)
            if [[ -n "${2:-}" ]]; then
                HEX_FILE="$2"
                shift 2
            else
                echo "Error: --f requires a filename" >&2
                exit 1
            fi
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [-f|--f filename.hex]" >&2
            exit 1
            ;;
    esac
done

# Go to the qmk directory
cd ~/qmk_firmware

# Sanity check
if [[ ! -f "$HEX_FILE" ]]; then
    echo "Error: $HEX_FILE not found in ~/qmk_firmware" >&2
    echo "Available .hex files:"
    ls -1 *.hex 2>/dev/null || echo "   (none)"
    exit 1
fi

echo "Flashing $HEX_FILE to crkbd..."

dfu-programmer atmega32u4 erase --force && \
dfu-programmer atmega32u4 flash "$HEX_FILE" && \
dfu-programmer atmega32u4 reset && \
echo -e "\nDone! Unplug and replug the keyboard — it will now run $HEX_FILE"
