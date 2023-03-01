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
ALL_PATHS=(
    ${USTREAMER_PATH}
    ${CSTREAMER_PATH}
)

# Helper messages
show_help() {
    printf "Usage %s [options]\n" "$(basename "${0}")"
    printf "\t-b or --build\t\tBuild Apps\n"
    printf "\t-c or --clean\t\tClean Apps\n"
    printf "\t-d or --delete\t\tDelete cloned Apps\n"
    printf "\t-r or --reclone\t\tClone Apps again\n\n"
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

delete_apps() {
    for i in "${ALL_PATHS[@]}"; do
        if [[ -d "${i}" ]]; then
            printf "Deleting '%s' ... \n" "${i}"
            rm -rf ./"${i}"
        fi
        if [[ ! -d "${i}" ]]; then
            printf "'%s' does not exist! ... [SKIPPED]\n" "${i}"
        fi
    done
}

## MAIN FUNC
main() {
    ## Error exit if no args given, show help
    if [[ $# -eq "0" ]]; then
        printf "ERROR: No options given ...\n"
        show_help
        exit 1
    fi
    ## Error exit if too many args given
    if [[ $# -gt "1" ]]; then
        printf "ERROR: Too many options given ...\n"
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
            -d|--delete)
                delete_apps
                break
            ;;
            -r|--reclone)
                CLONE_APPS="1"
            ;;
            *)
                printf "Unknown option: %s" "${1}"
                show_help
                exit 0
            ;;
        esac
    done
}

#### MAIN
main "${@}"
exit 0

#### EOF
