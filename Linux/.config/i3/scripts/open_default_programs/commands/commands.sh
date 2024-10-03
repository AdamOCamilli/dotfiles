#!/bin/bash

declare -A command_matrix

command_matrix = ( \
    ( \ # 1
        "firefox --new-window https://www.mlb.com/scores" \
        "firefox --new-window https://methstreams.com/mlb-streams/live4/" \
        "firefox --new-window https://methstreams.com/mlb-streams/live4/" \
        "firefox --new-window https://methstreams.com/mlb-streams/live4/" \
    ) \
    ( \ # 2
        "firefox --new-window https://docs.google.com/spreadsheets/d/1am2jGWdQBzQD1aQEcUkraWiy9fw42747K9zcitg9vGQ/edit?gid=0#gid=0" \
        "firefox --new-window https://docs.google.com/spreadsheets/d/1fILRIk-wOXbzxCw4WbpyvQkrXyE0quYH5GF7WuqWtoI/edit?pli=1&gid=0#gid=0" \
        "firefox --new-window https://docs.google.com/spreadsheets/d/1QoZ22Q36NTNYHJnHK5sLkDVoEIt1PgvXzGBxs2I-vLo/edit?gid=484851204#gid=484851204" \
        "firefox --new-window https://drive.google.com/drive/recent"
    ) \
    ( \ # 3
        ":"
    ) \
    ( \ # 4
        ":"
    ) \
    ( \ # 5
        ":"
    ) \
    ( \ # 6
        ":"
    ) \
    ( \ # 7
        ":"
    ) \
    ( \ # 8
        ":"
    ) \
    ( \ # 9
        ":"
    ) \
    ( \ # 10
        ":"
    ) \
    ( \ # 11
        ":"
    ) \
    ( \ # 12
        ":"
    ) \
    ( \ # 13
        ":"
    ) \
    ( \ # 14
        ":"
    ) \
    ( \ # 15
        ":"
    ) \
    ( \ # 16
        ":"
    ) \
    ( \ # 17
        ":"
    ) \
    ( \ # 18
        ":"
    ) \
    ( \ # 19
        ":"
    ) \
    ( \ # 20
        ":"
    ) \
    ( \ # 21
        ":"
    ) \
    ( \ # 22
        ":"
    ) \
    ( \ # 23
        ":"
    ) \
    ( \ # 24
        ":"
    ) \
    ( \ # 25
        ":"
    ) \
)


case "${1}" in
    1 | 26 | 51 | 76)
        #run_cmds_sequential "firefox --new-window" "firefox --new-window" "firefox --new-window" "firefox --new-window"
        # baseball streams
        run_cmds_sequential "firefox --new-window https://www.mlb.com/scores" "firefox --new-window https://methstreams.com/mlb-streams/live4/" "firefox --new-window https://methstreams.com/mlb-streams/live4/" "firefox --new-window https://methstreams.com/mlb-streams/live4/"
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
    5 | 30 | 55 | 80)
        run_cmd "i3-msg layout tabbed"
        # TODO can't figure out right escape for run_cmd...
        xfce4-terminal --title='Fluidsynth' -e "bash -c 'fluidsynth /usr/share/sounds/sf2/_SF2__GM_SoundFonts__shared_by_ZSF__-_Crisis_GM_3.51_ZSF_Edit.sf2 -g 1; exec bash'"
        run_cmd "powertabeditor";;
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
    16 | 41 | 66 | 91)
        run_cmd "protonvpn-app" ;;
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
        run_cmd "firefox" ;;
    23 | 48 | 73 | 98)
        run_cmd "firefox" ;;
    24 | 49 | 74 | 99)
        run_cmd "firefox" ;;
    50)
        bash -ci ". /home/adam/.bashrc ; nsw $(find /home/adam/Pictures/4chan/noice/custom/backgrounds/nitrogen/cfnm/ -maxdepth 1 -type d | tail -n +2 | shuf -n 1)"
        run_cmd "krusader --left $HOME/Pictures/4chan/noice/custom/backgrounds --right $HOME/Pictures/4chan/noice/art/animated/cfnm"
        ;;
    25 | 75 | 100)
        bash -ci ". /home/adam/.bashrc ; nsw $(find /home/adam/Pictures/4chan/noice/custom/backgrounds/nitrogen/f/ -maxdepth 1 -type d | tail -n +2 | shuf -n 1)"
        #bash -ci ". /home/adam/.bashrc ; nsw /home/adam/Pictures/4chan/noice/custom/backgrounds/nitrogen/nitrogen_girls_enjoying_my_nudity_1😄👉😳"
        #xfce4-terminal --title='Fluidsynth' -e "bash -ci '. /home/adam/.bashrc ; nsw /home/adam/Pictures/4chan/noice/custom/backgrounds/nitrogen/nitrogen_girls_enjoying_my_nudity_1😄👉😳'"
        run_cmd "krusader --left $HOME/Pictures/4chan/noice/custom/backgrounds --right $HOME/Pictures/4chan/noice"
        ;;
esac
