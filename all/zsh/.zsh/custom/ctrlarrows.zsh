# https://unix.stackexchange.com/a/740599
# Enable Ctrl+arrow key bindings for word jumping
bindkey '^[[1;5C' forward-word     # Ctrl+right arrow
bindkey '^[[1;5D' backward-word    # Ctrl+left arrow

# Use vim word chars
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

