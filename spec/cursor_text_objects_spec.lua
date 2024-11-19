--- Make sure the basic functionality of cursor-text-objects works.
---
---@module 'spec.cursor_text_objects_spec'
---

--- Get the lines of `buffer`.
---
---@param buffer number # A 1-or-more identifier for the Vim buffer.
---@return string # The text in `buffer`.
---
local function _get_lines(buffer)
    return vim.fn.join(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
end

--- Run `keys` from NORMAL mode.
---
---@param keys string Some command to run. e.g. `d]ap`.
---
local function _call_command(keys)
    vim.cmd("normal " .. keys)
end

--- Add mappings for unittests.
local function _initialize_mappings()
    vim.keymap.set("o", "[", "<Plug>(cursor-text-objects-up)")
    vim.keymap.set("o", "]", "<Plug>(cursor-text-objects-down)")
    vim.keymap.set("x", "[", "<Plug>(cursor-text-objects-up)")
    vim.keymap.set("x", "]", "<Plug>(cursor-text-objects-down)")
end

--- Create a new Vim buffer with `text` contents.
---
---@param text string All of the text to add into the buffer.
---@param file_type string? Apply a type to the newly created buffer.
---@return number # A 1-or-more identifier for the Vim buffer.
---@return number # A 1-or-more identifier for the Vim window.
---
local function _make_buffer(text, file_type)
    local buffer = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_set_current_buf(buffer)

    if file_type then
        vim.api.nvim_set_option_value("filetype", file_type, {})
    end

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.fn.split(text, "\n"))

    return buffer, vim.api.nvim_get_current_win()
end

--- Remove any the default mappings that were added from `_initialize_mappings`.
local function _revert_mappings()
    vim.keymap.del("o", "[")
    vim.keymap.del("o", "]")
    vim.keymap.del("x", "[")
    vim.keymap.del("x", "]")
end

--- Make sure `input` becomes `expected` when `keys` are called.
---
---@param cursor {[1]: number, [2]: number} The row & column position. (row=1-or-more, column=0-or-more).
---@param keys string Some command to run. e.g. `d]ap`.
---@param input string The buffer's original text.
---@param expected string The text that we expect to get after calling `keys`.
---
local function _run_simple_test(cursor, keys, input, expected)
    local buffer, window = _make_buffer(input)
    vim.api.nvim_win_set_cursor(window, cursor)

    _call_command(keys)

    assert.same(expected, _get_lines(buffer))
end

--- Initialize 'commentstring' so `:help gc` related tests work as expected.
---
---@param text string The template for creating comments. e.g. `"# %s"`.
---@param buffer number A 0-or-more Vim buffer ID.
---
local function _set_commentstring(text, buffer)
    vim.api.nvim_set_option_value("commentstring", text, { buf = buffer })
end

describe("basic", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    it("works with inner count", function()
        _run_simple_test(
            { 2, 0 },
            "d]2ap",
            [[
      some text
          more text <-- NOTE: The cursor will be set here
          even more lines!
      still part of the paragraph

      another paragraph
      with text in it

      last paragraph
      ]],
            [[
      some text
      last paragraph
      ]]
        )
    end)

    it("works with outer count", function()
        _run_simple_test(
            { 2, 0 },
            "2d]ap",
            [[
      some text
          more text <-- NOTE: The cursor will be set here
          even more lines!
      still part of the paragraph

      another paragraph
      with text in it

      last paragraph
      ]],
            [[
      some text
      last paragraph
      ]]
        )
    end)
end)

