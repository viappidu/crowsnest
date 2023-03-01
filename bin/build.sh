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



main
exit 0
