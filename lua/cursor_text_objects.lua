--- All function(s) that can be called externally by other Lua modules.
---
--- If a function's signature here changes in some incompatible way, this
--- package must get a new **major** version.
---
---@module 'cursor_text_objects'
---

local M = {}

local _Direction = { down = "down", up = "up" }
local _DirectionMark = { down = "]", up = "[" }
local _PositionType = { character_wise = "`", line_wise = "'" }

local _CURSOR
local _DIRECTION
local _OPERATOR
local _OPERATOR_FUNCTION

local unpack = unpack or table.unpack -- Future Lua versions use table.unpack

--- Check if the operatorfunc that is running will run on a whole-line.
---
--- See Also:
---     :help g@
---
---@param mode "block" | "char" | "line"
---@return boolean # If `mode` is meant to run on the full-line (ignores column data).
---
local function _is_line_mode(mode)
    return mode == "line"
end

--- Move the start / end marks of the text object as-needed.
---
--- Run this function once, just before executing any text-object / text-operator.
---
--- Important:
---     You must call `prepare()` once before this function can be called.
---
---@param mode "block" | "char" | "line"
---    The caller context. See `:help :map-operator` for details.
---@return string
---    If the user's current cursor position is included with the text-object,
---    we return the string necessary to do that. If the cursor position is not
---    meant to be included, an empty string is returned instead.
---@return string
---    Decide whether to operate on whole-lines ("'") or by-character ("`").
---@return "[" | "]"
---    Which way does is this text operator scanning, up ("[") or down ("]").
---
local function _adjust_marks(mode)
    vim.fn.setpos(".", _CURSOR)
    local mark
    local is_line = _is_line_mode(mode)

    if is_line then
        mark = "'" -- Includes only line information
    else
        mark = "`" -- Includes column information
    end

    local direction
    local inclusive_toggle = ""

    if _DIRECTION == _Direction.up then
        direction = _DirectionMark.up

        if not is_line then
            local buffer, row, column, offset = unpack(vim.fn.getpos("'" .. direction))

            if column > #vim.fn.getline(row) then
                row = row + 1
                column = 0
            end

            vim.fn.setpos("'" .. direction, { buffer, row, column, offset })
        end
    else
        direction = _DirectionMark.down

        local buffer, row, column, offset = unpack(vim.fn.getpos("'" .. direction))

        if not is_line and column == #vim.fn.getline(row) then
            -- NOTE: Move the mark past the current cursor column
            inclusive_toggle = "v"
        else
            vim.fn.setpos("'" .. direction, { buffer, row, column + 1, offset })
        end
    end

    return inclusive_toggle, mark, direction
end

--- Execute the original operatorfunc but crop it based on the cursor position.
---
--- Important:
---     You must call `prepare()` once before this function can be called.
---
---@param mode "block" | "char" | "line"
---    The caller context. See `:help :map-operator` for details.
---
function M.operatorfunc(mode)
    vim.o.operatorfunc = _OPERATOR_FUNCTION

    local inclusive_toggle, mark, direction = _adjust_marks(mode)

    vim.fn.feedkeys(_OPERATOR .. inclusive_toggle .. mark .. direction)
end

--- Make a visual selection of some text-object.
---
--- Important:
---     You must call `prepare()` once before this function can be called.
---
---@param mode "block" | "char" | "line"
---    The caller context. See `:help :map-operator` for details.
---
function M.visual(mode)
    vim.fn.setpos(".", _CURSOR)

    local mark

    if _is_line_mode(mode) then
        mark = "'" -- Includes only line information
    else
        mark = "`" -- Includes column information
    end

    local direction

    if _DIRECTION == _Direction.up then
        direction = _DirectionMark.up
    else
        direction = _DirectionMark.down
    end

    local _, row, column, _ = unpack(vim.fn.getpos("'" .. direction))

    if mark == _PositionType.line_wise then
        if direction == _DirectionMark.down then
            column = #vim.fn.getline(row)
        else
            column = 0
        end
    else
        column = column - 1
    end

    vim.cmd("normal v")
    vim.api.nvim_win_set_cursor(0, { row, column })
end

--- Remember anything that we will need to recall once we execute `operatorfunc`.
---
---@param direction "down" | "up" Which way to crop the text object.
---
function M.prepare(direction)
    _DIRECTION = direction
    _OPERATOR = vim.v.operator
    _CURSOR = vim.fn.getpos(".")
    _OPERATOR_FUNCTION = vim.o.operatorfunc
end

return M
