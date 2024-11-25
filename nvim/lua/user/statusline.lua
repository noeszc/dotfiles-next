local navic = require("nvim-navic")

navic.setup({
  icons = {
    File = "",
    Module = "",
    Namespace = "",
    Package = "",
    Class = "",
    Method = "",
    Property = "",
    Field = "",
    Constructor = "",
    Enum = "",
    Interface = "",
    Function = "",
    Variable = "",
    Constant = "",
    String = "",
    Number = "",
    Boolean = "",
    Array = "",
    Object = "",
    Key = "",
    Null = "",
    EnumMember = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
  },
  separator = " -> ",
  depth_limit = 3,
})

local M = {}

---Returns formatted git branch and status information
---@return string
function M.get_git_status()
  local branch = vim.b.gitsigns_head
  if not branch then
    return " -- "
  end

  local status = vim.b.gitsigns_status_dict or {}
  local added = status.added or 0
  local changed = status.changed or 0
  local removed = status.removed or 0

  return string.format("%s +%d -%d ~%d", branch, added, removed, changed)
end

---Returns current filename or placeholder if empty
---@return string
function M.get_filename()
  local filename = vim.fn.expand("%:t")
  return (filename ~= "") and filename or "[no name]"
end

---Returns current mode indicator
---@return string
M.get_current_mode = function()
  local mode = vim.fn.mode()

  local mode_aliases = {
    n = "n",
    i = "i",
    v = "v",
    V = "v",
    t = "t",
    c = "c",
    s = "s",
    ["␖"] = "v",
  }

  local mode_str = mode_aliases[mode] or "?"
  return string.format("%s", mode_str:upper())
end

---Returns diagnostic counts formatted
---@return string
M.get_diagnostics = function()
  local diagnostics = {
    error = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
    warning = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
    hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
  }

  return string.format("E%d W%d H%d", diagnostics.error, diagnostics.warning, diagnostics.hint)
end

local navicLimit = math.floor(vim.o.columns / 3)
M.statusbar_navic = function()
  local text = navic.get_location()
  if text == "" then
    return ""
  end
  local without_callbacks = text:gsub(" callback", "")
  if string.len(without_callbacks) >= navicLimit then
    without_callbacks = "…" .. without_callbacks:sub((navicLimit - 5) * -1)
  end
  return without_callbacks
end

return M
