--- Setup the [ and ] pending-operator mappings.

--- Set up the basic `cursor_text_objects` mappings.

--- Create a cursor xmap mapping.
---
---@param keys string
---    The new pending-operator to add.
---@param mode "o" | "x"
---    The Neovim mode to consider for the mapping.
---@param direction "down" | "up"
---    Which way to crop the text object. "up" means "operate from the cursor's
---    position to the up/left-most position" and "down" means "operate from
---    the cursor's position (including the cursor's current line, if
---    applicable) to the down/right-most position".
---
local function _map(keys, mode, direction)
    local command

    if mode == "o" then
        command = "<Esc>:<C-U>set operatorfunc=v:lua.require'cursor_text_objects'.operatorfunc<CR>%sg@"
    elseif mode == "x" then
        command = "<Esc>:<C-U>set operatorfunc=v:lua.require'cursor_text_objects'.visual<CR>%sg@"
    end

    vim.keymap.set(mode, keys, function()
        require("cursor_text_objects").prepare(direction)

        return string.format(command, vim.v.count1)
    end, { expr = true, silent = true })
end

_map("[", "o", "up")
_map("]", "o", "down")
_map("[", "x", "up")
_map("]", "x", "down")
