local M = {}

local function current_theme_name()
  local path = vim.fn.expand("~/.config/dotfiles/current-theme")
  if vim.fn.filereadable(path) == 0 then
    return "ash"
  end
  local lines = vim.fn.readfile(path)
  if #lines == 0 then
    return "ash"
  end
  return vim.fn.trim(lines[1])
end

function M.apply()
  local name = current_theme_name()
  package.loaded["themes.colors." .. name] = nil
  local ok_colors, colors = pcall(require, "themes.colors." .. name)
  if not ok_colors then
    vim.notify("Theme colors missing for: " .. name, vim.log.levels.WARN)
    return false
  end

  local ok_aether, aether = pcall(require, "aether")
  if not ok_aether then
    vim.notify("aether.nvim is not installed yet", vim.log.levels.WARN)
    return false
  end

  aether.setup({ colors = colors })
  vim.cmd.colorscheme("aether")
  return true
end

local revision_file = vim.fn.expand("~/.config/dotfiles/theme-revision")
local last_revision = ""

local function maybe_reload()
  if vim.fn.filereadable(revision_file) == 0 then
    return
  end
  local rev = vim.fn.readfile(revision_file)[1] or ""
  if rev ~= "" and rev ~= last_revision then
    last_revision = rev
    M.apply()
  end
end

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  callback = maybe_reload,
})

return M
