-- Plugin configuration: lualine.nvim ------------------------------------------------------

local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
    return
end

--------------------------------------------------------------------------------------------
-- Local Functions                                                                        --
--------------------------------------------------------------------------------------------

local diagnostics = {
    'diagnostics',
    sources = { 'nvim_diagnostic' },
    sections = { 'error', 'warn' },
    -- symbols = { error = ' ', warn = ' ', hint = '' },
    symbols = { error = 'E', warn = 'W', hint = 'H' },
    colored = true,
    update_in_insert = true,
    always_visible = true,
}

local mode = {
    'mode',
    fmt = function(str)
        return '-- ' .. str .. ' --'
    end,
}

local filetype = {
    'filetype',
    icons_enabled = false,
    icon = nil,
}

local branch = {
    'branch',
    icons_enabled = true,
    icon = '',
}

local time = function()
    return os.date('%H:%M:%S')
end

--------------------------------------------------------------------------------------------
-- Plugin Configuration                                                                   --
--------------------------------------------------------------------------------------------

lualine.setup({
    options = {
        -- Filetypes in which we will hide the bar.
        disabled_filetypes = {
            'alpha',
            'dashboard',
            'neo-tree',
            'noice',
            'starter',
        },
        icons_enabled = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        always_divide_middle = false,
        theme = 'moonfly',
    },

    sections = {
        lualine_a = { mode },
        lualine_b = { branch },
        lualine_c = { diagnostics, '%=', 'filename' },
        lualine_x = {},
        lualine_y = { time },
        lualine_z = { filetype },
    },

    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = {},
        lualine_y = {},
        lualine_z = { filetype },
    },
    tabline = {},
    extensions = {},
})
