-- Check out https://github.com/nvim-lua/kickstart.nvim !

-- Aesthetic: Omarchy theme (aether.nvim) loads via packer in after/plugin/plugins.lua
require('me.options')
require('me.globals')
require('me.lualine')
require('me.keymap')
require('me.lsp')
require('me.telescope')
require 'colorizer'.setup()
