#!/bin/bash

#### camera-streamer library

#### crowsnest - A webcam Service for multiple Cams and Stream Services.
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2021 - 2022
#### https://github.com/mainsail-crew/crowsnest
####
#### This File is distributed under GPLv3
####

# shellcheck enable=require-variable-braces

# Exit upon Errors
set -Ee

function run_multi() {
    local cams
    cams="${1}"
    for instance in ${cams} ; do
        run_ayucamstream "${instance}" &
    done
}

function run_ayucamstream() {
    local cam_sec ust_bin dev pt res rtsp rtsp_pt fps cstm start_param
    local v4l2ctl
    cam_sec="${1}"
    ust_bin="${BASE_CN_PATH}/bin/camera-streamer/camera-streamer"
    dev="$(get_param "cam ${cam_sec}" device)"
    pt=$(get_param "cam ${cam_sec}" port)
    res=$(get_param "cam ${cam_sec}" resolution)
    fps=$(get_param "cam ${cam_sec}" max_fps)
    rtsp=$(get_param "cam ${cam_sec}" enable_rtsp)
    rtsp_pt=$(get_param "cam ${cam_sec}" rtsp_port)
    cstm="$(get_param "cam ${cam_sec}" custom_flags 2> /dev/null)"
    ## construct start parameter
    # set http port
    #
    start_param=( -http-port="${pt}" )

    # Set device
    start_param+=( -camera-path="${dev}" )

    # Use MJPEG Hardware encoder if possible
    if [ "$(detect_mjpeg "${cam_sec}")" = "1" ]; then
        start_param+=( -camera-format=MJPG )
    fi

    # Set resolution
    get_height_val() {
        (sed 's/#.*//' | cut -d'x' -f2) <<< "${res}"
    }
    get_width_val() {
        (sed 's/#.*//' | cut -d'x' -f1) <<< "${res}"
    }

    start_param+=( -camera-width="$(get_width_val)" )
    start_param+=( -camera-height="$(get_height_val)" )

    # Set FPS
    start_param+=( -camera-fps="${fps}" )

    # Enable rtsp, if set true
    if [[ -n "${rtsp}" ]] && [[ "${rtsp}" == "true" ]]; then
        # ensure a port is set
        start_param+=( -rtsp-port="${rtsp_pt:-8554}" )
    fi

    # Custom Flag Handling (append to defaults)
    if [[ -n "${cstm}" ]]; then
        start_param+=( "${cstm}" )
    fi

    # v4l2 option handling
    v4l2ctl="$(get_param "cam ${cam_sec}" v4l2ctl)"
    if [ -n "${v4l2ctl}" ]; then
        IFS="," read -ra opt < <(echo "${v4l2ctl}" | tr -d " "); unset IFS
        log_msg "V4L2 Control: Handling done by camera-streamer ..."
        log_msg "V4L2 Control: Trying to set: ${v4l2ctl}"
        # loop through options
        for param in "${opt[@]}"; do
            start_param+=( -camera-options="${param}" )
        done
    fi


    # Log start_param
    log_msg "Starting camera-streamer with Device ${dev} ..."
    echo "Parameters: ${start_param[*]}" | \
    log_output "camera-streamer [cam ${cam_sec}]"
    # Start camera-streamer
    echo "${start_param[*]}" | xargs "${ust_bin}" 2>&1 | \
    log_output "camera-streamer [cam ${cam_sec}]"
    # Should not be seen else failed.
    log_msg "ERROR: Start of camera-streamer [cam ${cam_sec}] failed!"
}


# WIP !!!!!! Remove when finished
# Usage:
# $ bin/camera-streamer/camera-streamer <options...>

# Options:
#   -camera-path=%s             - Chooses the camera to use. If empty connect to default.
#   -camera-type=arg            - Select camera type. Values: v4l2, libcamera.
#   -camera-width=%u            - Set the camera capture width.
#   -camera-height=%u           - Set the camera capture height.
#   -camera-format=arg          - Set the camera capture format. Values: DEFAULT, YUYV, YUV420, YUYV, MJPG, MJPEG, JPEG, H264, RG10, GB10P, RG10P, RGB565, RGBP, RGB24, RGB, BGR.
#   -camera-nbufs=%u            - Set number of capture buffers. Preferred 2 or 3.
#   -camera-fps=%u              - Set the desired capture framerate.
#   -camera-allow_dma[=1]       - Prefer to use DMA access to reduce memory copy.
#   -camera-high_res_factor=%f  - Set the desired high resolution output scale factor.
#   -camera-low_res_factor=%f   - Set the desired low resolution output scale factor.
#   -camera-options=%s          - Set the camera options. List all available options with `-camera-list_options`.
#   -camera-auto_reconnect=%u   - Set the camera auto-reconnect delay in seconds.
#   -camera-auto_focus[=1]      - Do auto-focus on start-up (does not work with all camera).
#   -camera-vflip[=1]           - Do vertical image flip (does not work with all camera).
#   -camera-hflip[=1]           - Do horizontal image flip (does not work with all camera).
#   -camera-isp.options=%s      - Set the ISP processing options. List all available options with `-camera-list_options`.
#   -camera-jpeg.options=%s     - Set the JPEG compression options. List all available options with `-camera-list_options`.
#   -camera-h264.options=%s     - Set the H264 encoding options. List all available options with `-camera-list_options`.
#   -camera-list_options[=1]    - List all available options and exit.
#   -http-port=%u               - Set the HTTP web-server port.
#   -http-maxcons=%u            - Set maximum number of concurrent HTTP connections.
#   -rtsp-port[=8554]           - Set the RTSP server port (default: 8854).
#   -log-debug[=1]              - Enable debug logging.
#   -log-verbose[=1]            - Enable verbose logging.
#   -log-filter=%s              - Enable debug logging from the given files. Ex.: `-log-filter=buffer.cc`

# Configuration:
#   -camera-path=
#   -camera-type=               v4l2 - 00000000
#   -camera-width=              1920
#   -camera-height=             1080
#   -camera-format=             DEFAULT - 00000000
#   -camera-nbufs=              3
#   -camera-fps=                30
#   -camera-allow_dma=          1
#   -camera-high_res_factor=    0.000000
#   -camera-low_res_factor=     0.000000
#   -camera-auto_reconnect=     0
#   -camera-auto_focus=         1
#   -camera-vflip=              0
#   -camera-hflip=              0
#   -camera-jpeg.options=       compression_quality=80
#   -camera-h264.options=       video_bitrate_mode=0
#   -camera-h264.options=       video_bitrate=2000000
#   -camera-h264.options=       repeat_sequence_header=5000000
#   -camera-h264.options=       h264_i_frame_period=30
#   -camera-h264.options=       h264_level=11
#   -camera-h264.options=       h264_profile=4
#   -camera-h264.options=       h264_minimum_qp_value=16
#   -camera-h264.options=       h264_maximum_qp_value=32
#   -camera-list_options=       0
#   -http-port=                 8080
#   -http-maxcons=              10
#   -rtsp-port=                 0
#   -log-debug=                 0
#   -log-verbose=               0
