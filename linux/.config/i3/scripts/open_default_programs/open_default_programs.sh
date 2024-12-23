#!/bin/bash
###########################################################################
 # Name: open_default_programs.sh
 # Author: Adam Camilli <AdamOCamilli@github.com>
 # Description: Open my chosen default programs in given workspace
 # Date: 03/18/2024
###########################################################################

# Error/warning strings for logging
error_str="ERROR: $0"
warning_str="WARNING: $0"

# Args/Usage
args="n"
dry_flag=""

# Common helpers
run_cmd() {
    if [[ -n "${dry_flag}" ]]; then
        echo "${@}"
    else
        ${@}
    fi
}

run_cmds_sequential() {
    idx=0
    WS=$FOCUSED
    while [[ ${idx} -lt ${NUM_DISPLAYS} ]]; do
        if [[ -n "${dry_flag}" ]]; then
            echo "i3-msg workspace ${WS}"
            echo "${1}"
        else
            i3-msg "workspace ${WS}; exec ${1} &"
            sleep 0.5
        fi
        # Cycle back around to get all displays if starting on higher-numbered monitor
        if [[ $((WS+WS_PER_MONITOR)) -gt ${NUM_WS} ]]; then
            WS=$((WS-((NUM_DISPLAYS - 1) * WS_PER_MONITOR)))
        else
            WS=$((WS+WS_PER_MONITOR))
        fi
        idx=$((idx+1))
        shift
    done
    i3-msg workspace "${FOCUSED}"
}

run_cmds_if_visible() {
    idx=0
    WS=$FOCUSED
    #i3-msg -t get_workspaces | jq '.[] | select(.output == "HDMI-0" and .focused==true) | .name'
    while [[ ${idx} -lt ${NUM_DISPLAYS} ]]; do
        if [[ -n "${dry_flag}" ]]; then
            echo "i3-msg workspace ${WS}"
            echo "${1}"
        else
            i3-msg "workspace ${WS}; exec ${1} &; pid=$!; wait $!"
            sleep 0.5
        fi
        # Cycle back around to get all displays if starting on higher-numbered monitor
        if [[ $((WS+WS_PER_MONITOR)) -gt ${NUM_WS} ]]; then
            WS=$((WS-((NUM_DISPLAYS - 1) * WS_PER_MONITOR)))
        else
            WS=$((WS+WS_PER_MONITOR))
        fi
        idx=$((idx+1))
        shift
    done
    i3-msg workspace "${FOCUSED}"
}

pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}

NUM_DISPLAYS=$(xrandr | \grep -c " connected")
WS_PER_MONITOR=25
NUM_WS=$((NUM_DISPLAYS * WS_PER_MONITOR))

FOCUSED="$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused == true) | .name')"

case "${FOCUSED}" in
    1 )
        #run_cmds_sequential "firefox --new-window" "firefox --new-window" "firefox --new-window" "firefox --new-window"
        # baseball streams
        run_cmds_sequential "firefox --new-window https://www.mlb.com/scores" "firefox --new-window https://methstreams.com/mlb-streams/live4/" "firefox --new-window https://methstreams.com/mlb-streams/live4/" "firefox --new-window https://methstreams.com/mlb-streams/live4/"
        ;;
    26 | 51 | 76)
        run_cmd "krusader --left /media/adam/zfs/AOC-Media-12TB/Media/ --right $HOME"
        ;;
    2 | 27 | 52 | 77)
        run_cmds_sequential \
            "firefox --new-window https://docs.google.com/spreadsheets/d/1am2jGWdQBzQD1aQEcUkraWiy9fw42747K9zcitg9vGQ/edit?gid=0#gid=0" \
            "firefox --new-window https://docs.google.com/spreadsheets/d/1fILRIk-wOXbzxCw4WbpyvQkrXyE0quYH5GF7WuqWtoI/edit?pli=1&gid=0#gid=0" \
            "firefox --new-window https://docs.google.com/spreadsheets/d/1QoZ22Q36NTNYHJnHK5sLkDVoEIt1PgvXzGBxs2I-vLo/edit?gid=484851204#gid=484851204" \
            "firefox --new-window https://drive.google.com/drive/recent"
        ;;
    3 | 28 | 53 | 78)
        run_cmd "spotify" ;;
    4 | 29 | 54 | 79)
        run_cmd "steam" ;;
    5 | 30 | 80)
        run_cmd "i3-msg layout tabbed"
        # TODO can't figure out right escape for run_cmd...
        xfce4-terminal --title='Fluidsynth' -e "bash -c 'fluidsynth /usr/share/sounds/sf2/_SF2__GM_SoundFonts__shared_by_ZSF__-_Crisis_GM_3.51_ZSF_Edit.sf2 -g 1; exec bash'"
        run_cmd "powertabeditor"
        ;;
    55)
        xfce4-terminal --title='Tuner' e "bash -c 'notes=("Eb5" "Bb5" "Gb4" "Db4" "Ab4" "Eb4")'"
        ;;
    6 | 31 | 56 | 81)
        run_cmd "flatpak run com.obsproject.Studio"
        ;;
    7 | 32 | 57 | 82)
        run_cmd "firefox" ;;
    8 | 33 | 58 | 83)
        run_cmds_sequential "qbittorrent" "calibre" "firefox --new-window https://yts.mx" "firefox --new-window https://rutracker.org"
        ;;
    9 | 34 | 59 | 84)
        run_cmd "firefox" ;;
    10 | 35 | 60 | 85)
        run_cmd "firefox" ;;
    11 | 36 | 61 | 86)
        run_cmd "exodus" ;;
    12 | 37 | 62 | 87)
        run_cmd "firefox" ;;
    13 | 38 | 63 | 88)
        run_cmd "firefox" ;;
    14 | 39 | 64 | 89)
        run_cmd "krusader" ;;
    15 | 40 | 65 | 90)
        run_cmd "firefox" ;;
    "16 "* | 41 | 66 | 91)
        run_cmd "mullvad-vpn" ;;
    17 | 42 | 67 | 92)
        run_cmd "firefox" ;;
    18 | 43 | 68 | 93)
        run_cmd "firefox" ;;
    19 | 44 | 69 | 94)
        run_cmd "firefox" ;;
    20 | 45 | 70 | 95)
        run_cmd "firefox" ;;
    21 | 46 | 71 | 96)
        run_cmds_sequential \
            "xfce4-terminal --title='bashtop' -x bashtop" \
            "xfce4-terminal --title='nvtop' -x nvtop" \
            "cpu-x -g 1" \
            "blueman-manager"
        ;;
    22 | 47 | 72 | 97)
        run_cmds_sequential \
            "gnome-disks" \
            "krusader --left /media/adam/ntfs --right /media/adam/zfs" \
            "xfce4-terminal --title='bashtop' -x bashtop" \
            "firefox --new-window https://jro.io/truenas/openzfs/"
        ;;
    23 | 48 | 73 | 98)
        run_cmd "firefox" ;;
    24 | 49 | 74 | 99)
        run_cmd "firefox" ;;
esac
