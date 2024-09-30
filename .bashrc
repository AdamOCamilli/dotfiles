#!/bin/bash
####################################################################################################
# Description: My platform-agnostic .bashrc
####################################################################################################


####################################################################################################
# Preliminary
####################################################################################################
# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Get useful snippets
source "${HOME}/.bashrc_local/util.sh"

# *nix or Windows
function checkLocalPlatform()
{
	unameOut="$(uname -s)"
	case "${unameOut}" in
		Linux*)     
            if grep -qi microsoft /proc/version; then
                PLATFORM=WSL
            else
                PLATFORM=Linux
            fi
            ;;
		Darwin*)    PLATFORM=Mac;;
		CYGWIN*)    
			PLATFORM=Cygwin
			export CHERE_INVOKING=1;;
		MINGW*)     PLATFORM=Windows;;
		*)          PLATFORM="UNKNOWN:${unameOut}"
	esac
}
checkLocalPlatform

# Load local bash options
if [[ -d ${HOME}/.bashrc_local/ ]] && [[ -e ${HOME}/.bashrc_local/ ]]; then
    if [[ $PLATFORM == "Cygwin" ]]; then
        for f in ${HOME}/.bashrc_local/.bashrc_cygwin/.bashrc_*; do
            [[ -e "$f" ]] && source "$f"
        done
    elif [[ $PLATFORM == "Darwin" ]]; then
        for f in ${HOME}/.bashrc_local/.bashrc_macos/.bashrc_*; do
            [[ -e "$f" ]] && source "$f"
        done
    elif [[ $PLATFORM == "Windows" ]]; then
        for f in ${HOME}/.bashrc_local/.bashrc_windows/.bashrc_*; do
            [[ -e "$f" ]] && source "$f"
        done
    elif [[ $PLATFORM == "Linux" ]]; then
        for f in ${HOME}/.bashrc_local/.bashrc_linux/.bashrc_*; do
            [[ -e "$f" ]] && source "$f"
        done
    elif [[ $PLATFORM == "WSL" ]]; then
        for f in ${HOME}/.bashrc_local/.bashrc_wsl/.bashrc_*; do
            [[ -e "$f" ]] && source "$f"
        done
    fi
    for f in ${HOME}/.bashrc_local/.bashrc_all/.bashrc_*; do
        [[ -e "$f" ]] && source "$f"
    done
fi

# Search all bashrc files for something
alias find_bashrc='find ~ -type f -name ".bashrc*"'

# Vim as default editor
export EDITOR=vim

####################################################################################################
# Misc Options
####################################################################################################
#
# Remove a lot of "intelligent" annoying tab completion options and don't escape or expand $variables when tabbing
shopt -u progcomp

# From https://unix.stackexchange.com/a/61608
# Stop bad return displays when resizing window
shopt -s checkwinsize

####################################################################################################
# History
# Mostly based on tips from https://www.soberkoder.com/unlimited-bash-history/
####################################################################################################
#
# Append history instead of erasing it. Required to keep track of multiple shells
shopt -s histappend

# Give unlimited size
export HISTFILESIZE=
export HISTSIZE=

# Make bash immediately append commands to history to not lose history upon unexpected/unclean termination of shell and share history between all open shells
PROMPT_COMMAND="history -a; history -r; $PROMPT_COMMAND"
# Add timestamp to history
export HISTTIMEFORMAT="[%F %T] "
# Ignore duplicates and erase any existing ones
export HISTCONTROL=erasedups

####################################################################################################
# Aliases
####################################################################################################

# find - useful snippets
# prints name (WxH, size) of images >= 1920x1080
# find . -type f \( -iname "*.jpg" -o -iname "*.png" \) -exec bash -c 'identify -format "%w %h %b\n" "$1" | awk -v file="$1" '"'"'$1 >= 1920 && $2 >= 1080 { printf("%s (%dx%d, %s)\n", file, $1, $2, $3) }'"'"'' -- {} \;
# fills dir with symlinks to images of >= 2560x1440
# dest='2560x1440_links' && mkdir -p $dest && find . -type f \( -iname "*.jpg" -o -iname "*.png" \) -exec bash -c 'identify -format "%w %h\n" "$1" | awk -v file="$1" '"'"'$1 >= 2560 && $2 >= 1440 { print file }'"'"'' -- {} \; | xargs -I {} ln -sv "$(realpath {})" "$dest"

