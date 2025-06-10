return {
  lazy_treesitter_ensure_installed {
    "bash",
    "diff",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "ini",
  },

  {
    "theprimeagen/git-worktree.nvim",
    keys = {
      { "<leader>gw", "<cmd>Telescope git_worktree<cr>", desc = "Search worktrees" },
      { "<leader>gW", function() require("telescope").extensions.git_worktree.create_git_worktree() end, desc = "Create worktree" },
    },
  },

  { "lewis6991/gitsigns.nvim",
    about = "Git signs for the gutter and LSP code actions.",
    enabled = false,
    event = "BufReadPre",
    opts = {
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        interval = 1000,
        follow_files = true
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Hunk mappings:
        map("n", "]h", gs.next_hunk, "Next Git hunk")
        map("n", "[h", gs.prev_hunk, "Prev Git hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>ghd", gs.diffthis, "Diff this")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")

        -- Buffer mappings:
        map("n", "<leader>gm", gs.toggle_current_line_blame, "Toggle blame")
        map("n", "<leader>guS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>guR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>guU", gs.reset_buffer_index, "Reset buffer index")
      end,
    },
  },

  { "tpope/vim-fugitive",
    about = "Classy Git integration for Vim.",
    cmd = {
      "Git", "G", -- call arbitrary git commit, or show status by default
      "Gedit", "Gsplit", -- view any blob, tree, commit, or tag
      "Gdiffsplit", "Gvdiffsplit", "Ghdiffsplit", -- diff staged version with buffer
      "Gread", -- reset on current buffer
      "Gwrite", -- stage current buffer
      "Ggrep", "Glgrep",
      "GMove", "GRename", "GDelete", "GRemove",
      "GBrowse",
    },
    keys = {
      { "<leader>gS", "<cmd>vert Git<cr>", desc = "View status" },
      { "<leader>gD", "<cmd>Gdiffsplit<cr>", desc = "Diff buffer" },
      { "<leader>gC", "<cmd>Git commit | startinsert<cr>", desc = "Create commit" },
      { "<leader>gA", "<cmd>Git commit --amend | startinsert<cr>", desc = "Amend commit" },
      -- { "<leader>gF", "<cmd>Git commit | startinsert<cr>", desc = "Amend commit" },
    },
  },

  { "junegunn/gv.vim",
    -- ABOUT: Fast Git commit browser.
    -- USAGE:
    --   :GV     | Open commit browser. You can pass git log options to the command,
    --           | e.g. :GV -S foobar -- plugins. Also works on lines in visual mode.
    --   :GV!    | List commits that affected the current file.
    --   :GV?    | Fill the location list with the revisions of the current file.
    --           | Also works on lines in visual mode.
    --
    -- MAPPINGS:
    --   o       | Display commit contents or diff
    --   O       | Opens a new tab instead
    --   gb      | Launches :Gbrowse
    --   ]]      | Move to next commit
    --   [[      | Move to previous commit
    --   .       | Start command-line with :Git [CURSOR] SHA à la fugitive
    --   q       | to close
    cmd = "GV",
    keys = {
      { "<leader>gv", "<cmd>GV<cr>", desc = "Browse commits (GV)" }
    },
  },

  { "sindrets/diffview.nvim" },

  { "neogitorg/neogit",
    opts = {}
  },

  { "andrewradev/linediff.vim",
    about = [[
      Diff multiple blocks (lines) of text, instead of files.
      If you want to diff files, you can use the internal :diffthis command on
      multiple files. This plugin allows the same for lines.

      Use :LineDiff with multiple selections of lines.
    ]],
    cmd = "LineDiff",
    keys = {
      { "<leader>g.", "<cmd>LineDiff<cr>", mode = "x", desc = "Diff this line" },
    }
  },
}
