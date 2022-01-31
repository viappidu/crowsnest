#!/bin/bash

#### ustreamer library

#### webcamd - A webcam Service for multiple Cams and Stream Services.
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2021
#### https://github.com/mainsail-crew/crowsnest
####
#### This File is distributed under GPLv3
####

# shellcheck enable=require-variable-braces

# Exit upon Errors
set -e

# Use Port 8085
RTC_PORT="8085"

function run_webrtc {
    local url head stream cfg cnf_cm
    cams="${1}"
    url="rtsp://localhost:8554"
    cfg="/tmp/webrtc-config.json"
    # Remove existing tmp file
    if [ -f "${cfg}" ]; then
        rm -f "${cfg}"
    fi
    # Generate config.json
    head='{\n  "urls":{'
    echo -e "${head}" > "${cfg}"
    for i in ${cams}; do
        c=$((c +1))
        stream[0]="    \"${i}\":"
        stream[1]="{\"video\": \"${url}/${i}\""
        if [ "${c}" -eq "${#cnf_cm[@]}" ]; then
            stream[2]="}"
        else
            stream[2]="},"
        fi
        echo -e "${stream[*]}" >> "${cfg}"
    done
    echo -e "  }\n}" >> "${cfg}"
    # Check if it needs to be updated
    run_webrtc_srv &
    return
}

function run_webrtc_srv {
    local  rtc_bin pt cfg wwwroot start_param
    rtc_bin="${BASE_CN_PATH}/bin/webrtc-streamer/webrtc-streamer"
    pt="${RTC_PORT}"
    cfg="/tmp/webrtc-config.json"
    wwwroot="${BASE_CN_PATH}/bin/webrtc-streamer/html"
    # construct start parameter
    start_param=( -H"${pt}" -o -s -N1 )
    # webroot
    start_param+=( -w "${wwwroot}" )
    # config file
    start_param+=( -C "${cfg}" )
    # Log start_param
    log_msg "Starting webrtc-streamer ..."
    echo "Parameters: ${start_param[*]}" | \
    log_output "webrtc-streamer"
    # Start ustreamer
    echo "${start_param[*]}" | xargs "${rtc_bin}" 2>&1 | \
    log_output "webrtc-streamer"
    # Should not be seen else failed.
    log_msg "ERROR: Start of webrtc-streamer failed!"
}
