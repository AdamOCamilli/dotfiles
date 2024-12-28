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


###########################################################################
# Add LaTeX live preview
###########################################################################
if command -v pdflatex &> /dev/null; then
    # Required software
    sudo apt install falkon pandoc sioyek

    # Add to lazy nvim
    # insert after line contaning "local plugin_specs= {"
    cat <<'EOF' | sed -i "$(sed -n '/local plugin_specs = {/=' lua/plugin_specs.lua)r /dev/stdin" lua/plugin_specs.lua
  -- Use knap for LaTeX live previewing
  {
    "frabjous/knap",
    enabled = function()
      if utils.executable("latex") then
        return true
      end
      return false
    end,
    ft = { "tex" },
  },
EOF

    # Add preferred settings
    cat <<'EOF' >> viml_conf/knap.vim
""""""""""""""""""""""""""""knap/vimtex settings"""""""""""""""""""""""""""""
if executable('latex')
  " Set keybindings for knap per dev's recommendations
  """"""""""""""""""
  " KNAP functions "
  """"""""""""""""""
  " F5 processes the document once, and refreshes the view "
  inoremap <silent> <F5> <C-o>:lua require("knap").process_once()<CR>
  vnoremap <silent> <F5> <C-c>:lua require("knap").process_once()<CR>
  nnoremap <silent> <F5> :lua require("knap").process_once()<CR>

  " F6 closes the viewer application, and allows settings to be reset "
  inoremap <silent> <F6> <C-o>:lua require("knap").close_viewer()<CR>
  vnoremap <silent> <F6> <C-c>:lua require("knap").close_viewer()<CR>
  nnoremap <silent> <F6> :lua require("knap").close_viewer()<CR>

  " F7 toggles the auto-processing on and off "
  inoremap <silent> <F7> <C-o>:lua require("knap").toggle_autopreviewing()<CR>
  vnoremap <silent> <F7> <C-c>:lua require("knap").toggle_autopreviewing()<CR>
  nnoremap <silent> <F7> :lua require("knap").toggle_autopreviewing()<CR>

  " F8 invokes a SyncTeX forward search, or similar, where appropriate "
  inoremap <silent> <F8> <C-o>:lua require("knap").forward_jump()<CR>
  vnoremap <silent> <F8> <C-c>:lua require("knap").forward_jump()<CR>
  nnoremap <silent> <F8> :lua require("knap").forward_jump()<CR>

  let g:knap_settings = {
  \   "htmloutputext": "html",
  \   "htmltohtml": "none",
  \   "htmltohtmlviewerlaunch": "falkon %outputfile%",
  \   "htmltohtmlviewerrefresh": "none",
  \   "mdoutputext": "html",
  \   "mdtohtml": "pandoc --standalone %docroot% -o %outputfile%",
  \   "mdtohtmlviewerlaunch": "falkon %outputfile%",
  \   "mdtohtmlviewerrefresh": "none",
  \   "mdtopdf": "pandoc %docroot% -o %outputfile%",
  \   "mdtopdfviewerlaunch": "sioyek %outputfile%",
  \   "mdtopdfviewerrefresh": "none",
  \   "markdownoutputext": "html",
  \   "markdowntohtml": "pandoc --standalone %docroot% -o %outputfile%",
  \   "markdowntohtmlviewerlaunch": "falkon %outputfile%",
  \   "markdowntohtmlviewerrefresh": "none",
  \   "markdowntopdf": "pandoc %docroot% -o %outputfile%",
  \   "markdowntopdfviewerlaunch": "sioyek %outputfile%",
  \   "markdowntopdfviewerrefresh": "none",
  \   "texoutputext": "pdf",
  \   "textopdf": "pdflatex -interaction=batchmode -halt-on-error -synctex=1 %docroot%",
  \   "textopdfviewerlaunch": "sioyek --inverse-search 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%1'\"'\"',%2,%3)\"' --new-window %outputfile%",
  \   "textopdfviewerrefresh": "none",
  \   "textopdfforwardjump": "sioyek --inverse-search 'nvim --headless -es --cmd \"lua require('\"'\"'knaphelper'\"'\"').relayjump('\"'\"'%servername%'\"'\"','\"'\"'%1'\"'\"',%2,%3)\"' --reuse-window --forward-search-file %srcfile% --forward-search-line %line% %outputfile%",
  \   "textopdfshorterror": "A=%outputfile% ; LOGFILE=\"${A%.pdf}.log\" ; rubber-info \"$LOGFILE\" 2>&1 | head -n 1",
  \   "delay": 250
  \ }
endif
EOF
fi

###########################################################################
# Add required extra config
###########################################################################
cat << EOF >> init.lua
--
-- ${USER}'s required additions
--

-- knap settings for latex live preview
vim.cmd("source ".. vim.fs.joinpath(config_dir, "viml_conf/knap.vim"))

-- Set the path to the Python interpreter in your venv
vim.env.VIRTUAL_ENV = '~/.config/nvim/venv/'
vim.g.python3_host_prog = vim.loop.os_homedir() .. "/.config/nvim/venv/bin/python"

require("nvim-tree").setup({
  update_focused_file = {
    enable = true,
    update_root = true
  },
})

EOF

###########################################################################
# Add QOL extras
###########################################################################
if [[ -f ${HOME}/.vimrc ]]; then
    cp -v ${HOME}/.vimrc ./viml_conf/${USER}_vimrc.vim
fi
# Some QOL changes for neovim
cat << EOF >> init.lua
--
-- ${USER}'s customization
--

-- User vimrc
vim.cmd("source ".. vim.fs.joinpath(config_dir, "viml_conf/${USER}_vimrc.vim"))

-- knap settings for latex live preview
vim.cmd("source ".. vim.fs.joinpath(config_dir, "viml_conf/knap.vim"))

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

-- Tab to switch buffers
vim.keymap.set('n', '<Tab>', ':bn<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', ':bp<CR>', { noremap = true, silent = true })

-- Map <leader>q to delete the current buffer
vim.keymap.set('n', '<leader>q', ':bd<CR>', { noremap = true, silent = true })

EOF

###########################################################################
# Cleanup
###########################################################################
deactivate
popd
