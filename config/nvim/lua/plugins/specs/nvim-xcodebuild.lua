return {
    {
        "ychie/xcodebuild.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
            "j-hui/fidget.nvim",
        },
        config = function()
            require("xcodebuild").setup({
                guess_scheme = true,
                show_build_progress_bar = true,
                commands = {
                    focus_simulator_on_app_launch = false
                },
                logs = {
                    auto_open_on_success_tests = true,
                    auto_open_on_failed_tests = true,
                    auto_open_on_success_build = true,
                    auto_open_on_failed_build = true,
                    auto_close_on_app_launch = true,
                    auto_focus = false,
                    only_summary = true,
                    notify = function(message, severity)
                        local fidget = require("fidget")
                        if progress_handle then
                            progress_handle.message = message
                            if not message:find("Loading") then
                                progress_handle:finish()
                                progress_handle = nil
                                if vim.trim(message) ~= "" then
                                    fidget.notify(message, severity)
                                end
                            end
                        else
                            fidget.notify(message, severity)
                        end
                    end,
                    notify_progress = function(message)
                        local progress = require("fidget.progress")
                        if progress_handle then
                            progress_handle.title = ""
                            progress_handle.message = message
                        else
                            progress_handle = progress.handle.create({
                                message = message,
                                lsp_client = {
                                    name = "xcodebuild.nvim"
                                }
                            })
                        end
                    end
                },
                code_coverage = {
                    enabled = true
                }
            })
        end,
        keys = {
            {
                "<leader>xb",
                "<cmd>XcodebuildBuild<CR>",
                desc = "xcodebuild: build"
            },
            {
                "<leader>xr",
                "<cmd>XcodebuildBuildRun<CR>",
                desc = "xcodebuild: buld and run"
            },
            {
                "<leader>xt",
                "<cmd>XcodebuildTestTarget<CR>",
                desc = "xcodebuild: test current target"
            },
            {
                "<leader>X",
                "<cmd>XcodebuildPicker<CR>",
                desc = "xcodebuild: picker"
            },
            {
                "<leader>xd",
                "<cmd>XcodebuildSelectDevice<CR>",
                desc = "xcodebuild: select device"
            }
        }
    }
}
