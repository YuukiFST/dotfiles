return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#1a1b1e",
        dark_bg    = "#2b2d31",
        darker_bg  = "#2b2d31",
        lighter_bg = "#505258",

        fg         = "#eaeaef",
        dark_fg    = "#ef5d67",
        light_fg   = "#f8f8fa",
        bright_fg  = "#ffffff",
        muted      = "#f7c553",

        red        = "#ef5d67",
        yellow     = "#f7c553",
        orange     = "#e29ef3",
        green      = "#8edb73",
        cyan       = "#7dd8d3",
        blue       = "#7ca5ff",
        purple     = "#e29ef3",
        brown      = "#ef5d67",

        bright_red    = "#ff7680",
        bright_yellow = "#ffd86f",
        bright_green  = "#a2ee8b",
        bright_cyan   = "#94e8e3",
        bright_blue   = "#7ca5ff",
        bright_purple = "#efb5f9",

        accent               = "#7ca5ff",
        cursor               = "#f2a0a0",
        foreground           = "#eaeaef",
        background           = "#1a1b1e",
        selection            = "#505258",
        selection_foreground = "#2b2d31",
        selection_background = "#b2c3ff",
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
