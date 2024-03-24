local config = {
  words_to_replace = {},
}

local function run()
  -- get current cursor position
  local save_cursor = vim.api.nvim_win_get_cursor(0)

  -- get word under cursor
  local current_word = vim.fn.expand("<cword>")
  local new_word = ''
  local found_word = false

  -- find the mapping for current word (word under cursor)
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

  -- move cursor to the beginning of the word and delete the word under cursor
  vim.cmd('normal! bdiw')

  -- insert the new word
  vim.api.nvim_put({new_word}, '', true, true)

  -- restore cursor position
  vim.api.nvim_win_set_cursor(0, save_cursor)
end

local function setup(user_config)
  config = vim.tbl_extend("force", config, user_config or {})
end

return {
  run = run,
  setup = setup
}

