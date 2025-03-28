-- When we're in a lua file, we are currently most likely in one for nvim.
-- These functions are pretty useful for that.

-- @brief Pretty print passed value by vim.inspect. 
P = function(v)
  print(vim.inspect(v))
  return v
end

-- @brief Reload any number of modules, useful during development.
RELOAD = function(...)
  return require("plenary.reload").reload_module(...)
end

-- @brief Reload and require named module
R = function(name)
  RELOAD(name)
  return require(name)
end
