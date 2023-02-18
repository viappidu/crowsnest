#!/bin/bash

#### Hardware Handling library

#### crowsnest - A webcam Service for multiple Cams and Stream Services.
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2021
#### https://github.com/mainsail-crew/crowsnest
####
#### This File is distributed under GPLv3
####

# shellcheck enable=require-variable-braces

# Exit upon Errors
set -Ee

### Detect Hardware
function detect_avail_cams {
    local avail realpath
    avail="$(find /dev/v4l/by-id/ -iname "*index0" 2> /dev/null)"
    count="$(echo "${avail}" | wc -l)"
    if [[ -d "/dev/v4l/by-id/" ]] &&
    [[ -n "${avail}" ]]; then
        log_msg "INFO: Found ${count} available camera(s)"
        echo "${avail}" | while read -r v4l; do
            realpath=$(readlink -e "${v4l}")
            log_msg "${v4l} -> ${realpath}"
            if [[ "${CROWSNEST_LOG_LEVEL}" != "quiet" ]]; then
                list_cam_formats "${v4l}"
                list_cam_v4l2ctrls "${v4l}"
            fi
        done
    else
        log_msg "INFO: No usable Cameras found."
    fi
}

# Used for "verbose" and "debug" logging in logging.sh
function list_cam_formats {
    local device formats
    device="${1}"
    formats="$(v4l2-ctl -d "${device}" --list-formats-ext | sed '1,3d')"
    log_msg "Supported Formats:"
    echo "${formats}" | while read -r i; do
        log_msg "\t\t${i}"
    done
}

function list_cam_v4l2ctrls {
    local device ctrls
    device="${1}"
    ctrls="$(v4l2-ctl -d "${device}" --list-ctrls-menus)"
    log_msg "Supported Controls:"
    echo "${ctrls}" | while read -r i; do
        log_msg "\t\t${i}"
    done
}


# libcamera-hello --list-cameras | sed '1,2d' | grep "\(/base/*\)" | cut -d"(" -f2 | tr -d '$)'

# Determine connected libcamera (CSI) device
function detect_libcamera {
    local avail
    if [[ -f /proc/device-tree/model ]] &&
    grep -q "Raspberry" /proc/device-tree/model; then
        vcgencmd get_camera | grep -c "libcamera interfaces=1" || true
    fi
}

# Spit /base/soc path for libcamera device
function get_libcamera_path {
    if [[ -f /proc/device-tree/model ]] &&
    [[ -x "$(command -v libcamera-hello)" ]]; then
        libcamera-hello --list-cameras | sed '1,2d' \
        | grep "\(/base/*\)" | cut -d"(" -f2 | tr -d '$)'
    fi
}

# Determine if cam has H.264 Hardware encoder
# call detect_h264 <nameornumber> ex.: detect_h264 foobar
# returns 1 = true / 0 = false ( numbers are strings! not int!)
function detect_h264 {
    local dev
    dev="$(get_param "cam ${1}" device)"
    v4l2-ctl -d "${dev}" --list-formats-ext | grep -c "[hH]264"
}

# Determine if cam has MJPEG Hardware encoder
# call detect_mjpeg <nameornumber> ex.: detect_mjpeg foobar
# returns 1 = true / 0 = false ( numbers are strings! not int!)
function detect_mjpeg {
    local dev
    dev="$(get_param "cam ${1}" device)"
    v4l2-ctl -d "${dev}" --list-formats-ext | grep -c "Motion-JPEG, compressed"
}
