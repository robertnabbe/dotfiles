return {
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      opts.colorschemes = opts.colorschemes or {}

      -- filter out nvim default themes
      opts.colorschemes.ignore_patterns = {
        "^blue$",
        "^darkblue$",
        "^delek$",
        "^desert$",
        "^elflord$",
        "^evening$",
        "^industry$",
        "^koehler$",
        "^morning$",
        "^murphy$",
        "^pelflord$",
        "^ron$",
        "^shine$",
        "^slate$",
        "^torte$",
        "^zellner$",
        "^quiet$",
        "^habamax$",
        "^lunaperche$",
      }

      return opts
    end,
  },
}
