-- There's some issue with oil.nvim and the latest Neovim
-- IMPORTANT: This file must be loaded before any plugins
local original_uri_to_fname = vim.uri_to_fname

vim.uri_to_fname = function(uri)
  if uri == nil then
    return nil
  end
  if type(uri) == "string" and uri:match("^oil://") then
    return uri  -- Return the URI directly for oil:// URIs
  end
  return original_uri_to_fname(uri)
end

return true
