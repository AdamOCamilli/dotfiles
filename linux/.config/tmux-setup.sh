sudo apt install tmux

if command -v pip; then
    pip install powerline-status
fi

if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    mkdir -p $TMUX_PLUGIN_MANAGER_PATH
    git clone https://github.com/tmux-plugins/tpm $TMUX_PLUGIN_MANAGER_PATH/tpm
fi

