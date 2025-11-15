local M = {
  header_win = nil,
  content_win = nil,
  header_buf = nil,
  content_buf = nil,
  todos = {},
  raw_todos = {},
  virtual_list = {},
  virtual_to_buffer_line = {},
  header_lines = 0,
  rendering = false,
  
  sort_mode = "none",
  group_mode = "file",
  filter_mode = "all",
  show_heading_context = false,
  
  selected_line = 1,
  topline = 1,
  
  config = {
    icons = {
      pending = "-",
      progress = "=",
      important = "!",
      unknown = "?",
      hold = "~",
    },
    sort_modes = {"none", "modified", "created"},
    group_modes = {"file", "folder", "day", "week", "month"},
    filter_modes = {"all", "journal", "important", "partial", "unknown", "hold"},
  }
}

return M
