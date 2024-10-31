return function()
  local methods = vim.lsp.protocol.Methods

  local message_id = 0

  local function next_message_id()
    message_id = message_id + 1
    return message_id
  end

  local closing = false

  ---@type vim.lsp.rpc.PublicClient
  ---@diagnostic disable-next-line:missing-fields
  local M = {}

  function M.is_closing()
    return closing
  end

  function M.terminate()
    closing = true
  end

  function M.notify(method)
    return method == methods.initialized
  end

  function M.request(method, params, callback)
    if method == methods.initialize then
      callback(nil, {
        capabilities = {
          completionProvider = {},
        },
      })

      return true, next_message_id()
    elseif method == methods.textDocument_completion then
      ---@cast params lsp.CompletionParams

      local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
      local previous_word = vim.api
        .nvim_buf_get_text(bufnr, params.position.line, 0, params.position.line, params.position.character, {})[1]
        :match "(%S*)$"
      local filetype = vim.filetype.match { buf = bufnr }
      local config = require "snippets.config"

      ---@type lsp.CompletionItem[]
      local result = {}

      local function add(snippets)
        for label, snippet in pairs(snippets or {}) do
          if vim.startswith(label, previous_word) then
            ---@type lsp.CompletionItem
            local item = {
              label = label,
              kind = vim.lsp.protocol.CompletionItemKind.Snippet,
              insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
              insertText = type(snippet) == "function" and snippet() or snippet,
            }

            table.insert(result, item)
          end
        end
      end

      add(config.filetypes[filetype])
      add(config.global)

      callback(nil, result)

      return true, next_message_id()
    end

    return false
  end

  return M
end