describe(":help c", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    describe("down", function()
        it("works cap", function()
            _run_simple_test(
                { 2, 0 },
                "c]ap",
                [[
        some text
            more text <-- NOTE: The cursor will be set here
            even more lines!
        still part of the paragraph

        another paragraph
        with text in it
        ]],
                [[
        some text

        another paragraph
        with text in it
        ]]
            )
        end)

        it("works ca}", function()
            _run_simple_test(
                { 3, 0 },
                "c]a}",
                [[
        {
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        }

        {
            another paragraph
            with text in it
        }
        ]],
                [[
        {
            some text


        {
            another paragraph
            with text in it
        }
        ]]
            )
        end)
    end)

    describe("up", function()
        it("works cap", function()
            _run_simple_test(
                { 7, 0 },
                "c[ap",
                [[
        some text
            more text
            even more lines!
        still part of the paragraph

        first line, second paragraph
        another paragraph  <-- NOTE: The cursor will be set here
        with text in it
        ]],
                [[
        some text
            more text
            even more lines!
        still part of the paragraph


        with text in it
        ]]
            )
        end)

        it("works ca}", function()
            _run_simple_test(
                { 3, 0 },
                "c[a}",
                [[
        {
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        }

        {
            another paragraph
            with text in it
        }
        ]],
                [[

                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        }

        {
            another paragraph
            with text in it
        }
        ]]
            )
        end)
    end)
end)

