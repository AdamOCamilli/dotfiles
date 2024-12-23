# !/bin/bash
####################################################################################################
# Prompt
# Based on https://gist.github.com/zachbrowne/8bc414c9f30192067831fafebd14255c
#######################################################
function setprompt
{
	local LAST_COMMAND=$? # Must come first!

    ###########################################################################
    # Colors - see https://misc.flogisoft.com/bash/tip_colors_and_formatting
    ###########################################################################

    # Quick and dirty xterm/bash color explanation:
    #   "\["            - start group (needed when defining $PS1)
    #   "\033["         - start palette (\033 is C (and Bash) octal code for escape, "[..." basically runs command to directly modify terminal, e.g. "[2K" would erase current line)
    #                    " \<esc sequence>[" in general is a Control Sequence Inducer to initiate one of many ANSI defined control sequences.
    #   "XX;Y;ZZZ;"     - 256 color params, first three are foreground (text) color
    #   "XX;Y;ZZZ"      - 256 color params, second three are background color
    #   "m"             - Final byte
    #   "\]"            - end group (needed when defining $PS1)

    # Escape character to use
    local C_ESC="\033"

    # Formatting
    # Bold (or bright)
    local C_BOLD="${C_ESC}[1m"
    local C_DIM="${C_ESC}[2m"
    local C_UNDERLINE="${C_ESC}[4m"
    local C_BLINKING="${C_ESC}[5m"
    # Invert foreground/background colors
    local C_INVERTED="${C_ESC}[7m"
    local C_HIDDEN="${C_ESC}[8m"

    # Undo all formatting
    local C_NO_FORMAT="${C_ESC}[0m"
    # Undo specific formatting
    local C_BOLD_END="${C_ESC}[21m"
    local C_DIM_END="${C_ESC}[22m"
    local C_UNDERLINE_END="${C_ESC}[4m"
    local C_BLINKING_END="${C_ESC}[25m"
    local C_INVERTED_END="${C_ESC}[27m"
    local C_HIDDEN_END="${C_ESC}[28m"


	# text colors
	local C_WHITE="38;5;231"
	local C_BROWN="38;5;208"
    local C_GREEN="38;5;46"
	local RED="0;31"
	local LIGHTRED="1;31"
    local ORANGE="38;5;214"
    local GREEN="0;32"
	local YELLOW="1;33"
	local BLUE="0;34"
	local LIGHTBLUE="1;34"
	local MAGENTA="0;35"
	local LIGHTMAGENTA="1;35"
    local LIGHTPINK="38;5;213"
	local CYAN="0;36"
	local LIGHTCYAN="1;36"
	local NOCOLOR="0"
    # reset
    # Define highlights (background color)
    local BG_NONE="0"
    local BG_RED="48;5;196"

    # LS Colors
    # Remove background color when listing directories (from https://snippets.cacher.io/snippet/f437b0e713c1aea739c5)
    #LS_COLORS=$LS_COLORS:'di=0;36:'
    eval "$(dircolors ~/.bashrc_local/custom_dircolors)"
    bind 'set colored-stats on'
    bind 'set colored-completion-prefix on'

    PS1=""


	# SSH if applicable
	local SSH_IP=$(echo $SSH_CLIENT | awk '{ print $1 }')
	local SSH2_IP=$(echo $SSH2_CLIENT | awk '{ print $1 }')
	if [ "$SSH2_IP" ] || [ "$SSH_IP" ] ; then
        PS1+="\[${C_ESC}[${C_WHITE};${BG_RED}m\](SSH)\[${C_ESC}[${BG_NONE}m\]\[${C_ESC}[${C_WHITE}m\]-"
    fi
	# Date
    # PS1+="(\[${C_ESC}[${CYAN}m\]$(date +%a) $(date +%m/%d/%y)"
	# Time
	# PS1+="\[${C_ESC}[${LIGHTPINK}m\] $(date +'%-I':%M:%S%P)\[${C_ESC}[${C_WHITE}m\])-"

	# CPU
	# PS1+="(\[${C_ESC}[${LIGHTRED}m\]$(cpu)%"

	# Jobs
	# PS1+="\[${C_ESC}[${C_WHITE}m\]:\[${C_ESC}[${LIGHTRED}m\]\j"

	# Network Connections (for a server - comment out for non-server)
	# PS1+="\[${C_WHITE}m\]:\[${MAGENTA}m\]Net $(awk 'END {print NR}' /proc/net/tcp)"

	# PS1+="\[${C_ESC}[${C_WHITE}m\])-"

	# User
    PS1+="(\[${C_ESC}[${ORANGE}m\]\u@\h"

	# Current directory
	PS1+="\[${C_ESC}[${C_WHITE}m\]:\[${C_ESC}[${C_BROWN}m\]\w\[${C_ESC}[${C_WHITE}m\])-"

	# Total size of files in current directory
	PS1+="(\[${C_ESC}[${C_GREEN}m\]$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')\[${C_ESC}[${C_WHITE}m\]:"

	# Number of files
	PS1+="\[${C_ESC}[${C_GREEN}m\]\$(/bin/ls -A -1 | /usr/bin/wc -l)\[${C_ESC}[${C_WHITE}m\])"

	# Skip to the next line
	PS1+="\n\[${C_NO_FORMAT}\]"

    # Use '$' for normal user, '#' for root
	if [[ $EUID -ne 0 ]]; then
		PS1+="\[${C_ESC}[${C_WHITE}m\]\$\[${C_ESC}[${C_WHITE}m\] " # Normal user
	else
		PS1+="\[${C_ESC}[${RED}m\]#\[${C_ESC}[${C_WHITE}m\] " # Root user
	fi

	# PS2 is used to continue a command using the \ character
	PS2="\[${C_ESC}[${C_WHITE}m\]>\[${C_ESC}[${NOCOLOR}m\] "

	# PS3 is used to enter a number choice in a script
	PS3='Please enter a number from above list: '

	# PS4 is used for tracing a script in debug mode
	PS4='\[${C_ESC}[${C_WHITE}m\]+\[${C_ESC}[${NOCOLOR}m\] '
}

PROMPT_COMMAND='setprompt'
