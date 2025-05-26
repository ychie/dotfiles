local function open_nvim_tree()
    -- open the tree
    require("nvim-tree.api").tree.open()
end

return {
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({
                open_on_tab = true,
                notify = {
                    threshold = vim.log.levels.WARN
                },
                view = {
                    width = 40,
                    relativenumber = true
                },
                renderer = {
                    indent_markers = {
                        enable = true
                    }
                },
                actions = {
                    open_file = {
                        quit_on_open = true,
                        window_picker = {
                            enable = false
                        }
                    }
                },
                git = {
                    ignore = true
                },
                update_focused_file = {
                    enable = true,
                    update_root = false
                }
            })
        end,
        keys = {
            {
                "<leader>a",
                "<cmd>NvimTreeToggle<CR>",
                desc = "nvim_tree: toggle"
            }
        }
    }
}
