local v = vim

------------------------------------------------------------------------------
----------------------------------- OPTIONS ----------------------------------
------------------------------------------------------------------------------
local o = v.opt
local g = v.g
v.scriptencoding = "utf-8"
o.encoding = "utf-8"
o.fileencoding = "utf-8"
o.relativenumber = true
o.title = true
o.autoindent = true
o.smartindent = true
o.hlsearch = false
o.showcmd = true
o.cmdheight = 1
o.laststatus = 2
o.expandtab = true
o.scrolloff = 10
o.shell = "zsh"
o.ignorecase = true
o.smarttab = true
o.breakindent = true
o.shiftwidth = 4
-- Make splits below and to the right
o.splitbelow = true
o.splitright = true
o.tabstop = 4
-- Don't wrap lines
o.wrap = false
o.backspace = "start,eol,indent"
o.colorcolumn = "79"
-- Search into subfolders
o.path:append({ "**" })
o.cursorline = false
o.signcolumn = "yes"
o.termguicolors = true
-- Display completion matches using popup menu
o.wildoptions = "pum"
o.background = "dark"
-- o.t_Co=256
-- Enable mouse
o.mouse = "a"
-- Always display tabline
o.showtabline = 2
o.clipboard:append({ "unnamedplus" }) -- Share system clipboard
-- Change Directory automatically when we switch files/buffers
o.autochdir = true
-- Persistent undos, even after closing vim, how cool
local xdg_config_path = os.getenv("XDG_DATA_HOME")
o.undofile = true
o.undodir = xdg_config_path .. "/nvim/undodir"
-- Enable file backups
o.backup = true
o.backupdir = xdg_config_path .. "/nvim/backupdir"
-- Autocompletion
o.completeopt = "menu,menuone,noselect"
-- -- Ultisnips
-- Required for ultisnips
g.loaded_python_provider = 1
g.python_host_skip_check = 1
g.python_host_prog = "/usr/bin/python3"
g.python3_host_prog = "/usr/bin/python3"
g.python3_host_skip_check = 1
v.g.tmux_navigator_no_mappings = 1
-- kdb+/q custom filetype
v.cmd([[
    augroup filetypedetect
      au! BufRead,BufNewFile *.k		setfiletype k
      au! BufRead,BufNewFile *.q		setfiletype q
    augroup END
]])
------------------------------------------------------------------------------
--------------------------------- PLUGINS ------------------------------------
------------------------------------------------------------------------------
local lazypath = v.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not v.loop.fs_stat(lazypath) then
    v.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