describe(":help d", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    describe("down", function()
        it("works with da)", function()
            _run_simple_test(
                { 3, 0 },
                "d]a)",
                [[
        (
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        )

        (
            another paragraph
            with text in it
        )
        ]],
                [[
        (
            some text


        (
            another paragraph
            with text in it
        )
        ]]
            )
        end)

        it("works with da]", function()
            _run_simple_test(
                { 3, 0 },
                "d]a]",
                [[
        [
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        ]

        [
            another paragraph
            with text in it
        ]
        ]],
                [[
        [
            some text


        [
            another paragraph
            with text in it
        ]
        ]]
            )
        end)

        it("works with da}", function()
            _run_simple_test(
                { 3, 0 },
                "d]a}",
                [[
        {
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        }

        {
            another paragraph
            with text in it
        }
        ]],
                [[
        {
            some text


        {
            another paragraph
            with text in it
        }
        ]]
            )
        end)

        it("works with dap - 3 paragraphs", function()
            _run_simple_test(
                { 4, 0 },
                "d]ap",
                [[
        first first

        second 1
        second 2  <-- NOTE: The cursor will be set here
        second 3

        third paragraph
        ]],
                [[
        first first

        second 1
        third paragraph
        ]]
            )
        end)

        it("works with dap", function()
            _run_simple_test(
                { 2, 0 },
                "d]ap",
                [[
        some text
            more text <-- NOTE: The cursor will be set here
            even more lines!
        still part of the paragraph

        another paragraph
        with text in it
        ]],
                [[
        some text
        another paragraph
        with text in it
        ]]
            )
        end)

        it("works with das", function()
            _run_simple_test(
                { 1, 28 },
                "d]as",
                [[
        some sentences. With text and stuff
        multiple lines.
        other code
        ]],
                [[
        some sentences. Withother code
        ]]
            )
        end)

        it("works with dat", function()
            _run_simple_test(
                { 3, 0 },
                "d]at",
                [[
        <foo>
            some text
                more text <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph
        </foo>
        ]],
                [[
        <foo>
            some text

        ]]
            )
        end)

        it("works with di)", function()
            _run_simple_test(
                { 3, 0 },
                "d]i)",
                [[
        (
            some lines
            and more things  <-- NOTE: The cursor will be set here
            last in the paragraph

            last bits
        )

        (
            another one
        )
        ]],
                [[
        (
            some lines
        )

        (
            another one
        )
        ]]
            )
        end)

        it("works with di]", function()
            _run_simple_test(
                { 3, 0 },
                "d]i]",
                [[
        [
            some lines
            and more things  <-- NOTE: The cursor will be set here
            last in the paragraph

            last bits
        ]

        [
            another one
        ]
        ]],
                [[
        [
            some lines
        ]

        [
            another one
        ]
        ]]
            )
        end)

        it("works with di}", function()
            _run_simple_test(
                { 3, 0 },
                "d]i}",
                [[
        {
            some lines
            and more things  <-- NOTE: The cursor will be set here
            last in the paragraph

            last bits
        }

        {
            another one
        }
        ]],
                [[
        {
            some lines
        }

        {
            another one
        }
        ]]
            )
        end)

        it("works with dip", function()
            _run_simple_test(
                { 2, 0 },
                "d]ip",
                [[
        some text
            more text  <-- NOTE: The cursor will be set here
            even more lines!
        still part of the paragraph

        another paragraph
        with text in it
        ]],
                [[
        some text

        another paragraph
        with text in it
        ]]
            )
        end)

        it("works with dis", function()
            _run_simple_test(
                { 1, 22 },
                "d]is",
                "some sentences. With text and stuff\nmultiple lines\nother code",
                "some sentences. With t"
            )
        end)

        it("works with dit", function()
            _run_simple_test(
                { 3, 0 },
                "d]it",
                [[
        <foo>
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph
        </foo>
        ]],
                [[
        <foo>
            some text
</foo>
        ]]
            )
        end)
    end)

    describe("single-line", function()
        describe("left", function()
            it("works with daW", function()
                _run_simple_test({ 1, 11 }, "d[aW", "sometext.morethings", "rethings")
            end)

            it("works with das", function()
                _run_simple_test(
                    { 1, 19 },
                    "d[as",
                    "some sentences. With text and stuff. other code",
                    "some sentences. h text and stuff. other code"
                )
            end)

            it("works with daw", function()
                _run_simple_test({ 1, 2 }, "d[aw", "sometext.morethings", "metext.morethings")
            end)

            it("works with da[", function()
                _run_simple_test({ 1, 15 }, "d[a[", "some text [ inner text ] t", "some text er text ] t")
            end)

            it("works with da{", function()
                _run_simple_test({ 1, 15 }, "d[a{", "some text { inner text }   ", "some text er text }   ")
            end)

            it("works with dis", function()
                _run_simple_test(
                    { 1, 23 },
                    "d[is",
                    "some sentences. With text and stuff. other code",
                    "some sentences. xt and stuff. other code"
                )
            end)

            it("works with di[", function()
                _run_simple_test({ 1, 15 }, "d[i[", "some text [ inner text ]   ", "some text [er text ]   ")
            end)

            it("works with di{", function()
                _run_simple_test({ 1, 15 }, "d[i{", "some text { inner text }   ", "some text {er text }   ")
            end)
        end)

        describe("right", function()
            it("works with daW", function()
                _run_simple_test({ 1, 2 }, "d]aW", "sometext.morethings", "so")
            end)

            it("works with daw", function()
                _run_simple_test({ 1, 2 }, "d]aw", "sometext.morethings", "so.morethings")
            end)

            it("works with da]", function()
                _run_simple_test({ 1, 15 }, "d]a]", "some text [ inner text ]   ", "some text [ inn   ")
            end)

            it("works with da}", function()
                _run_simple_test({ 1, 15 }, "d]a}", "some text { inner text }   ", "some text { inn   ")
            end)

            it("works with di]", function()
                _run_simple_test({ 1, 15 }, "d]i]", "some text [ inner text ]   ", "some text [ inn]   ")
            end)

            it("works with di}", function()
                _run_simple_test({ 1, 15 }, "d[i}", "some text { inner text }   ", "some text {er text }   ")
            end)
        end)
    end)

    describe("up", function()
        it("works with da)", function()
            _run_simple_test(
                { 7, 0 },
                "d[a)",
                [[
        (
            some text
                more text
                even more lines!
            still part of the paragraph

            more lines  <-- NOTE: The cursor will be set here
            last line
        )

        (
            another paragraph
            with text in it
        )
        ]],
                [[
            more lines  <-- NOTE: The cursor will be set here
            last line
        )

        (
            another paragraph
            with text in it
        )
        ]]
            )
        end)

        it("works with da]", function()
            _run_simple_test(
                { 3, 22 },
                "d[a]",
                [[
        [
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        ]

        [
            another paragraph
            with text in it
        ]
        ]],
                [[
        ext  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        ]

        [
            another paragraph
            with text in it
        ]
        ]]
            )
        end)

        it("works with da}", function()
            _run_simple_test(
                { 3, 24 },
                "d[a}",
                [[
        {
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        }

        {
            another paragraph
            with text in it
        }
        ]],
                [[
        t  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        }

        {
            another paragraph
            with text in it
        }
        ]]
            )
        end)

        it("works with dat", function()
            _run_simple_test(
                { 3, 0 },
                "d[at",
                [[
        <foo>
            some text
                more text <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph
        </foo>
        ]],
                [[
                more text <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph
        </foo>
        ]]
            )
        end)

        it("works with dap", function()
            _run_simple_test(
                { 7, 0 },
                "d[ap",
                [[
        some text
            more text
            even more lines!
        still part of the paragraph

        first line, second paragraph
        another paragraph  <-- NOTE: The cursor will be set here
        with text in it
        ]],
                [[
        some text
            more text
            even more lines!
        still part of the paragraph

        with text in it
        ]]
            )
        end)

        it("works with di)", function()
            _run_simple_test(
                { 3, 0 },
                "d[i)",
                [[
        (
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        )

        (
            another paragraph
            with text in it
        )
        ]],
                [[
        (
                even more lines!
            still part of the paragraph

            more lines
        )

        (
            another paragraph
            with text in it
        )
        ]]
            )
        end)

        it("works with di]", function()
            _run_simple_test(
                { 3, 0 },
                "d[i]",
                [[
        [
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        ]

        [
            another paragraph
            with text in it
        ]
        ]],
                [[
        [
                even more lines!
            still part of the paragraph

            more lines
        ]

        [
            another paragraph
            with text in it
        ]
        ]]
            )
        end)

        it("works with di}", function()
            _run_simple_test(
                { 3, 0 },
                "d[i}",
                [[
        {
            some text
                more text  <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph

            more lines
        }

        {
            another paragraph
            with text in it
        }
        ]],
                [[
        {
                even more lines!
            still part of the paragraph

            more lines
        }

        {
            another paragraph
            with text in it
        }
        ]]
            )
        end)

        it("works with dip", function()
            _run_simple_test(
                { 2, 23 },
                "d[ip",
                [[
        some text
            more text <-- NOTE: The cursor will be set here
            even more lines!
        still part of the paragraph

        another paragraph
        with text in it
        ]],
                [[
            even more lines!
        still part of the paragraph

        another paragraph
        with text in it
        ]]
            )
        end)

        it("works with dis", function()
            _run_simple_test(
                { 1, 19 },
                "d[is",
                "some sentences. With text and stuff. other code",
                "some sentences. h text and stuff. other code"
            )
        end)

        it("works with dit - 001", function()
            _run_simple_test(
                { 3, 0 },
                "d[it",
                [[
        <foo>
            some text
                more text <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph
        </foo>
        ]],
                [[
        <foo>
                more text <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph
        </foo>
        ]]
            )
        end)

        it("works with dit - 002 - Include characters", function()
            _run_simple_test(
                { 3, 23 },
                "d[it",
                [[
        <foo>  some text
            some text
                more text <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph
        </foo>
        ]],
                [[
        <foo>xt <-- NOTE: The cursor will be set here
                even more lines!
            still part of the paragraph
        </foo>
        ]]
            )
        end)
    end)
end)

