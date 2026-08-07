return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#090E13",
        dark_bg    = "#090E13",
        darker_bg  = "#090E13",
        lighter_bg = "#393B44",

        fg         = "#C5C9C7",
        dark_fg    = "#c4746e",
        light_fg   = "#c8c093",
        bright_fg  = "#A4A7A4",
        muted      = "#c4b28a",

        red        = "#c4746e",
        yellow     = "#c4b28a",
        orange     = "#a292a3",
        green      = "#8a9a7b",
        cyan       = "#8ea4a2",
        blue       = "#8ba4b0",
        purple     = "#a292a3",
        brown      = "#c4746e",

        bright_red    = "#e46876",
        bright_yellow = "#e6c384",
        bright_green  = "#87a987",
        bright_cyan   = "#7aa89f",
        bright_blue   = "#8ba4b0",
        bright_purple = "#938aa9",

        accent               = "#8ba4b0",
        cursor               = "#C5C9C7",
        foreground           = "#C5C9C7",
        background           = "#090E13",
        selection            = "#393B44",
        selection_foreground = "#C5C9C7",
        selection_background = "#393B44",
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
