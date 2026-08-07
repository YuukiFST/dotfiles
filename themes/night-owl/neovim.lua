return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#011627",
        dark_bg    = "#011627",
        darker_bg  = "#011627",
        lighter_bg = "#575656",

        fg         = "#d6deeb",
        dark_fg    = "#ef5350",
        light_fg   = "#d6deeb",
        bright_fg  = "#ffffff",
        muted      = "#c5e478",

        red        = "#ef5350",
        yellow     = "#c5e478",
        orange     = "#c792ea",
        green      = "#22da6e",
        cyan       = "#21c7a8",
        blue       = "#82aaff",
        purple     = "#c792ea",
        brown      = "#ef5350",

        bright_red    = "#ef5350",
        bright_yellow = "#ffeb95",
        bright_green  = "#22da6e",
        bright_cyan   = "#7fdbca",
        bright_blue   = "#82aaff",
        bright_purple = "#c792ea",

        accent               = "#82aaff",
        cursor               = "#80a4c2",
        foreground           = "#d6deeb",
        background           = "#011627",
        selection            = "#575656",
        selection_foreground = "#ffffff",
        selection_background = "#1d3b53",
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