describe(":help gU", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    describe("down", function()
        it("works with gUip", function()
            _run_simple_test(
                { 5, 0 },
                "gU]ip",
                [[
        aaaa
        bbbbb

        ccccc
        ddddddddddd  <-- NOTE: The cursor will be set here
        eeeeeeeee

        fffff
        ]],
                [[
        aaaa
        bbbbb

        ccccc
        DDDDDDDDDDD  <-- NOTE: THE CURSOR WILL BE SET HERE
        EEEEEEEEE

        fffff
        ]]
            )
        end)
    end)

    describe("up", function()
        it("works with gUip", function()
            _run_simple_test(
                { 5, 0 },
                "gU[ip",
                [[
        aaaa
        bbbbb

        ccccc
        ddddddddddd  <-- NOTE: The cursor will be set here
        eeeeeeeee

        fffff
        ]],
                [[
        aaaa
        bbbbb

        CCCCC
        DDDDDDDDDDD  <-- NOTE: THE CURSOR WILL BE SET HERE
        eeeeeeeee

        fffff
        ]]
            )
        end)
    end)
end)

describe(":help gc", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    describe("down", function()
        it("works with gcip", function()
            local buffer, window = _make_buffer(
                [[
                def foo() -> None:
                    """Some function."""  <-- NOTE: The cursor will be set here
                    print("do stuff")

                    for _ in range(10):
                        print("stuff")
                ]],
                "python"
            )
            vim.api.nvim_win_set_cursor(window, { 2, 0 })
            _set_commentstring("# %s", buffer)

            _call_command("gc]ip")

            assert.same(
                [[
                def foo() -> None:
                    # """Some function."""  <-- NOTE: The cursor will be set here
                    # print("do stuff")

                    for _ in range(10):
                        print("stuff")
                ]],
                _get_lines(buffer)
            )
        end)
    end)

    describe("up", function()
        it("works with gcip", function()
            local buffer, window = _make_buffer(
                [[
                def foo() -> None:
                    """Some function."""  <-- NOTE: The cursor will be set here
                    print("do stuff")

                    for _ in range(10):
                        print("stuff")
                ]],
                "python"
            )
            vim.api.nvim_win_set_cursor(window, { 2, 0 })
            _set_commentstring("# %s", buffer)

            _call_command("gc[ip")

            assert.same(
                [[
                # def foo() -> None:
                #     """Some function."""  <-- NOTE: The cursor will be set here
                    print("do stuff")

                    for _ in range(10):
                        print("stuff")
                ]],
                _get_lines(buffer)
            )
        end)
    end)
end)