# git
# List paths to all modified files in git repo 
gitc_func() {
    if [[ -n "${1}" ]]; then
        git status "${1}" --porcelain | sed s,^...,.\/,
    else
        git status --porcelain | sed s,^...,.\/,
    fi
}
alias gitc=gitc_func

# nice usable vimdiff with git
# uses temp vimscript file
# for each modified file, opens local copy next to head (stored in unwriteable /tmp buffer) 
# also opens most useful vimdiff / fold commands + a window to type a commit msg in a variable
gitd () {
    if [[ -z "${1}" ]]; then
        src="."
    else
        src="${1}"
    fi
    modified_git_files=()
    head_files=()
    readarray -t modified_git_files < <(git -C "${src}" status -s | awk '/^\s*M/ {print $2}' | xargs -I {} realpath "{}")
    for modified_git_file in "${modified_git_files[@]}"; do
        # need to use paths relative to git repo
        modified_git_file_git_path=$(git ls-files --full-name "${modified_git_file}")
        tmp_file="tmp.$(date +%s).$(basename ${modified_git_file})"
        git show HEAD:"${modified_git_file_git_path}" > "/tmp/${tmp_file}"
        head_files+=("/tmp/${tmp_file}")
    done
    if [[ "${#modified_git_files[@]}" -ne "${#head_files[@]}" ]]; then
        echo "error: not all modified files have matching head files: "
        echo "${modified_git_files[@]}"
        echo "${head_files[@]}"
    else
        # create vimscript file to execute commands
        export GITD_REPO=$(git rev-parse --show-toplevel)
        repo=$(basename "${GITD_REPO}")
        rev=$(git rev-parse HEAD)
        tmp_vimscript_file="/tmp/tmp.gitd.setup.${repo}_${rev}.vim"
        export GITD_COMMIT="/tmp/tmp.gitd.commit.${repo}_${rev}.sh"
        if [[ ! -e "${GITD_COMMIT}" ]]; then
            touch "${GITD_COMMIT}"
            chmod +x "${GITD_COMMIT}"
            echo "# Current git status:" > "${GITD_COMMIT}"
            git status | awk '{print "# " $0}' >> "${GITD_COMMIT}"
            cat <<EOF >> "${GITD_COMMIT}"
# files=($(echo "${modified_git_files[@]}" | awk '{ for (i=1; i<=NF; i++) printf "\"%s\"",(i==NF?$i:$i FS) }' ))
# GITD_REPO="${GITD_REPO}"
files=()
message=""
git add "\${files[@]}"
git commit -m "\${message}" "\${files[@]}"
echo "Added and committed: \${files[@]}"
echo "Message: \${message}"
rm "${GITD_COMMIT}"
EOF
        fi
        for i in $(eval echo "{0..$(( ${#head_files[@]} - 1 ))}"); do
            # initial does not need tab
            if [[ "${i}" -eq 0 ]]; then
                cat <<EOF > "${tmp_vimscript_file}"
" Initial file 
h jumpto-diff 
wincmd r
resize 20%
vsplit
wincmd w
h fold-commands
vsplit
wincmd w
e ${GITD_COMMIT}
normal! G
wincmd w
set diffopt=filler,vertical
view ${head_files[${i}]}
diffsplit ${modified_git_files[${i}]}
EOF
            else
                cat <<EOF >> "${tmp_vimscript_file}"
" Subsequent file (in its own tab)
tabnew
wincmd w
h jumpto-diff 
wincmd r
resize 20%
vsplit
wincmd w
h fold-commands
vsplit
wincmd w
e ${GITD_COMMIT}
normal! G
wincmd w
set diffopt=filler,vertical
view ${head_files[${i}]}
diffsplit ${modified_git_files[${i}]}
EOF
            fi
        done
        vim -S "${tmp_vimscript_file}"
    fi
}

# grep 
export GREP_COLORS="$(cat ~/.bashrc_local/custom_dircolors)"
alias egrep='egrep --color=always'              # show differences in colour
alias fgrep='fgrep --color=always'              # show differences in colour
alias g='grep -Hn --color=always'            # show differences in colour
alias j='jobs -l'