v.opt.rtp:prepend(lazypath)
require("lazy").setup({
    -- Colorschemes --
    {
        "cocopon/iceberg.vim",
        lazy = false,
        priority = 1000,
        config = function()
            v.cmd([[colorscheme iceberg]])
        end,
    },
    -- Status and buffer lines --
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        config = function()
            require("lualine").setup({
                enable = true,
                options = {
                    component_separators = "",
                    -- section_separators = { left = "", right = "" },
                    section_separators = "",
                },
            })
        end,
        dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
    },
    {
        "akinsho/bufferline.nvim",
        config = function()
            require("bufferline").setup({})
        end,
    },
    -- Treesitter --
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                ensure_installed = {
                    "markdown",
                    "lua",
                    "python",
                    "vimdoc",
                    "c",
                    "cpp",
                    "json",
                    "julia",
                    "bash",
                    "bibtex",
                    "html",
                    "r",
                    "yaml",
                },
                auto_install = true,
                highlight = {
                    enable = true,
                    disable = { "latex", "ledger" },
                },
            })
        end,
    },
    { "mbbill/undotree" },
    -- Autopairs --
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },
    -- Fzf --
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("fzf-lua").register_ui_select() -- Set fzf-lua as the default picker
        end,
    },
    {
        "elihunter173/dirbuf.nvim",
        config = function()
            require("dirbuf").setup({})
        end,
    },
    -- Cmp --
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            -- "quangnguyen30192/cmp-nvim-ultisnips",
        },
        config = function()
            local cmp_status_ok, cmp = pcall(require, "cmp")
            if not cmp_status_ok then
                return
            end
            local kind_icons = {
                Text = "",
                Method = "m",
                Function = "",
                Constructor = "",
                Field = "",
                Variable = "",
                Class = "",
                Interface = "",
                Module = "",
                Property = "",
                Unit = "",
                Value = "",
                Enum = "",
                Keyword = "",
                Snippet = "",
                Color = "",
                File = "",
                Reference = "",
                Folder = "",
                EnumMember = "",
                Constant = "",
                Struct = "",
                Event = "",
                Operator = "",
                TypeParameter = "",
            }
            cmp.setup({
                -- snippet = {
                --     expand = function(args)
                --         vim.fn["UltiSnips#Anon"](args.body)
                --     end,
                -- },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                }),
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        -- Kind icons
                        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
                        vim_item.menu = ({
                            buffer = "[Buffer]",
                            path = "[Path]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
                sources = {
                    -- { name = "ultisnips" },
                    { name = "path" },
                    { name = "nvim_lsp" },
                    { name = "buffer",  keyword_length = 3 },
                },
                confirm_opts = {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                },
                experimental = {
                    ghost_text = false,
                    native_menu = false,
                },
            })
        end,
    },
    -- Lsp --
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            local mason_status_ok, mason = pcall(require, "mason")
            if not mason_status_ok then
                return
            end
            mason.setup()
            local mason_lsp_config_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
            if not mason_lsp_config_status_ok then
                return
            end
            mason_lspconfig.setup({
                ensure_installed = {
                    "lua_ls",
                    "jedi_language_server",
                    "html",
                    "cssls",
                    "jsonls",
                    "jdtls",
                },
                automatic_installation = true, -- All servers setup with lspconfig are automatically installed
            })
            local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
            if not lspconfig_status_ok then
                return
            end
            lspconfig.lua_ls.setup({})
            lspconfig.html.setup({})
            lspconfig.cssls.setup({})
            lspconfig.jedi_language_server.setup({})
            lspconfig.jsonls.setup({})
            lspconfig.jdtls.setup({})
            require("lspconfig.ui.windows").default_options.border = "single"
        end,
    },
    -- Null-ls --
    {
        "jay-babu/mason-null-ls.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "nvim-lua/plenary.nvim",
            "jose-elias-alvarez/null-ls.nvim",
        },
        config = function()
            local null_ls_status_ok, null_ls = pcall(require, "null-ls")
            if not null_ls_status_ok then
                return
            end
            local b = null_ls.builtins
            local sources = {
                b.formatting.black,
                b.diagnostics.flake8.with({ extra_args = { "--max-line-length", 99 } }),
                b.formatting.fixjson,
                b.formatting.stylua,
                b.formatting.shfmt,
                b.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
            }
            null_ls.setup({
                debug = true,
                sources = sources,
            })
            require("mason-null-ls").setup({
                ensure_installed = nil,
                automatic_installation = true,
                automatic_setup = false,
            })
        end,
    },
    -- Nvim Surround --
    {
        "kylechui/nvim-surround",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    -- Comments --
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup({})
        end,
    },
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },
    {
        "ziontee113/icon-picker.nvim",
        config = function()
            require("icon-picker").setup({
                disable_legacy_commands = true,
            })
        end,
    },
    { "christoomey/vim-tmux-navigator" },
    {
        "SirVer/ultisnips",
        ft = { "tex", "plaintex", "ledger" },
        init = function()
            v.g.UltiSnipsSnippetDirectories = { "ultisnippets" }
            v.g.UltiSnipsExpandTrigger = "<C-o>"
            v.g.UltiSnipsJumpForwardTrigger = "<C-j>"
            v.g.UltiSnipsJumpBackwardTrigger = "<C-k>"
        end,
        config = function()
            v.keymap.set("n", "<leader>S", ":UltiSnipsEdit<CR>")
        end,
    },
    {
        "lervag/vimtex",
        ft = { "tex", "plaintex" },
        init = function()
            v.g.vimtex_view_method = "zathura"
        end,
        config = function()
            v.keymap.set("n", "<leader>E", ":VimtexErrors<CR>")
            v.keymap.set("n", "<leader>C", ":w<CR>:VimtexCompile<CR>")
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        tag = "v0.8.1",
        event = "BufReadPre",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local gitsigns_status_ok, gitsigns = pcall(require, "gitsigns")
            if not gitsigns_status_ok then
                return
            end
            gitsigns.setup({
                on_attach = function(bufnr)
                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        v.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map("n", "]h", function()
                        if v.wo.diff then
                            v.cmd.normal({ "]h", bang = true })
                        else
                            gitsigns.nav_hunk("next")
                        end
                    end)
                    map("n", "[h", function()
                        if v.wo.diff then
                            v.cmd.normal({ "[h", bang = true })
                        else
                            gitsigns.nav_hunk("prev")
                        end
                    end)
                    -- Actions
                    map("n", "<leader>hs", gitsigns.stage_hunk)
                    map("n", "<leader>hr", gitsigns.reset_hunk)
                    map("v", "<leader>hs", function()
                        gitsigns.stage_hunk({ v.fn.line("."), v.fn.line("v") })
                    end)
                    map("v", "<leader>hr", function()
                        gitsigns.reset_hunk({ v.fn.line("."), v.fn.line("v") })
                    end)
                    map("n", "<leader>hS", gitsigns.stage_buffer)
                    map("n", "<leader>hu", gitsigns.undo_stage_hunk)
                    map("n", "<leader>hR", gitsigns.reset_buffer)
                    map("n", "<leader>hp", gitsigns.preview_hunk)
                    map("n", "<leader>hb", function()
                        gitsigns.blame_line({ full = true })
                    end)
                    map("n", "<leader>hd", gitsigns.diffthis)
                    map("n", "<leader>hD", function()
                        gitsigns.diffthis("~")
                    end)
                    map("n", "<leader>td", gitsigns.toggle_deleted)
                    -- Text object
                    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
                end,
            })
        end,
    },
})

