if vim.g.loaded_snippets then
  return
end

vim.g.loaded_snippets = 1

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("SnippetsNvim", { clear = true }),
  callback = function(args)
    require("snippets").start(args.buf)
  end,
})
