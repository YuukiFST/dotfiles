return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#000000",
        dark_bg    = "#000000",
        darker_bg  = "#000000",
        lighter_bg = "#1A1A1A",

        fg         = "#FEFEFE",
        dark_fg    = "#FEFEFE",
        light_fg   = "#FEFEFE",
        bright_fg  = "#F5F5F5",
        muted      = "#CFCFCF",

        red        = "#FEFEFE",
        yellow     = "#CFCFCF",
        orange     = "#BDBDBD",
        green      = "#BDBDBD",
        cyan       = "#BDBDBD",
        blue       = "#BDBDBD",
        purple     = "#BDBDBD",
        brown      = "#FEFEFE",

        bright_red    = "#F5F5F5",
        bright_yellow = "#CFCFCF",
        bright_green  = "#BDBDBD",
        bright_cyan   = "#BDBDBD",
        bright_blue   = "#BDBDBD",
        bright_purple = "#BDBDBD",

        accent               = "#BDBDBD",
        cursor               = "#FEFEFE",
        foreground           = "#FEFEFE",
        background           = "#000000",
        selection            = "#1A1A1A",
        selection_foreground = "#FEFEFE",
        selection_background = "#2B2B2B",
      },
    },
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
