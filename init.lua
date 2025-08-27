local M = {}

local defaults = {
  -- appearance
  width = 40,
  max_width = 80,
  max_height = 15,
  border = "rounded",
  style = "minimal",
  relative = "editor",


  -- mapping
  map = "<leader>t",
  map_mode = "n",
  map_opts = { noremap = true, silent = true },

  -- buffer selection
  getbufinfo_opts = { buflisted = 1 },

  enter = true,
}


local config = vim.tbl_deep_extend('force', {}, defaults)

local function get_lines(buffers)
  local lines = {}
  for i, buf in ipairs(buffers) do
    local name = buf.name ~= "" and vim.fn.fnamemodify(buf.name, ":t") or "[No Name]"
    table.insert(lines, i .. ": " .. name)
  end

  return lines
end

local function calculate_window_dimensions(opts, lines)
  local width = opts.width or defaults.width
  local maxlen = 0

  for _, l in ipairs(lines) do
    local len = vim.fn.strdisplaywidth(l)
    if len > maxlen then maxlen = len end
  end

  local win_width = math.min(math.max(width, maxlen + 2), opts.max_width or defaults.max_width)
  local height = math.min(#lines, opts.max_height or defaults.max_height)

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - win_width) / 2)

  return win_width, height, row, col
end

local function get_buffer(lines)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'switchblaze'

  return buf
end

local function get_window(lines, buffer, opts)
  local width, height, row, col = calculate_window_dimensions(opts, lines)
  local win = vim.api.nvim_open_win(buffer, opts.enter, {
    relative = opts.relative,
    width = width,
    height = height,
    row = row,
    col = col,
    style = opts.style,
    border = opts.border
  })

  if not win or win == 0 then
    vim.notify("Failed to open floating window", vim.log.levels.ERROR)
    pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    return 0
  end

  return win
end

local function handle_number_keys(buffers, win, bufnr, opts)
  for i, buf in ipairs(buffers) do
    local lhs = tostring(i)

    vim.keymap.set('n', lhs, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end

      if vim.api.nvim_buf_is_valid(buf.bufnr) then
        vim.api.nvim_set_current_buf(buf.bufnr)
      else
        vim.notify('Buffer not valid: ' .. tostring(buf.bufnr), vim.log.levels.WARN)
      end
    end, vim.tbl_extend('force', { buffer = bufnr }, opts.map_opts or {}))
  end
end

local function handle_cursor_select(buffers, win, bufnr, opts)
  vim.keymap.set('n', '<CR>', function()
    if not vim.api.nvim_win_is_valid(win) then return end

    local cursor = vim.api.nvim_win_get_cursor(win)
    local line = cursor[1]
    local buf = buffers[line]

    if buf and vim.api.nvim_buf_is_valid(buf.bufnr) then
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_set_current_buf(buf.bufnr)
    end
  end, vim.tbl_extend('force', { buffer = bufnr }, opts.map_opts or {}))
end

local function handle_close(win, bufnr, opts)
  local close_fn = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set('n', '<Esc>', close_fn, vim.tbl_extend('force', { buffer = bufnr }, opts.map_opts or {}))
  vim.keymap.set('n', 'q', close_fn, vim.tbl_extend('force', { buffer = bufnr }, opts.map_opts or {}))

  vim.api.nvim_create_autocmd('WinClosed', {
    once = true,
    callback = function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
      end
    end,
  })
end

function M.open(opts)
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  if not buffers or vim.tbl_isempty(buffers) then
    vim.notify('No buffers to show', vim.log.levels.INFO)
    return
  end

  local lines = get_lines(buffers)
  local buf = get_buffer(lines)

  local win = get_window(lines, buf, opts)
  if not win then
    return
  end

  vim.wo[win].cursorline = true

  handle_number_keys(buffers, win, buf, opts)
  handle_cursor_select(buffers, win, buf, opts)
  handle_close(win, buf, opts)
end

function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", config, opts)
  M._is_setup = true

  if config.map and config.map ~= false then
    vim.keymap.set(config.map_mode or 'n', config.map, function()
      M.open(config)
    end, config.map_opts or {})
  end
end
