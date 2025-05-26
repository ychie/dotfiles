return {
    {
        "nvim-telescope/telescope.nvim",
        config = function(_, opts)
            require("telescope").setup(opts)
        end,
        dependecies = {
            "nvim-lua/plenary.nvim"
        },
        keys = {
            {
                "<leader>pf",
                "<cmd>lua require('telescope.builtin').find_files()<CR>",
                desc = "telescope: find_files"
            },
            {
                "<leader>ps",
                "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input('Grep > ') })<CR>",
				desc = "telescope: find_words"
            }
        },
        cmd = {
            "Telescope"
        }
    }
}
