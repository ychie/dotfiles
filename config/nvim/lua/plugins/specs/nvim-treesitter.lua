return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = {
            "BufReadPost",
            "User FilePost"
        },
        build = ":TSUpdate",
        config = function()
           require("nvim-treesitter.configs").setup({
               incremental_selection = {
                   enable = false,
                   keymaps = {
                       scope_incremental = "a",
                       node_decremental = "z"
                   }
               },
               highlight = {
                   enable = true
               },
               ensure_installed = {
                   "xml",
                   "json",
                   "yaml",
                   "toml",

                   "lua",
                   "rust",

                   "c",
                   "cpp",

                   "objc",
                   "swift",

                   "markdown",
                   "gitignore"
               },
               auto_install = true
           })
        end
    }
}
