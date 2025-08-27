if vim.g.floating_buffer_picker_disable_autoload then
  return
end

local ok, picker = pcall(require, 'switchblaze')
if not ok or not picker then
  return
end

if not picker._is_setup then
  pcall(picker.setup)
end
