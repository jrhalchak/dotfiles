local parser_dir = vim.fn.stdpath("data") .. "/site/parser/"
local parser_name = "bdiagram"
local parser_so = parser_dir .. parser_name .. ".so"
local parser_src = "tree-sitter-bdiagram"

vim.fn.mkdir(parser_dir, "p")

local function run(cmd)
  print("Running: " .. cmd)
  local ok = os.execute(cmd)
  if ok ~= 0 then
    error("Command failed: " .. cmd)
  end
end

run("cd " .. parser_src .. " && tree-sitter generate")
run("cd " .. parser_src .. " && cc -o " .. parser_name .. ".so -shared -Os -fPIC src/parser.c")
run("cp " .. parser_src .. "/" .. parser_name .. ".so " .. parser_so)
print("Installed " .. parser_name .. ".so to " .. parser_dir)