describe(":help gu", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    describe("down", function()
        it("works with guip", function()
            _run_simple_test(
                { 5, 0 },
                "gu]ip",
                [[
        aaaa
        bbbbb

        ccccc
        ddDddDddDdd  <-- NOTE: The cursor will be set here
        eeeEeEEee

        fffff
        ]],
                [[
        aaaa
        bbbbb

        ccccc
        ddddddddddd  <-- note: the cursor will be set here
        eeeeeeeee

        fffff
        ]]
            )
        end)
    end)

    describe("up", function()
        it("works with guip", function()
            _run_simple_test(
                { 5, 0 },
                "gu[ip",
                [[
        aaaa
        bbbbb

        cCCcc
        ddDddDddDdd  <-- NOTE: The cursor will be set here
        eeeEeEEee

        fffff
        ]],
                [[
        aaaa
        bbbbb

        ccccc
        ddddddddddd  <-- note: the cursor will be set here
        eeeEeEEee

        fffff
        ]]
            )
        end)
    end)
end)

describe(":help g~", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    describe("down", function()
        it("works with g~ip", function()
            _run_simple_test(
                { 5, 0 },
                "g~]ip",
                [[
        aaaa
        bbbbb

        cCCcc
        ddDddDddDdd  <-- NOTE: The cursor will be set here
        eeeEeEEee

        fffff
        ]],
                [[
        aaaa
        bbbbb

        cCCcc
        DDdDDdDDdDD  <-- note: tHE CURSOR WILL BE SET HERE
        EEEeEeeEE

        fffff
        ]]
            )
        end)
    end)

    describe("up", function()
        it("works with g~ip", function()
            _run_simple_test(
                { 5, 0 },
                "g~[ip",
                [[
        aaaa
        bbbbb

        cCCcc
        ddDddDddDdd  <-- NOTE: The cursor will be set here
        eeeEeEEee

        fffff
        ]],
                [[
        aaaa
        bbbbb

        CccCC
        DDdDDdDDdDD  <-- note: tHE CURSOR WILL BE SET HERE
        eeeEeEEee

        fffff
        ]]
            )
        end)
    end)
end)

