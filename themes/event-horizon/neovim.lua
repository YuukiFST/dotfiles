return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#1c1e26",
        dark_bg    = "#1c1e26",
        darker_bg  = "#1c1e26",
        lighter_bg = "#6c6f93",

        fg         = "#fadad1",
        dark_fg    = "#e95678",
        light_fg   = "#fadad1",
        bright_fg  = "#fadad1",
        muted      = "#fab795",

        red        = "#e95678",
        yellow     = "#fab795",
        orange     = "#ee64ac",
        green      = "#29d398",
        cyan       = "#59e3e3",
        blue       = "#26bbd9",
        purple     = "#ee64ac",
        brown      = "#e95678",

        bright_red    = "#ec6a88",
        bright_yellow = "#fbc3a7",
        bright_green  = "#3fdaa4",
        bright_cyan   = "#6be4e6",
        bright_blue   = "#26bbd9",
        bright_purple = "#f075b5",

        accent               = "#26bbd9",
        cursor               = "#fadad1",
        foreground           = "#fadad1",
        background           = "#1c1e26",
        selection            = "#6c6f93",
        selection_foreground = "#1c1e26",
        selection_background = "#26bbd9",
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