------------------------------------------------------------------------------
--------------------------------- MAPPINGS -----------------------------------
------------------------------------------------------------------------------
v.g.mapleader = " "
local keymap = v.keymap
keymap.set("n", "<C-l>", ":bnext<CR>")
keymap.set("n", "<C-h>", ":bprevious<CR>")
keymap.set("n", "<C-q>", ":bd!<CR>")
keymap.set("i", "jj", "<Esc>:w<CR>") -- Exit insert mode and save
-- Better indentation
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
-- Enable spelling
keymap.set("n", "<leader>ss", ":setlocal spell! spelllang=en_gb<CR>")
-- Correct last spelling mistake
keymap.set("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u")
-- Better macros
keymap.set("n", "Q", "@q")
-- Fuzzy Finding
-- Search all files in home directory not excluded by .fdignore
keymap.set("n", "<leader>f", ":lua require('fzf-lua').files({ cwd = '~/' })<CR>")
-- Search recent files
keymap.set("n", "<leader>o", ":FzfLua oldfiles<CR>")
-- Search all files in project
keymap.set("n", "<leader>p", ":lua require('fzf-lua').files()<CR>")
-- Ripgrep Current Project
keymap.set("n", "<leader>R", ":FzfLua grep_project<CR>")
keymap.set("n", "<leader>/", ":FzfLua grep_curbuf<CR>")
-- Change color theme
keymap.set("n", "<leader>t", ":FzfLua colorschemes<CR>")
-- Undotree
keymap.set("n", "<leader>u", ":UndotreeToggle<CR>:UndotreeFocus<CR>")
-- Icon picker
keymap.set("i", "<M-e>", "<Esc>:IconPickerInsert<CR>i")
-- Tmux navigator mappings
keymap.set("n", "<M-h>", ":TmuxNavigateLeft<CR>")
keymap.set("n", "<M-l>", ":TmuxNavigateRight<CR>")
keymap.set("n", "<M-j>", ":TmuxNavigateDown<CR>")
keymap.set("n", "<M-k>", ":TmuxNavigateUp<CR>")
-- LSP Mappings
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
keymap.set("n", "<space>e", v.diagnostic.open_float)
keymap.set("n", "[d", v.diagnostic.goto_prev)
keymap.set("n", "]d", v.diagnostic.goto_next)
keymap.set("n", "<space>q", v.diagnostic.setloclist)
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
v.api.nvim_create_autocmd("LspAttach", {
    group = v.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        v.bo[ev.buf].omnifunc = "v:lua.v.lsp.omnifunc"

        -- Buffer local mappings.
        -- See `:help v.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        keymap.set("n", "gD", v.lsp.buf.declaration, opts)
        keymap.set("n", "gd", v.lsp.buf.definition, opts)
        keymap.set("n", "K", v.lsp.buf.hover, opts)
        keymap.set("n", "gi", v.lsp.buf.implementation, opts)
        keymap.set("i", "<C-k>", v.lsp.buf.signature_help, opts)
        keymap.set("n", "<space>wa", v.lsp.buf.add_workspace_folder, opts)
        keymap.set("n", "<space>wr", v.lsp.buf.remove_workspace_folder, opts)
        keymap.set("n", "<space>wl", function()
            print(v.inspect(v.lsp.buf.list_workspace_folders()))
        end, opts)
        keymap.set("n", "<space>D", v.lsp.buf.type_definition, opts)
        keymap.set("n", "<space>r", v.lsp.buf.rename, opts)
        keymap.set("n", "<space>c", v.lsp.buf.code_action, opts)
        keymap.set("n", "gr", v.lsp.buf.references, opts)
        keymap.set("n", "<space>m", function()
            v.lsp.buf.format({ async = true })
        end, opts)
    end,
})
