local fn = vim.fn
local bo = vim.bo
local api = vim.api
local M = {
  defaultopts = {
    symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
    no_exec_files = { "packer", "TelescopePrompt", "mason", "CompetiTest" },
    highlight = { guifg = "#957CC6", guibg = api.nvim_get_hl_by_name("Normal", true)["background"] },
    interval = 100
  },
  direction = { left = 'h', right = 'l', up = 'k', down = 'j' },
  c_win = -1
}

--- Judge whether the current can be started and colorful line
---@param no_exec_files
---@return: boolean
function M.can_create(no_exec_files)
  local cursor_win_filetype = bo.filetype
  if vim.fn.win_gettype(0) == 'popup' then -- Skip the floating window
    return false
  end
  local win = api.nvim_get_current_win()
  if M.c_win == win then
    return false
  end
  for i = 1, #no_exec_files do
    if no_exec_files[i] == cursor_win_filetype then
      return false
    end
  end
  M.c_win = win
  return true
end

--- Determine if there are neighbors in the direction
---@param direction
---@return: boolean
function M.direction_have(direction)
  local winnum = vim.fn.winnr()
  api.nvim_command('wincmd ' .. direction)
  if winnum ~= vim.fn.winnr() then
    api.nvim_command("exe " .. winnum .. "\"wincmd w\"")
    return true
  end
  return false
end

--- Get the win property of the orientation
---@param direction : { left = 'h', right = 'l', up = 'k', down = 'j' }
---@return:opts
function M.create_direction_win_option(direction)
  local opts = { style = 'minimal', relative = 'editor', height = 0, width = 0, row = 0, col = 0 }
  local cursor_win_pos = api.nvim_win_get_position(0)
  local cursor_win_width = fn.winwidth(0)
  local cursor_win_height = fn.winheight(0)
  if fn.has('nvim-0.8') then
    if vim.o.winbar ~= '' then
      cursor_win_height = cursor_win_height + 1
    end
  end
  -- vertical line
  if direction == M.direction.left or direction == direction.right then
    opts.width = 1
    if M.direction_have(M.direction.up) and (M.direction_have(M.direction.down) or vim.o.laststatus ~= 3) then
      opts.height = cursor_win_height + 2
    elseif not M.direction_have(M.direction.up) and not M.direction_have(M.direction.down) then
      opts.height = cursor_win_height
    else
      opts.height = cursor_win_height + 1
    end
    if not M.direction_have(M.direction.up) and vim.o.showtabline == 2 then
      opts.row = cursor_win_pos[1]
    elseif not M.direction_have(M.direction.up) and vim.o.showtabline == 1 then
      if fn.tabpagenr("$") > 1 then
        opts.row = cursor_win_pos[1]
      else
        opts.row = cursor_win_pos[1] - 1
      end
    else
      opts.row = cursor_win_pos[1] - 1
    end
    if direction == M.direction.left then
      opts.col = cursor_win_pos[2] - 1
    else
      opts.col = cursor_win_pos[2] + cursor_win_width
    end
  end
  -- horizontal line
  if direction == M.direction.up or direction == M.direction.down then
    opts.width = cursor_win_width
    opts.height = 1
    if direction == M.direction.up then
      opts.row = cursor_win_pos[1] - 1
    else
      opts.row = cursor_win_pos[1] + cursor_win_height
    end
    opts.col = cursor_win_pos[2]
  end
  vim.notify(vim.inspect(opts))
  return opts
end

--- Override user configuration
---@param opts : table
function M.set_user_config(opts)
  if type(opts) == 'table' and opts ~= {} then
    M.defaultopts = vim.tbl_deep_extend("force", M.defaultopts, opts)
  end
end

function M.set_space_line()
end

return M