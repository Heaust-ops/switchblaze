local ok, m = pcall(require, "switchblaze")

if ok and m.setup and not m._is_setup then
  m.setup()
end
