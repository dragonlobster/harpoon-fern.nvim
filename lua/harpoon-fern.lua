local Path = require("plenary.path")
local harpoon = require("harpoon")
local Extensions = require("harpoon.extensions")

local H = {}
local HarpoonFern = {}

HarpoonFern.setup = function(config)
    -- setup config
    config = H.setup_config(config)

    -- apply config
    H.apply_config(config)
end
HarpoonFern.config = {
    options = {
        -- allow harpoon menu to be opened in fern buffer
        allow_menu = true,

        -- choose fern opener type
        fern_opener = "select",

        -- vim.notify user if item was added to harpoon
        notify = true,

        -- override non-fern buffer harpoon add and harpoon menu
        harpoon_override = true
    },

    harpoon_add = {
        -- harpoon add for fern buffer
        fern = function(item)
            harpoon:list():add(item)
        end,

        -- harpoon add for non fern buffer
        non_fern = function()
            harpoon:list():add()
        end
    },

    harpoon_menu = {
        -- harpoon menu for fern buffer
        fern = function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end,

        -- harpoon menu for non fern buffer
        non_fern = function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end
    }
}

HarpoonFern.harpoon_add = function()
    --  get config
    local config = HarpoonFern.config

    -- non fern buffer
    if vim.bo.filetype ~= "fern" and config.options.harpoon_override then
        config.harpoon_add.non_fern()

        -- notify
        if config.options.notify then
            vim.notify(string.format("(harpoon-fern) Added %s to list", vim.api.nvim_buf_get_name(0)),
                vim.log.levels.INFO)
        end

        -- fern buffer
    elseif vim.bo.filetype == "fern" then
        -- can't add directories to harpoon
        local isdir = vim.fn["fern#is_dir"]()
        if isdir == 1 then
            vim.notify("(harpoon-fern) Can't add directory", vim.log.levels.ERROR)
            return
        end

        local path = vim.fn["fern#get_path"]()

        -- get relative path
        local rpath = H.normalize_path(
            path,
            vim.uv.cwd()
        )

        -- default row and column for harpoon context
        local item = {
            value = rpath,
            context = {
                row = 1,
                col = 0,
            },
        }

        -- add the specific item
        config.harpoon_add.fern(item)

        -- notify
        if config.options.notify then
            vim.notify(string.format("(harpoon-fern) Added %s to list", rpath), vim.log.levels.INFO)
        end
    end
end

HarpoonFern.harpoon_menu = function()
    -- get config
    local config = HarpoonFern.config

    if config.options.allow_menu and vim.bo.filetype == "fern" then
        config.harpoon_menu.fern()

        -- disable opening menu in fern buffer
    elseif not config.options.allow_menu and vim.bo.filetype == "fern" then
        vim.notify("(harpoon-fern) Can't open menu in fern buffer", vim.log.levels.ERROR)

        -- non fern buffer
    else
        config.harpoon_menu.non_fern()
    end
end

-- Helper
H.default_config = vim.deepcopy(HarpoonFern.config)

H.setup_config = function(config)
    vim.validate({ config = { config, "table", true } })
    config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})

    vim.validate({
        options = { config.options, "table" },
        harpoon_add = { config.harpoon_add, "table" },
        harpoon_menu = { config.harpoon_menu, "table" },
    })

    vim.validate({
        ["options.allow_menu"] = { config.options.allow_menu, "boolean" },
        ["options.fern_opener"] = { config.options.fern_opener, "string" },
        ["options.notify"] = { config.options.notify, "boolean" },
        ["options.harpoon_override"] = { config.options.harpoon_override, "boolean" },
        ["harpoon_add.fern"] = { config.harpoon_add.fern, "function" },
        ["harpoon_add.non_fern"] = { config.harpoon_add.non_fern, "function" },
        ["harpoon_menu.fern"] = { config.harpoon_menu.fern, "function" },
        ["harpoon_menu.non_fern"] = { config.harpoon_menu.non_fern, "function" },
    })

    return config
end

H.apply_config = function(config)
    HarpoonFern.config = config

    -- extend harpoon ui create
    --
    harpoon:extend({
        UI_CREATE = function(cx)
            local is_fern = H.string_starts(cx.current_file, "fern://")
            if is_fern then
                vim.keymap.set("n", "<CR>", function()
                    local idx = vim.fn.line(".")
                    local list_item = harpoon.ui.active_list.items[idx]

                    local f = list_item.value
                    local ctx = list_item.context

                    harpoon.ui:save()
                    harpoon.ui:close_menu()
                    vim.fn["fern#internal#buffer#open"](f, { opener = config.options.fern_opener })

                    local lines = vim.api.nvim_buf_line_count(vim.fn.bufnr("%"))

                    local edited = false
                    if ctx.row > lines then
                        ctx.row = lines
                        edited = true
                    end

                    local row = ctx.row
                    local row_text =
                        vim.api.nvim_buf_get_lines(0, row - 1, row, false)
                    local col = #row_text[1]

                    if ctx.col > col then
                        ctx.col = col
                        edited = true
                    end

                    vim.api.nvim_win_set_cursor(0, {
                        ctx.row or 1,
                        ctx.col or 0,
                    })

                    if edited then
                        Extensions.extensions:emit(
                            Extensions.event_names.POSITION_UPDATED,
                            {
                                list_item = list_item,
                            }
                        )
                    end
                end, { buffer = cx.bufnr, remap = true })
            end
        end,
        --[[SELECT = function(cx)
        if is_fern then
            print(dump(cx.item))
        end
    end --]] -- not useful because this select and the normal select will both run
    })
end

-- utils
H.normalize_path = function(buf_name, root)
    return Path:new(buf_name):make_relative(root)
end


H.string_starts = function(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

-- return module
return HarpoonFern
