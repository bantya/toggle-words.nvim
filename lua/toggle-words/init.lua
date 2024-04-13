local config = {
  words_to_replace = {},
}

-- 5.1 compatibility
if not table.unpack then
  table.unpack = unpack
end

local function get_word_from_range(bufnr, start, finish)
  -- get the lines within the specified range
  local lines = vim.api.nvim_buf_get_lines(bufnr, start[1] - 1, finish[1], false)

  -- join the lines into a single string
  local text = table.concat(lines, '\n')

  -- extract the word from the text
  local word = text:sub(start[2], finish[2])

  return word
end

local function get_word_positions(row, col)
  local start_col = vim.fn.searchpos("\\<", "bcn", row .. "l" .. col)
  local end_col = vim.fn.searchpos("\\>", "cen", row .. "l" .. col)

  local start2, end2 = table.unpack(end_col)

  -- provision to not include character next to the word under cursor
  end_col = { start2, end2 - 1 }

  return { start_col, end_col }
end

local function run()
  local bufnr = vim.fn.bufnr('')
  local new_word = ''
  local found_word = false
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = table.unpack(cursor)

  -- get the current line
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]

  -- get the start and end positions of the word under the cursor
  local start_pos, end_pos = table.unpack(get_word_positions(row, col))

  -- get word under cursor
  local current_word = get_word_from_range(bufnr, start_pos, end_pos)

  -- find mapping for current word (word under cursor)
  for key, values in pairs(config) do
    local current_index = 2

    for idx, value in ipairs(values) do
      if value == current_word then
        local index = (current_index + idx - 2) % #values + 1
        new_word = values[index]
        found_word = true
      end
    end
  end

  -- if no mapping is found, throw error
  if found_word == false then
    vim.api.nvim_err_writeln("Replacement not provided!")
    return
  end

  -- replace occurrences of the old word with the new word
  local new_line = line:sub(1, start_pos[2] - 1) .. new_word .. line:sub(end_pos[2] + 1)

  -- update the buffer with the modified line
  vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, {new_line})

  local diff = current_word:len() - new_word:len()

  if diff < 0 and start_pos[2] + new_word:len() < col then
    diff = 0
  end

  if col - diff < 0 then
    diff = 0
  end

  -- restore cursor position
  vim.api.nvim_win_set_cursor(0, { row, col - diff })
end

local function setup(user_config)
  config = vim.tbl_extend("force", config, user_config or {})
end

return {
  run = run,
  setup = setup
}
