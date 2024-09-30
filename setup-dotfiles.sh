#!/bin/bash
####################################################################################################
# Description: Replace dotfiles with symlinks
####################################################################################################

SCRIPT_DIR=$(realpath $(dirname "${BASH_SOURCE[0]}"))

# Error/warning strings for logging
log_error() {
    echo "ERROR: $0 $1" 2>&1
}
log_warn() {
    echo "WARNING: $0 $1" 2>&1
}

# Usage
usage () {
    echo "$0 : Setup for dotfiles"
    echo -e "\t-h | --help\tDisplay this message and exit"
    echo -e "\t-n | --dry-run\tDisplay what will we done but make no changes"
    echo -e "\t-r | --replace\tReplace dotfiles with symlinks, put old files into recovery dir"
    echo -e "\t-s | --root\tMake changes to /root/ dotfiles (requires sudo)"
}

# Process args
args="dhr"
dry_flag=""
replace_flag=""
root_flag=""
while [[ $# -gt 0 ]]; do
    case "${1}" in
        -*)
            arg_str="${1}"
            while [[ "${arg_str}" != "-" ]]; do
                if [[ "${arg_str}" == "-"*"h"* ]]; then
                    usage
                    exit 0
                elif [[ "${arg_str}" == "-"*"n"* ]]; then
                    dry_flag=1
                    arg_str="${arg_str//n}"
                elif [[ "${arg_str}" == "-"*"r"* ]]; then
                    replace_flag=1
                    arg_str="${arg_str//r}"
                elif [[ "${arg_str}" == "-"*"s"* ]]; then
                    root_flag=1
                    arg_str="${arg_str//s}"
                else
                    echo "${error_str} invalid flags \"${arg_str//-}\""
                    exit 1
                fi
            done
            shift;
    esac
done


# From https://stackoverflow.com/a/8574392
contains() {
    set +e
    local e match="$1"
    shift
    for e; do
        if [[ "$e" == "$match" ]]; then
            set -e
            echo "$e"
        fi
    done
    set -e
}

# Symlink function
link_target() {
    src="${1}"
    dest="${2}"

    # Check src
    if [[ ! -r "${src}" ]]; then
        log_error "${src} is not readable"
    else
        # Check dest if not replacing
        if [[ -z "${replace_flag}" ]]; then
            if [[ -L "${dest}" ]]; then
                if [[ ! -r "${dest}" ]]; then
                    log_warn "${dest} is a symlink but not readable, skipping"
                fi
            elif [[ ! -r "${dest}" ]]; then
                log_warn "${dest} is readable but not a symlink, skipping"
            fi
        fi
        if [[ -n "${dry_flag}" ]]; then
            if [[ ! -e "${dest}" ]]; then
                echo "mkdir -p \"$(dirname ${dest})\""
                echo "ln -sv \"${src}\" \"${dest}\""
            else
                if [[ -z "${RECOVERY_DIR}" ]]; then
                    RECOVERY_DIR="${SCRIPT_DIR}/temp_dotfiles_recovery_$(date +%s)"
                    echo "mkdir -p \"${RECOVERY_DIR}\""
                fi
                echo "mv \"${dest}\" \"${RECOVERY_DIR}\""
                echo "mkdir -p \"$(dirname ${dest})\""
                echo "ln -sv \"${src}\" \"${dest}\""
            fi
        else
            if [[ ! -e "${dest}" ]]; then
                mkdir -p "$(dirname ${dest})"
                ln -sv "${src}" "${dest}"
            else
                if [[ -z "${RECOVERY_DIR}" ]]; then
                    RECOVERY_DIR="${SCRIPT_DIR}/temp_dotfiles_recovery_$(date +%s)"
                    mkdir -p "${RECOVERY_DIR}"
                fi
                mv "${dest}" "${RECOVERY_DIR}"
                mkdir -p "$(dirname ${dest})"
                ln -sv "${src}" "${dest}"
            fi
        fi
    fi
}

pushd () {
    command pushd "$@" &>/dev/null
}

popd () {
    command popd "$@" &>/dev/null
}


# Set platform
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)
        if grep -qi microsoft /proc/version; then
            PLATFORM=WSL
        else
            PLATFORM=Linux
        fi
        ;;
    Darwin*)
        PLATFORM=Darwin
        ;;
    CYGWIN*)
        PLATFORM=Cygwin
        export CHERE_INVOKING=1
        ;;
    MINGW*)
        PLATFORM=Windows
        ;;
    *)
        PLATFORM="UNKNOWN"
        ;;
esac

# Don't link git files, OS-specific config files and setup scripts
LINK_EXCLUDES=(".git" "Linux" "WSL" "Cygwin" "Windows" "Darwin" "setup-*" "README.md")

if [[ "${PLATFORM}" == "UNKNOWN" ]]; then
    log_warn "unknown platform \"${PLATFORM}\" no OS specific symlinks will be created"
else
    # Non-platform based items
    pushd "${SCRIPT_DIR}"
    mapfile -t items < <(find . -maxdepth 1 -iwholename "./*" | sed 's|^\./||')
    for item in "${items[@]}"; do
        res=$(contains "${item}" "${LINK_EXCLUDES[@]}")
        if [[ -z "${res}" ]]; then
            link_target "${item}" "${HOME}/${item}"
        fi
    done
    # Platform-based items
    pushd "./${PLATFORM}"
    mapfile -t platform_items < <(find . -maxdepth 1 -iwholename "./*" | sed 's|^\./||')
    for platform_item in "${platform_items[@]}" ; do
        link_target "${platform_item}" "${HOME}/${platform_item}"
    done
    popd
    popd
fi
