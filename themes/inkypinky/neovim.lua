return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#13131D",
        dark_bg    = "#13131D",
        darker_bg  = "#13131D",
        lighter_bg = "#434353",

        fg         = "#c8c8c8",
        dark_fg    = "#EA90A8",
        light_fg   = "#a1a2a7",
        bright_fg  = "#c8c8c8",
        muted      = "#D18BA2",

        red        = "#EA90A8",
        yellow     = "#D18BA2",
        orange     = "#9f859f",
        green      = "#a6b2c7",
        cyan       = "#919ab7",
        blue       = "#7c7ca8",
        purple     = "#9f859f",
        brown      = "#EA90A8",

        bright_red    = "#f6bfce",
        bright_yellow = "#e3aebf",
        bright_green  = "#d1d9e4",
        bright_cyan   = "#d2d7e3",
        bright_blue   = "#7c7ca8",
        bright_purple = "#bfadbf",

        accent               = "#7c7ca8",
        cursor               = "#c8c8c8",
        foreground           = "#c8c8c8",
        background           = "#13131D",
        selection            = "#434353",
        selection_foreground = "#13131D",
        selection_background = "#c8c8c8",
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
