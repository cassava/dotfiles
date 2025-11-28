local M = {}

function M.grep(str)
  Snacks.picker.grep({
    search=str,
    layout={fullscreen=true},
  })
end

function M.dir_containing(str)
    Snacks.picker.files({
        search=str,
        preview=function(ctx)
            return Snacks.picker.preview.cmd(
                string.format([[lsd --tree "$(dirname %s)"]], ctx.item._path), ctx
            )
        end,
        layout={ fullscreen=true },
    })
  end

function M.files(str)
  Snacks.picker.files({
    search=str,
    layout={fullscreen=true},
  })
  end

function M.git_files(str)
  Snacks.picker.git_files({
    search=str,
    layout={fullscreen=true},
  })
end

return M
