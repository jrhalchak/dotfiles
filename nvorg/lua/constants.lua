local M = {}

M.ismac = vim.loop.os_uname().sysname == "Darwin"

return M