describe(":help y", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    describe("down", function()
        it("works with yap", function()
            local _, window = _make_buffer([[
                aaaa
                bbbb  <-- NOTE: The cursor will be set here
                    cccc

                next
                lines
                    blah

                ]])
            vim.api.nvim_win_set_cursor(window, { 2, 0 })

            _call_command("y]ap")

            assert.same(
                [[
                bbbb  <-- NOTE: The cursor will be set here
                    cccc

]],
                vim.fn.getreg("")
            )
        end)
    end)

    describe("up", function()
        it("works with yap", function()
            local _, window = _make_buffer([[
                aaaa
                bbbb  <-- NOTE: The cursor will be set here
                    cccc

                next
                lines
                    blah

                ]])
            vim.api.nvim_win_set_cursor(window, { 2, 0 })

            _call_command("y[ap")

            assert.same(
                "                aaaa\n                bbbb  <-- NOTE: The cursor will be set here\n",
                vim.fn.getreg("")
            )
        end)
    end)
end)

describe("marks", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    describe("marks - '", function()
        describe("down", function()
            it("works with yank", function()
                local buffer, window = _make_buffer([[
                    aaaa
                    bbbb  <-- NOTE: The cursor will be set here
                        cccc

                    next
                    lines
                        blah

                    ]])
                vim.api.nvim_win_set_cursor(window, { 2, 0 })

                vim.api.nvim_buf_set_mark(buffer, "b", 6, 18, {})

                _call_command("y]'b")

                assert.same(
                    [[
                    bbbb  <-- NOTE: The cursor will be set here
                        cccc

                    next
                    lines
]],
                    vim.fn.getreg("")
                )
            end)
        end)

        describe("up", function()
            it("works with yank", function()
                local buffer, window = _make_buffer([[
                    aaaa
                    bbbb
                        cccc

                    next
                    lines <-- NOTE: The cursor will be set here
                        blah

                    ]])
                vim.api.nvim_win_set_cursor(window, { 6, 19 })

                vim.api.nvim_buf_set_mark(buffer, "b", 2, 19, {})

                _call_command("y['b")

                assert.same(
                    [[
                    bbbb
                        cccc

                    next
                    lines <-- NOTE: The cursor will be set here
]],
                    vim.fn.getreg("")
                )
            end)
        end)
    end)

    describe("marks - `", function()
        describe("down", function()
            it("works with yank", function()
                local buffer, window = _make_buffer([[
                    aaaa
                    bbbb  <-- NOTE: The cursor will be set here
                        cccc

                    next
                    lines
                        blah

                    ]])
                vim.api.nvim_win_set_cursor(window, { 2, 22 })

                vim.api.nvim_buf_set_mark(buffer, "b", 6, 22, {})

                _call_command("y]`b")

                assert.same(
                    [[bb  <-- NOTE: The cursor will be set here
                        cccc

                    next
                    li]],
                    vim.fn.getreg("")
                )
            end)
        end)

        describe("up", function()
            it("works with yank", function()
                local buffer, window = _make_buffer([[
                    aaaa
                    bbbb
                        cccc

                    next
                    lines <-- NOTE: The cursor will be set here
                        blah

                    ]])
                vim.api.nvim_win_set_cursor(window, { 6, 23 })

                vim.api.nvim_buf_set_mark(buffer, "b", 2, 23, {})

                _call_command("y[`b")

                assert.same(
                    [[b
                        cccc

                    next
                    lin]],
                    vim.fn.getreg("")
                )
            end)
        end)
    end)
end)

describe("scenario", function()
    before_each(_initialize_mappings)
    after_each(_revert_mappings)

    it("works with a curly function - da{", function()
        _run_simple_test(
            { 3, 0 },
            "d[a{",
            vim.fn.join({
                "void main() {",
                "  something",
                "  ttttt <-- NOTE: The cursor will be set here",
                "  fffff",
                "}",
            }, "\n"),
            vim.fn.join({ "void main() ", "  ttttt <-- NOTE: The cursor will be set here", "  fffff", "}" }, "\n")
        )
    end)

    it("works with a curly function - di{", function()
        _run_simple_test(
            { 3, 0 },
            "d[i{",
            [[
      void main() {
        something
        ttttt <-- NOTE: The cursor will be set here
        fffff
      }
      ]],
            [[
      void main() {
        fffff
      }
      ]]
        )
    end)
end)
