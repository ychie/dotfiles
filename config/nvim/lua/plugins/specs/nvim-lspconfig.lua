return {
    {
        "neovim/nvim-lspconfig",
        event = {
            "BufReadPre",
            "BufNewFile"
        },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            {
                "antosha417/nvim-lsp-file-operations",
                config = true
            }
        },
        config = function()
            local cmp_nvim_lsp = require("cmp_nvim_lsp")
            local capabilities = cmp_nvim_lsp.default_capabilities()

            local opts = { noremap = true, silent = true }
            local on_attach = function(_, bufnr)
                opts.bufnr = bufnr
            end

            require("lspconfig")["sourcekit"].setup({
                capabilities = capabilities,
                on_attach = on_attach
            })
        end
    }
}
