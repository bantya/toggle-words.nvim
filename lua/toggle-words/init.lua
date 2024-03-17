local config = {
  words_to_replace = {},
}

local function run()
  -- save current cursor position
  local save_cursor = vim.api.nvim_win_get_cursor(0)

  -- get word under cursor
  local current_word = vim.fn.expand("<cword>")
  local new_word = vim.fn.input('replace ' .. current_word .. ' with: ')

  -- move cursor to the beginning of the word
  vim.cmd('normal! b')

  -- delete the word under cursor
  vim.cmd('normal! diwh')

  -- insert the new word
  vim.api.nvim_put({new_word}, '', true, true)

  -- restore cursor position
  vim.api.aa(0, save_cursor)
end

local function setup(user_config)
  print(user_config)
  for key, value in pairs(user_config) do
    if config[key] ~= nil then
      config[key] = value
    end
  end
end

return {
  run = run,
  setup = setup
}