# ls
#LS_COLORS="$(vivid generate molokai)"
export LS_COLORS="$(cat ~/.bashrc_local/custom_dircolors)"
alias l='clear && \ls -AhF --color=always '
alias ls='\ls -AFh --color=always' # add colors and file type extensions
alias la='\ls -AFlh --color=always' # long file names
alias lx='\ls -lXBh --color=always' # sort by extension
alias lk='\ls -lSrh --color=always' # sort by size
alias lc='\ls -lcrh --color=always' # sort by change time
alias lu='\ls -lurh --color=always' # sort by access time
alias lr='\ls -lRh --color=always' # recursive ls
alias lt='\ls -ltrh --color=always' # sort by date
alias lm='\ls -alh |more --color=always' # pipe through 'more'
alias lw='\ls -xAh --color=always' # wide listing format
alias ll='\ls -Fls --color=always' # long listing format
alias labc='\ls -lAp --color=always' #alphabetical sort
alias lf="ls -l --color=always | egrep -v '^d'" # files only
alias ldir="ls -l --color=always | egrep '^d'" # directories only

# Pipe shorteners
alias p_v='vim -'
alias p_vr='vim -R -'
alias p_xvp='xargs vim -p'      # use with |, open list of filenames in separate buffers in vim
alias p_xg="xargs grep -in --color=always"

# python / pip
if [[ "${PLATFORM}" -eq "Linux" || "${PLATFORM}" -eq "WSL" ]]; then
    # Two problems with python in Linux:
    #   1. Everything is installed locally (a.k.a off the PATH) by default
    #   2. Try to ameliorate this by installing with Linux pkg managers results in permissions issues and completely broken dependency chains with cryptic errors
    # To solve you need to use virtualenvs, and if I want one for general use I put it in ~/.local
    # Personally cannot stand general use stuff not being on PATH so also need to add local python install to PATH
    export PATH="~/.local/:${PATH}"

    # Redhat and other distros don't assign 'python' to anything by default, but 99% of the time I just want latest version
    # Set 'python' to latest python version installed if not already specified
    unalias python &>/dev/null
    python_cmds=($(compgen -c python | awk '/^python[0-9]+(\.[0-9]+)?$/'))
    if [[ -n "${python_cmds[@]}" ]]; then
        for python_cmd in "${python_cmds[@]}"; do 
            python_cmd_major=$(${python_cmd} --version | sed 's|python\s*\([0-9]\+\)\.\?\([0-9]\+\)\.\?\([0-9]\+\)\?|\1|gi')
            python_cmd_minor=$(${python_cmd} --version | sed 's|python\s*\([0-9]\+\)\.\?\([0-9]\+\)\.\?\([0-9]\+\)\?|\2|gi')
            python_cmd_patch=$(${python_cmd} --version | sed 's|python\s*\([0-9]\+\)\.\?\([0-9]\+\)\.\?\([0-9]\+\)\?|\3|gi')
            python_cmd_ver="${python_cmd_major}.${python_cmd_minor}.${python_cmd_patch}"
            python_cur_lib_ver="${python_cmd_major}.${python_cmd_minor}"
            if [[ -z "${python_current_ver}" ]]; then
                python_current_ver="${python_cmd_ver}"
            fi
            util_verlt "${python_current_ver}" "${python_cmd_ver}" && res="${python_cmd}" && python_cur_lib_ver="${python_cmd_major}.${python_cmd_minor}"
        done
        if [[ -n "${res}" ]]; then
            alias python="${res}"
        fi
        export PYTHON_LIB_VER="${python_cur_lib_ver}"
    fi
fi

# qbittorrent
qbt_inspect  () {
    if curl --head --silent --fail "${1}" &> /dev/null; then
        local temp="a.torrent" 
        curl -s -o "${temp}" "${1}"
        transmission-show "${temp}" && rm "${temp}"
    else
        echo "Url \"${1}\" is invalid"
    fi
}

