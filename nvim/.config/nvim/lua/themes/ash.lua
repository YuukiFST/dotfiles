return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#121212",
        dark_bg    = "#0d0d0d",
        darker_bg  = "#080808",
        lighter_bg = "#212121",

        fg         = "#e0e0e0",
        dark_fg    = "#adadad",
        light_fg   = "#eaeaea",
        bright_fg  = "#fafafa",
        muted      = "#5a5a5a",

        red        = "#8a8a8a",
        yellow     = "#9e9e9e",
        orange     = "#949494",
        green      = "#767676",
        cyan       = "#767676",
        blue       = "#626262",
        purple     = "#8a8a8a",
        brown      = "#545454",

        bright_red    = "#9e9e9e",
        bright_yellow = "#b2b2b2",
        bright_green  = "#767676",
        bright_cyan   = "#9e9e9e",
        bright_blue   = "#626262",
        bright_purple = "#8a8a8a",

        accent               = "#626262",
        cursor               = "#e0e0e0",
        foreground           = "#e0e0e0",
        background           = "#121212",
        selection            = "#212121",
        selection_foreground = "#e0e0e0",
        selection_background = "#212121",
      },
    },
    -- set up hot reload
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
      require("aether.hotreload").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
