return {
    {
      "mfussenegger/nvim-lint",
      optional = true,
      opts = {
        linters_by_ft = {
          -- Overwrite markdown to be empty, disabling markdownlint entirely
          markdown = {},
        },
      },
    },
  }