qbit_yts_mx_download () {
    # Error/warning strings for logging
    local error_str="ERROR: $0"
    local warning_str="WARNING: $0"
    local exit_flag=0
    local src=""
    local dest=""
    local output_name=""

    # parse args
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h) 
                echo "qbit_yts_download [YTS.MX URL] [PATH] [NAME?]"
                echo "    If no name provided, use the Name: portion of torrent metadata to find <Media Name> <Year>"
                shift ;;
            *)
                if curl --head --silent --fail "${1}" &> /dev/null; then
                    if [[ -z "${src}" ]]; then
                        if [[ "${1}" =~ ^http(s?)://yts.mx/.*$ ]]; then
                            local src="${1}"
                        else
                            echo "${error_str} URL must be from https://yts.mx"
                            local exit_flag=1
                        fi
                    else
                        echo "${error_str} More than one URL specified"
                        local exit_flag=1
                    fi
                elif [[ -d "${dest}" ]]; then
                    if [[ -z "${dest}" ]]; then 
                        local dest="${1}"
                    else
                        echo "${error_str} More than one destination file specified"
                        local exit_flag=1
                    fi
                elif [[ -z "${output_name}" ]]; then
                    local output_name="${1}"
                fi
                shift;;
        esac
    done
    if [[ ${exit_flag} == "0" ]]; then
        # Use torrent data to get default name if not provided
        local torrent_name="$(qbt_inspect ${src} | rg -o --pcre2 '(?<=Name: )[^$]*' -m 1).torrent"
        if [[ -z "${output_name}" ]]; then
            local output_name=$(qbt_inspect "${src}" | rg -o --pcre2 '(?<=Name: )[^[]*' -m 1)
        fi
        echo "${torrent_name}"
        echo "${output_name}"
        mkdir -p "${dest}/${output_name}/"
        pushd "${dest}/${output_name}"
        curl -o "${torrent_name}" "${src}"
        popd
        qbittorrent "${dest}/${output_name}/${torrent_name}" --save-path="${dest}/${output_name}/" --add-paused=false
    fi
}

# reset
if [[ "${PLATFORM}" -eq "Linux" || "${PLATFORM}" -eq "WSL" ]]; then
    alias r='source ${HOME}/.bashrc && reset && neofetch ' # have reset run bashrc to get any updates + neofetch
else
    alias r='source ${HOME}/.bashrc && reset' # have reset run bashrc to get any updates
fi

# Easy way to change prompt length if bothersome for terminal window size
r-- () {
    export PROMPT_DIRTRIM=1
    # Reset if any args given
    [[ -n $@ ]] && reset
}
r++ () {
    export PROMPT_DIRTRIM=0
    # Reset if any args given
    [[ -n $@ ]] && reset
}
r- () {
    cwd=$(pwd)
    cwd_no_slashes=${cwd//"/"}
    cwd_num_slashes=$(( ${#cwd} - ${#cwd_no_slashes} ))
    if [[ ${PROMPT_DIRTRIM} -gt 1 ]]; then
        export PROMPT_DIRTRIM=$(( ${PROMPT_DIRTRIM} - 1 )) 
        # Reset if any args given
        [[ -n $@ ]] && reset
    elif [[ ${PROMPT_DIRTRIM} -eq 0 ]]; then
        export PROMPT_DIRTRIM=$(( ${cwd_num_slashes} - 1 )) 
        # Reset if any args given
        [[ -n $@ ]] && reset
    fi
}
r+ () {
    cwd=$(pwd)
    cwd_no_slashes=${cwd//"/"}
    cwd_num_slashes=$(( ${#cwd} - ${#cwd_no_slashes} ))
    if [[ ${PROMPT_DIRTRIM} -lt ${cwd_num_slashes} && ${PROMPT_DIRTRIM} -gt 0 ]]; then
        export PROMPT_DIRTRIM=$(( ${PROMPT_DIRTRIM} + 1 ))
        # Reset if any args given
        [[ -n $@ ]] && reset
    fi
}

# svn
svn_url_func () {
    svn info "${1}" | \grep -E '^URL: ' | \grep -oE 'https.*' | tr -d '\r'
}
alias svn_url=svn_url_func 

svn_count_commits_func () {
    svn log "${1}" --quiet | \grep "^r" | awk '{print $3}' | sort | uniq -c
}
alias svn_count_commits='svn_count_commits_func '

# usable vimdiff with svn
svnd () {
    if [[ -z "${1}" ]]; then
        src="."
    else
        src="${1}"
    fi
    modified_svn_files=()
    head_files=()
    readarray -t modified_svn_files < <(svn status -q "${src}" | awk '{print $2}' | tr "\\\\" "/" | tr -d '\r')
    for modified_svn_file in "${modified_svn_files[@]}"; do
        tmp_file="tmp.$(date +%s).$(basename ${modified_svn_file})"
        svn cat "${modified_svn_file}" > "/tmp/${tmp_file}"
        head_files+=("/tmp/${tmp_file}")
    done
    if [[ "${#modified_svn_files[@]}" -ne "${#head_files[@]}" ]]; then
        echo "error: not all modified files have matching head files: "
        echo "${modified_svn_files[@]}"
        echo "${head_files[@]}"
    else
        for i in $(eval echo "{0..$(( ${#head_files[@]} - 1 ))}"); do
            if [[ "${i}" -eq 0 ]]; then
                diff_cmd="vim -c 'set diffopt=filler,vertical' -c 'view ${head_files[${i}]}' -c 'diffsplit ${modified_svn_files[${i}]}' "
            else
                diff_cmd="${diff_cmd} ; vim -c 'set diffopt=filler,vertical' -c 'view ${head_files[${i}]}' -c 'diffsplit ${modified_svn_files[${i}]}' "
            fi
        done
        eval "${diff_cmd}"
    fi
}

# tmux
export TMUXDIR="${HOME}/.config/tmux"
export TMUX_RESURRECT="${HOME}/.local/share/tmux/resurrect/"
export TMUX_PLUGIN_MANAGER_PATH="${TMUXDIR}/plugins"
alias tm='tmux '
alias tn='tmux new -s '
alias tl='tmux list-sessions '
alias ta='tmux at -t '
alias tk='tmux kill-session -t '

# tree
alias t='tree '
alias tree='tree -aC ' # List dotfiles by default and use LS_COLORS

# Xargs 
alias xargs='xargs ' # make xargs respect aliases over default binaries
alias x='xargs '               

# Xmodmap 
if [[ "${PLATFORM}" -eq "Linux" || "${PLATFORM}" -eq "WSL" ]]; then
    if [[ ! -f ~/.Xmodmap ]]; then
        xmodmap -pke > ~/.Xmodmap
    fi
    xmodmap ~/.Xmodmap
fi

# Various utilies
alias a=alias
alias h=history
alias rg="rg --hidden --glob '!.git' --glob '!.svn' --path-separator / "
alias rp="realpath"
alias ssh='sshrc'
alias v='vim '
alias vr='vim -R '

####################################################################################################
# Functions
####################################################################################################

# Show all current single character aliases and functions
s () {
    echo "Single Character Aliases: "
    alias | \grep -o ' .=.*' | sed -nr "s/^ /\t/p"
    echo "Single Character Functions: "
    cat ~/.bashrc | \grep -Pzo '#.*\n. \(\).*\n' | sed -nr "s/^(. |# )/\t\1/p"
}

# Make a directory and cd into it immediately
mcd_func () {
    mkdir -p "${1}"
    cd "${1}"
}
alias mcd=mcd_func

# Show hexcode color (w/o #)
showcolor() {
    perl -e 'foreach $a(@ARGV){print "\e[48:2::".join(":",unpack("C*",pack("H*",$a)))."m \e[49m "};print "\n"' "$@"
}

# Temporarily download and play youtube audio  and delete after you stop listening
tyt_func () {
    local urls=()
    local audio_files=()
    local playlist_file="playlist.m3u"
    local vlc_params=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v)
                yt_dlp_options=""
                ;;
            --vlc)
                shift
                vlc_params="$1"
                ;;
            *)
                urls+=("$1")
                ;;
        esac
        shift
    done

    # Check if URLs are provided
    if [[ ${#urls[@]} -eq 0 ]]; then
        echo "URLs are required."
        return 1
    fi

    # Download audio or video using yt-dlp for each URL
    for url in "${urls[@]}"; do
        # If not a URL, assume it is a youtube video ID
        if [[ ! "${url}" =~ "https://"* ]]; then
            url="https://www.youtube.com/watch?v=${url}"
        fi
        local audio_file="audio_$(date +%s).mp3"
        # if audio, download lowest possible quality video
        if [[ -z "$yt_dlp_options" ]]; then
            yt-dlp -x --audio-format mp3 -f worst "$url" -o "$audio_file"
            #yt-dlp -x --audio-format mp3 "$url" -o "$audio_file"
        else
            yt-dlp "$url" -o "$audio_file"
        fi
        audio_files+=("$audio_file")
    done

    # Create playlist file
    > "${playlist_file}"
    for audio_file in "${audio_files[@]}"; do
        local audio_rp="$(realpath ${audio_file})"
        local audio_win_rp=$(cygpath -w "${audio_rp}")
        echo "${audio_win_rp}" >> "$playlist_file"
    done

    # Play playlist with VLC
    if [[ -z "${vlc_params}" ]]; then
        # Play audio or video with minimized VLC by default
        vlc --qt-start-minimized "$playlist_file" vlc://quit &
    else
        vlc ${vlc_params} "$playlist_file" vlc://quit &
    fi

    # Wait for VLC to exit
    wait

    # Delete audio files
    for audio_file in "${audio_files[@]}"; do
        if rm -f -- "./$audio_file"; then
            echo "File '$audio_file' deleted successfully."
        else
            echo "Failed to delete file '$audio_file'."
        fi
    done

    # Delete playlist file
    if rm -f -- "./$playlist_file"; then
        echo "Playlist file '$playlist_file' deleted successfully."
    else
        echo "Failed to delete playlist file '$playlist_file'."
    fi
}

ytTempDownloadAndPlay() {
    local url=""
    local audio_file="audio.mp3"
    local vlc_params=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v)
                yt_dlp_options=""
                ;;
            --vlc)
                shift
                vlc_params="$1"
                ;;
            *)
                url="$1"
                ;;
        esac
        shift
    done

    # Check if URL is provided
    if [[ -z "$url" ]]; then
        echo "At least one valid yt URL is required."
        return 1
    fi

    # Download audio or video using yt-dlp
    if [[ -z "$yt_dlp_options" ]]; then
        yt-dlp "$url" -o "$audio_file"
    else
        yt-dlp -x --audio-format mp3 "$url" -o "$audio_file"
    fi

    if [[ -f "$audio_file" ]]; then
        if [[ -z "${vlc_params}" ]]; then
            # Play audio or video with minimized VLC by default
            vlc --play-and-exit --qt-start-minimized "$audio_file" vlc://quit &
        else
            vlc --play-and-exit $vlc_params "$audio_file" vlc://quit &
        fi

        # Wait for VLC to exit
        wait

        # Delete audio or video file
        if rm -i -- "$audio_file"; then
            echo "File deleted successfully."
        else
            echo "Failed to delete file."
        fi
    else
        echo "Invalid URL or error occurred while downloading."
    fi
}
alias tyt='tyt_func '

####################################################################################################
# Final
####################################################################################################
# Command prompt
. "${HOME}/.bashrc_local/prompt.sh"

# Cargo
if [[ -d  "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi

# nvm
if [[ -d  "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# Persist as much config as possible when switching to root
sudorc_func() {
    # Intended only for sshrc use
	local SSH_IP=$(echo $SSH_CLIENT | awk '{ print $1 }')
	local SSH2_IP=$(echo $SSH2_CLIENT | awk '{ print $1 }')
	if [ "$SSH2_IP" ] || [ "$SSH_IP" ] ; then
        export MY_HOME="${HOME}"
        sudo --preserve-env=MY_HOME -s <<EOF
if [[ ! -f /root/.bashrc.bak ]]; then
    mv /root/.bashrc /root/.bashrc.bak
fi
cat "${MY_HOME}"/.bashrc > /root/.bashrc
cp -a "${MY_HOME}"/.bashrc_local* /root
cp -a "${MY_HOME}"/.cargo  /root/
EOF
        sudo -i --preserve-env=TMUXDIR --preserve-env=TMUX_PLUGIN_MANAGER_PATH 
    else
        echo "Not in ssh shell, use sudo su"
    fi
}
alias sudorc='sudorc_func '

####################################################################################################
# Appended by 3rd party scripts (don't push)
####################################################################################################

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

