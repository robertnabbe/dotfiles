local map = vim.keymap.set

-- Buffer management
map("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprev<CR>", { desc = "Previous buffer" })

-- neotree
map("n", "<leader>e", ":Neotree toggle<CR>", {})
