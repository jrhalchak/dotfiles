local M = {}

function M.keymap(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function M.split_str(input_str, sep)
  if sep == nil then
    sep = '%s'
  end

  local sep_index = string.find(input_str, sep) or 0

  return {
    string.sub(input_str, 0, sep_index),
    string.sub(input_str, sep_index + 1, #input_str),
  }
end

function M.debounce(fn)
  local timer = vim.loop.new_timer()

  return function(...)
    local argv = {...}
    local argc = select('#', ...)

    timer:start(500, 0, function()
      pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
    end)
  end, timer
end

return M

