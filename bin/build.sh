#!/usr/bin/env bash

#### crowsnest - A webcam Service for multiple Cams and Stream Services.
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2021 - till today
#### https://github.com/mainsail-crew/crowsnest
####
#### This File is distributed under GPLv3
####

# shellcheck enable=require-variable-braces

### Disable SC2317 due Trap usage
# shellcheck disable=SC2317

# Exit on errors
set -Ee

# Debug
# set -x

# Global vars

CLONE_FLAGS="--depth=1 --single-branch"
USTREAMER_PATH="ustreamer"
USTREAMER_REPO="https://github.com/pikvm/ustreamer.git"
USTREAMER_BRANCH="master"
CSTREAMER_PATH="camera-streamer"
CSTREAMER_REPO="https://github.com/ayufan-research/camera-streamer.git"
CSTREAMER_BRANCH="develop"
ARCH="$(uname -m)"

# Helper messages
show_help() {
    printf "Usage %s [options]\n" "$(basename "${0}")"
}

# Helper funcs
## Check if device is Raspberry Pi
is_raspberry_pi() {
    if [[ -f /proc/device-tree/model ]] &&
    grep -q "Raspberry" /proc/device-tree/model; then
        echo "1"
    else
        echo "0"
    fi
}

## Get avail mem
get_avail_mem() {
    grep "MemTotal" /proc/meminfo | awk '{print $2}'
}


## MAIN
main() {
    get_avail_mem
    echo "main"
}


## Error exit if no args given, show help
if [[ $# -eq "0" ]]; then
    show_help
    exit 1
fi
## Get opts
while true; do
    case "${1}" in
        -b|--build)
            BUILD_APPS="1"
            break
        ;;
        -c|--clean)
            CLEAN_APPS="1"
            break
        ;;
        *)
            printf "Unknown option: %s" "${1}"
            show_help
            exit 0
        ;;
    esac
done

main
exit 0

#### EOF
