return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#101315",
        dark_bg    = "#101315",
        darker_bg  = "#101315",
        lighter_bg = "#4b4e55",

        fg         = "#cacccc",
        dark_fg    = "#565d60",
        light_fg   = "#cbc2be",
        bright_fg  = "#a5aeb4",
        muted      = "#d9dbdc",

        red        = "#565d60",
        yellow     = "#d9dbdc",
        orange     = "#aeaeae",
        green      = "#9fa5a9",
        cyan       = "#707070",
        blue       = "#798186",
        purple     = "#aeaeae",
        brown      = "#565d60",

        bright_red    = "#de6145",
        bright_yellow = "#c9c2b4",
        bright_green  = "#343d41",
        bright_cyan   = "#707070",
        bright_blue   = "#798186",
        bright_purple = "#9a9a9a",

        accent               = "#798186",
        cursor               = "#cacccc",
        foreground           = "#cacccc",
        background           = "#101315",
        selection            = "#4b4e55",
        selection_foreground = "#101315",
        selection_background = "#798186",
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
