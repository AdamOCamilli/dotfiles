#!/bin/zsh
####################################################################################################
# Preliminary
####################################################################################################
# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

ZSH_THEME="powerlevel10k/powerlevel10k"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# NOTE: need to edit ~/.p10k.zsh POWERLEVEL9K_LEFT_PROMPT_ELEMENTS section for further customization of prompt

export ZSH="${HOME}/.zsh"

####################################################################################################
# Plugins
####################################################################################################
# znap
if [[ ! -f ${ZSH}/plugins/znap/znap.zsh ]]; then
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git "${ZSH}/plugins/znap/"
fi
source "${ZSH}/plugins/znap/znap.zsh"

# powerlevel10k
if [[ ! -d ${ZSH}/themes/powerlevel10k ]]; then
    git clone --depth 1 -- https://github.com/romkatv/powerlevel10k.git "${ZSH}/themes/powerlevel10k/"
fi
source "${ZSH}/themes/powerlevel10k/powerlevel10k.zsh-theme"

#znap source marlonrichert/zsh-autocomplete
znap source zsh-users/zsh-autosuggestions

####################################################################################################
# Custom
####################################################################################################
export ZSH_CUSTOM="${ZSH}/custom"
# Get my custom aliases etc
source <(cat "${ZSH}/custom/"*.zsh)

# Speed up completion
#autoload -Uz compinit && compinit -C

####################################################################################################
# Prompt
####################################################################################################
# Adjust zsh prompt so newlines added except when shell launched or 'clear' executed
#FIRST_PROMPT=true
#precmd() {
#    if [[ "${FIRST_PROMPT}" = true ]]; then
#        unset FIRST_PROMPT
#    else
#        # Get the last command executed
#        local last_command=$(fc -ln -1)
#
#        # Check if the last command was 'clear' or 'reset'
#        if [[ "$last_command" != "clear" ]]; then
#            # If not, add a newline before showing the prompt
#            echo ""
#        fi
#    fi
#}

####################################################################################################
# Appended by 3rd party scripts (don't push)
####################################################################################################
# Cargo
if [[ -d  "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# nvm
if [[ -d  "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# Remove any previous homebrew PATH tokens
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v 'linuxbrew' | tr '\n' ':' | sed 's/:$//')
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

#zcompile .zshrc
#zcompile $ZSH_CUSTOM/*.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
