return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#101010",
        dark_bg    = "#000000",
        darker_bg  = "#000000",
        lighter_bg = "#9a9d9a",

        fg         = "#cecfc9",
        dark_fg    = "#d93f37",
        light_fg   = "#cecfc9",
        bright_fg  = "#ffffff",
        muted      = "#9a9d9a",

        red        = "#d93f37",
        yellow     = "#9a9d9a",
        orange     = "#d93f37",
        green      = "#9a9d9a",
        cyan       = "#9a9d9a",
        blue       = "#9a9d9a",
        purple     = "#d93f37",
        brown      = "#d93f37",

        bright_red    = "#da0f0f",
        bright_yellow = "#cecfc9",
        bright_green  = "#cecfc9",
        bright_cyan   = "#cecfc9",
        bright_blue   = "#9a9d9a",
        bright_purple = "#da0f0f",

        accent               = "#9a9d9a",
        cursor               = "#cecfc9",
        foreground           = "#cecfc9",
        background           = "#101010",
        selection            = "#9a9d9a",
        selection_foreground = "#101010",
        selection_background = "#cecfc9",
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
