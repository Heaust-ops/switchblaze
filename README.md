# Switchblaze - a shorthand for switching file buffers

<img width="1426" height="734" alt="image" src="https://github.com/user-attachments/assets/ad2e949e-5517-4eab-98d2-491c85731a75" />


- [how to use](#how-to-use)
- [installation](#lazyvim-install)
- [config](#config)

## How to use

type `<leader>t` and then the number of file you want to switch to

https://github.com/user-attachments/assets/1d9c8fc0-4af0-4dc3-abe5-ef0f4daf950a

if you don't pick instantly, a window will appear to remind you what numbers the buffers are

https://github.com/user-attachments/assets/8feb4a34-768b-4157-8041-245edef7532c

at which point you can then type that number or

https://github.com/user-attachments/assets/1f3f3006-cf4b-4962-9e38-6e26a187b262

navigate your cursor and hit enter.

Or use can hit `esc` or `q` to get rid of the menu.

## LazyVim install

```lua
return {
  'Heaust-ops/switchblaze',
  config = function()
    require("switchblaze").setup()
  end,
}
```

add this to a file named `switchblaze.lua` in your plugins directory.

## Config

these are configurable,

```lua
return {
  'Heaust-ops/switchblaze',
  config = function()
    require("switchblaze").setup({
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
    })
  end,
}
```
