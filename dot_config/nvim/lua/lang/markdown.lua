return {
  lazy_treesitter_ensure_installed {
    "html",
    "json",
    "markdown",
    "markdown_inline",
    "toml",
    "xml",
    "yaml",
  },

  lazy_mason_ensure_installed {
    "mdformat",
  },

  { "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "mdformat" },
      }
    },
    init = function()
      require("conform").formatters.mdformat = function(bufnr)
        local width = string.format("%d", vim.bo.textwidth)
        if width == "0" then
          width = "keep"
        end
        return {
          prepend_args = { "--number", "--wrap", width }
        }
      end
    end
  },

  { "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      render_modes = true,
      debounce = 100,
      file_types = { "markdown", "codecompanion" },
      bullet = {
        icons = { "•" },
      },
      dash = {
        width = 80
      },
      heading = {
        width = "block",
        min_width = 80,
      },
      code = {
        width = "block",
        min_width = 80,
      },
      checkbox = {
        right_pad = 0,
        unchecked = { icon = "󰄱 " },
        checked = { icon = " " },
        custom = {
          collect = { raw = "[_]", rendered = "󰄷 ", highlight = "RenderMarkdownUnchecked" },
          alldone = { raw = "[/]", rendered = "󰄸 ", highlight = "RenderMarkdownChecked" },
          ongoing = { raw = "[-]", rendered = "󰏭 ", highlight = "RenderMarkdownTodo" },
          postpone = { raw = "[>]", rendered = "󰐋 ", highlight = "RenderMarkdownTodo" },
          cancelled = { raw = "[~]", rendered = " ", highlight = "RenderMarkdownError" },
          important = { raw = "[!]", rendered = " ", highlight = "RenderMarkdownWarn" },
          finished = { raw = "[=]", rendered = " ", highlight = "RenderMarkdownSuccess" },
        }
      }
    }
  },

  { "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      if vim.fn.executable("microsoft-edge") then
        vim.g.mkdp_browser = "microsoft-edge"
      elseif vim.fn.executable("firefox") then
        vim.g.mkdp_browser = "firefox"
      elseif vim.fn.executable("chromium") then
        vim.g.mkdp_browser = "chromium"
      else
        vim.g.mkdp_browser = nil
      end
      if vim.g.mkdp_browser ~= "" then
        vim.cmd [[
          function OpenMarkdownPreview (url)
            execute "silent ! " . g:mkdp_browser . " --new-window " . a:url
          endfunction
          let g:mkdp_browserfunc = 'OpenMarkdownPreview'
        ]]
      end
    end,
    ft = "markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle" },
    keys = {
      { ",m", "<cmd>MarkdownPreviewToggle<cr>", "Toggle Markdown preview" },
    },
  },

  { "jghauser/follow-md-links.nvim" },
}
