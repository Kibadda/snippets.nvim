---@alias snippets.snippet string|fun(): string

---@class snippets.config
---@field global table<string, snippets.snippet>
---@field filetypes table<string, snippets.snippet>

---@class snippets.internalconfig
local SnippetsDefaultConfig = {
  global = {},
  filetypes = {},
}

---@type snippets.config | (fun(): snippets.config) | nil
vim.g.snippets = vim.g.snippets

---@type snippets.config
local opts = type(vim.g.snippets) == "function" and vim.g.snippets() or vim.g.snippets or {}

---@type snippets.internalconfig
local SnippetsConfig = vim.tbl_deep_extend("force", {}, SnippetsDefaultConfig, opts)

local check = require "snippets.config.check"
local ok, err = check.validate(SnippetsConfig)
if not ok then
  vim.notify("snippets: " .. err, vim.log.levels.ERROR)
end

return SnippetsConfig
