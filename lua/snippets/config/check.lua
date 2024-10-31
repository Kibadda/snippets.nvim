local M = {}

--- small wrapper around vim.validate
---@param path string
---@param tbl table
---@return boolean
---@return string?
local function validate(path, tbl)
  local prefix = "invalid config: "
  local ok, err = pcall(vim.validate, tbl)
  return ok or false, prefix .. (err and path .. "." .. err or path)
end

--- validate given config
---@param config snippets.internalconfig
---@return boolean
---@return string?
function M.validate(config)
  local ok, err

  ok, err = validate("snippets", {
    global = { config.global, "table", true },
    filetypes = { config.filetypes, "table", true },
  })
  if not ok then
    return false, err
  end

  for name, snippet in vim.spairs(config.global or {}) do
    ok, err = validate("snippets.global." .. name, {
      name = { name, "string" },
      snippet = { snippet, { "string", "function" } },
    })
    if not ok then
      return false, err
    end
  end

  for filetype, snippets in vim.spairs(config.filetypes or {}) do
    ok, err = validate("snippets.filetypes." .. filetype, {
      filetype = { filetype, "string" },
      snippets = { snippets, "table" },
    })
    if not ok then
      return false, err
    end

    for name, snippet in vim.spairs(snippets) do
      ok, err = validate("snippets.filetypes." .. filetype .. "." .. name, {
        name = { name, "string" },
        snippet = { snippet, { "string", "function" } },
      })
      if not ok then
        return false, err
      end
    end
  end

  return true
end

return M
