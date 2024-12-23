#!/bin/sh

###########################################################################
# Required system-wide installs
###########################################################################
sudo apt-get install lua5.4 npm ripgrep universal-ctags
sudo npm install -g vim-language-server

###########################################################################
# Set up nvim config (https://github.com/jdhao/nvim-config)
###########################################################################
# Fall back to ${HOME}/.config if XDG_CONFIG_HOME undefined
pushd "${XDG_CONFIG_HOME:-${HOME}/.config}"
if [[ -d ./nvim ]]; then
    mv "./nvim" "./nvim_backup_$(date +%s)"
fi
mkdir nvim && cd nvim
git clone --depth=1 https://github.com/jdhao/nvim-config.git .
# Don't use deprecated branches
sed -i s/"canary"/"main"/gp lua/plugin_specs.lua

###########################################################################
# Build with custom python env
###########################################################################
python -m venv venv
source venv/bin/activate

# Install required packages using pip
pip install --upgrade pip
pip install pynvim 'python-lsp-server[all]' pylsp-mypy python-lsp-isort python-lsp-black pylint flake8 vint pyright
echo "Installing nvim plugins, please wait"
nvim -c "autocmd User LazyInstall quitall"  -c "lua require('lazy').install()"

deactivate

###########################################################################
# Add customizations
###########################################################################
# Old vimrc
cp -v ${HOME}/.vimrc ./viml_conf/adam_vimrc.vim
# Some QOL changes for neovim
cat << EOF >> init.lua
--
-- Adam's customization
--

-- My vimrc
vim.cmd("source ".. vim.fs.joinpath(config_dir, "viml_conf/adam_vimrc.vim"))

-- Space leader key
vim.g.mapleader = " "

-- Set the terminal to use true colors
vim.opt.termguicolors = true
-- Decent colorscheme by default
vim.cmd("colorscheme default")
-- Function to set transparent background
function set_transparency()
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "NonText", { bg = "NONE", ctermbg = "NONE" })
end
-- Call the function initially
set_transparency()
-- Autocommand to reapply transparency when colorscheme changes
vim.cmd [[
    augroup Transparency
        autocmd!
        autocmd ColorScheme * lua set_transparency()
    augroup END
]]
-- Enable line wrapping
vim.opt.wrap = true               -- Enable line wrapping
vim.opt.linebreak = true          -- Break lines at word boundaries
vim.opt.textwidth = 0             -- Disable automatic line breaking on text width
-- Set the path to the Python interpreter in your venv
vim.env.VIRTUAL_ENV = '~/.config/nvim/venv/'
vim.g.python3_host_prog = vim.loop.os_homedir() .. "~/.config/nvim/venv/bin/python"

-- Tab to switch buffers
vim.keymap.set('n', '<Tab>', ':bn<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', ':bp<CR>', { noremap = true, silent = true })

-- Map <leader>q to delete the current buffer
vim.keymap.set('n', '<leader>q', ':bd<CR>', { noremap = true, silent = true })

require("nvim-tree").setup({
  update_focused_file = {
    enable = true,
    update_root = true
  },
})
EOF

###########################################################################
# Cleanup
###########################################################################
popd
