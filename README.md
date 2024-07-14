<!-- ABOUT THE PROJECT -->
## About The Project

The goal of this plugin to integrate `harpoon` with `vim-fern` for Neovim. This plugin is only useful to you if you:

1. Use Neovim
2. Use [ThePrimagen/harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) plugin and the `harpoon2` branch
3. Use the `vim-fern` plugin with Neovim

<!-- FEATURES -->
## Features

* Add files to your harpoon list directly from a fern buffer
* Open your harpoon list directly from a fern buffer
* Use the `fern-opener` of your choice when entering a file in a harpoon list opened from a fern buffer, default is `select` (see `:help fern-opener`)

![demo](assets/demo.gif)

<!-- GETTING STARTED -->
## Getting Started

### Dependencies

* [ThePrimagen/harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) (harpoon2 branch)

* [vim-fern](https://github.com/lambdalisue/vim-fern)

* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)


### Installation

Using Lazy:

```lua
{
    "dragonlobster/harpoon-fern.nvim"
    dependencies = { "harpoon", "vim-fern", "plenary.nvim" },
    config = function()
        require("harpoon-fern").setup()
    end
}
```

<!-- USAGE -->
## Usage

Replace the following mappings that you have already set for harpoon; the new one will automatically detect the current buffer and executes new features on a fern buffer while falling back to default behavior on non-fern buffers:

```lua
-- ADD ITEM TO A LIST
-- local harpoon = require("harpoon")
-- harpoon:list():add()

local harpoon_fern = require("harpoon-fern")
harpoon_fern.harpoon_add()

-- ADD ITEM TO A CUSTOM LIST
-- harpoon:list("custom"):add()

harpoon_fern.harpoon_add("custom")

-- OPEN MENU
-- harpoon.ui:toggle_quick_menu(harpoon:list())

harpoon_fern.harpoon_menu()

harpoon_fern.harpoon_menu("custom") -- open custom menu
```


<!-- CONFIGURATION -->
## Configuration

### Default Configuration
```lua
{
    options = {
        -- allow harpoon menu to be opened in fern buffer
        allow_menu = true,

        -- choose fern opener type (see :help fern-opener)
        fern_opener = "select",

        -- vim.notify user if item was added to harpoon
        notify = true,

        -- override non-fern buffer harpoon add and harpoon menu (leave this as true unless you know what you are doing)
        harpoon_override = true
    },

-- ADVANCED SETTINGS BELOW: customize the harpoon_add and harpoon_menu functions for fern and non-fern buffers if you want.

    harpoon_add = {
        -- harpoon add for fern buffer
        fern = function(item, harpoon_list)
            harpoon:list(harpoon_list):add(item)
        end,

        -- harpoon add for non fern buffer
        non_fern = function(harpoon_list)
            harpoon:list(harpoon_list):add()
        end
    },

    harpoon_menu = {
        -- harpoon menu for fern buffer
        fern = function(harpoon_list)
            harpoon.ui:toggle_quick_menu(harpoon:list(harpoon_list))
        end,

        -- harpoon menu for non fern buffer
        non_fern = function(harpoon_list)
            harpoon.ui:toggle_quick_menu(harpoon:list(harpoon_list))
        end
    }
}
```

