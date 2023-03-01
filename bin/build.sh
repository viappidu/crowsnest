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
# Base Path
BASE_CN_BIN_PATH="$(dirname "$(readlink -f "${0}")")"

# Clone Flags
CLONE_FLAGS=(--depth=1 --single-branch)

# Ustreamer repo
USTREAMER_PATH="ustreamer"
USTREAMER_REPO="https://github.com/pikvm/ustreamer.git"
USTREAMER_BRANCH="master"

# Camera-streamer repo
CSTREAMER_PATH="camera-streamer"
CSTREAMER_REPO="https://github.com/ayufan-research/camera-streamer.git"
CSTREAMER_BRANCH="develop"

# CPU architecture
ARCH="$(uname -m)"

# Paths of repos
ALL_PATHS=(
    "${BASE_CN_BIN_PATH}"/"${USTREAMER_PATH}"
    "${BASE_CN_BIN_PATH}"/"${CSTREAMER_PATH}"
)

# Helper messages
show_help() {
    printf "Usage %s [options]\n" "$(basename "${0}")"
    printf "\t-b or --build\t\tBuild Apps\n"
    printf "\t-c or --clean\t\tClean Apps\n"
    printf "\t-d or --delete\t\tDelete cloned Apps\n"
    printf "\t-r or --reclone\t\tClone Apps again\n\n"
}

## Helper funcs
### Check if device is Raspberry Pi
is_raspberry_pi() {
    if [[ -f /proc/device-tree/model ]] &&
    grep -q "Raspberry" /proc/device-tree/model; then
        echo "1"
    else
        echo "0"
    fi
}

### Get avail mem
get_avail_mem() {
    grep "MemTotal" /proc/meminfo | awk '{print $2}'
}

## MAIN funcs
### Delete repo folder
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

### Clone ustreamer
clone_ustreamer() {
    if [[ -d "${BASE_CN_BIN_PATH}"/"${USTREAMER_PATH}" ]]; then
        printf "%s already exist ... [SKIPPED]\n" "${USTREAMER_PATH}"
        return
    fi
    git clone  "${USTREAMER_REPO}" \
        -b "${USTREAMER_BRANCH}" \
        "${BASE_CN_BIN_PATH}"/"${USTREAMER_PATH}" \
        "${CLONE_FLAGS[@]}"
}

### Clone camera-streamer
clone_cstreamer() {
    if [[ -d "${BASE_CN_BIN_PATH}"/"${CSTREAMER_PATH}" ]]; then
        printf "%s already exist ... [SKIPPED]\n" "${CSTREAMER_PATH}"
        return
    fi
    git clone  "${CSTREAMER_REPO}" \
        -b "${CSTREAMER_BRANCH}" \
        "${BASE_CN_BIN_PATH}"/"${CSTREAMER_PATH}" \
        "${CLONE_FLAGS[@]}" --recursive
}

### Clone Apps
clone_apps() {
    local apps
    apps="ustreamer cstreamer"
    for app in ${apps}; do
        clone_"${app}"
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
                delete_apps
                clone_apps
                break
            ;;
            *)
                printf "Unknown option: %s" "${1}"
                show_help
                break
            ;;
        esac
    done
}

#### MAIN
main "${@}"
exit 0

#### EOF
