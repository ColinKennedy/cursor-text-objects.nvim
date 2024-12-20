# cursor-text-objects.nvim

| <!-- -->     | <!-- -->                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Build Status | [![unittests](https://img.shields.io/github/actions/workflow/status/ColinKennedy/cursor-text-objects.nvim/test.yml?branch=main&style=for-the-badge&label=Unittests)](https://github.com/ColinKennedy/cursor-text-objects.nvim/actions/workflows/test.yml)  [![documentation](https://img.shields.io/github/actions/workflow/status/ColinKennedy/cursor-text-objects.nvim/documentation.yml?branch=main&style=for-the-badge&label=Documentation)](https://github.com/ColinKennedy/cursor-text-objects.nvim/actions/workflows/documentation.yml)  [![luacheck](https://img.shields.io/github/actions/workflow/status/ColinKennedy/cursor-text-objects.nvim/luacheck.yml?branch=main&style=for-the-badge&label=Luacheck)](https://github.com/ColinKennedy/cursor-text-objects.nvim/actions/workflows/luacheck.yml) [![llscheck](https://img.shields.io/github/actions/workflow/status/ColinKennedy/cursor-text-objects.nvim/llscheck.yml?branch=main&style=for-the-badge&label=llscheck)](https://github.com/ColinKennedy/cursor-text-objects.nvim/actions/workflows/llscheck.yml) [![stylua](https://img.shields.io/github/actions/workflow/status/ColinKennedy/cursor-text-objects.nvim/stylua.yml?branch=main&style=for-the-badge&label=Stylua)](https://github.com/ColinKennedy/cursor-text-objects.nvim/actions/workflows/stylua.yml)  [![urlchecker](https://img.shields.io/github/actions/workflow/status/ColinKennedy/cursor-text-objects.nvim/urlchecker.yml?branch=main&style=for-the-badge&label=URLChecker)](https://github.com/ColinKennedy/cursor-text-objects.nvim/actions/workflows/urlchecker.yml)  |
| License      | [![License-MIT](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](https://github.com/ColinKennedy/cursor-text-objects.nvim/blob/main/LICENSE)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Social       | [![RSS](https://img.shields.io/badge/rss-F88900?style=for-the-badge&logo=rss&logoColor=white)](https://github.com/ColinKennedy/cursor-text-objects.nvim/commits/main/doc/news.txt.atom)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |


# How To Use
## Summary
In short, mappings like `dap`, which delete a whole paragraph, now can use
`d[ap` which means "delete from the start of the paragraph to your current
cursor position" and `d]ap` means "delete from the current cursor position to
the end of the paragraph".

It works with any text operator or text object pair and integrates with existing plugins.


## Details
For every text object and text operator that Vim has, you can now "include"
your cursor as a part of the command.

Here's a practical example. Have you ever had a paragraph of text like this.

```
Some text with many lines. And something
that wraps multiple|cursor here| lines in a single sentence.
Lorem ipsum and all that.

More paragraph text
```

And you'd like delete just from your current `|cursor|` to the bottom of the
paragraph? You can't use `dap`, that deletes the whole paragraph. With
cursor-text-objects.nvim, you can use `d]ap` which means "delete from the
current cursor position around the end of the paragraph". And you can delete to
the start of the paragraph with `d[ap`. If you want to delete to the start of
the sentence, use `d[is`.

Again, **any text operator or text object** command that you can think of now
works with your cursor. Here's more examples.

- `d[a}` - Delete around the start of a {}-pair to the cursor.
- `d]a}` - Delete around the cursor to the end of a {}-pair.
- `gc[ip` - Comment from the start of the paragraph to the cursor.
- `gc]ip` - Comment from the cursor to the end of the paragraph.
- `gw[ip` - Format from the start of the paragraph to the cursor.
- `gw]ip` - Format from the cursor to the end of the paragraph.
- `v[ip` - Select from the start of the paragraph to the cursor.
- `v]ip` - Select from the cursor to the end of the paragraph.
- `y[ib` - Yank inside start of a ()-pair to the cursor.
- `y]ib` - Yank inside the cursor to the end of a ()-pair.

It works with custom operators and objects too!

Using [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)

- `v]ic` - Select lines from the cursor to the end of a class.
- `v[ic` - Select lines from the start of a class to the cursor.
- `v]if` - Select lines from the cursor to the end of a function.
- `v[if` - Select lines from the start of a function to the cursor.

Using [vim-textobj-indent](https://github.com/kana/vim-textobj-indent)

- `c[ii` - Change from start of the indented-lines to the cursor.
- `c]ii` - Change from the cursor to the end of the indented-lines.

etc. etc. etc.

Give your right-pinky a workout and install `cursor-text-objects.nvim` today!


# Installation
- [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "ColinKennedy/cursor-text-objects.nvim",
    config = function()
        vim.keymap.set(
            {"o", "x"},
            "[",
            "<Plug>(cursor-text-objects-up)",
            { desc = "Run from your current cursor to the end of the text-object." }
        )
        vim.keymap.set(
            {"o", "x"},
            "]",
            "<Plug>(cursor-text-objects-down)",
            { desc = "Run from your current cursor to the end of the text-object." }
        )
    end,
    version = "v1.*",
}
```


# Disclaimer
The default recommended mappings, `[` and `]`, will not conflict with existing
mappings. There's [a test
script](https://gist.github.com/ColinKennedy/7e632f88570be89762b0ca8372769b72)
that verifies this.

However if you have another mapping like this:

`vim.keymap.set({'n', 'x', 'o'}, '[i', function() return "dd" end,
{expr=true})`

then you may be surprised that `d[ip` does not work.

In short while actually this is not a conflict, it can still be confusing for
a you and you'll want to remap `cursor-text-objects` or that other mapping
/ plug-in to avoid the issue.

<details>
<summary>More details on what is going on in this case</summary>

`cursor-text-objects` is a pending operator but the mapping above is a regular
operator. A pending operator is a mapping that "waits for the user to keep
typing more keys" but a regular operator executes immediately. So if you only
have `cursor-text-objects` applied, `ip` is interpreted as "[i]nside
[p]aragraph". But with the mapping above, `d[i` executes immediately and then
treats `p` as the start of a new command. And `p` as a standalone keymap means
[p]ut. (See `:help put` for details).

So again this is all expected behavior but if you don't want that to happen,
you're better off remapping `[i` to something else.

</details>


# Tests
## Initialization
Run this line once before calling any `busted` command

```sh
eval $(luarocks path --lua-version 5.1 --bin)
```


## Running
Run all tests
```sh
luarocks test --test-type busted
# Or manually
busted --helper spec/minimal_init.lua .
# Or with Make
make test
```

Run test based on tags
```sh
busted --helper spec/minimal_init.lua . --tags=simple
```


# Tracking Updates
See [doc/news.txt](doc/news.txt) for updates.

You can watch this plugin for changes by adding this URL to your RSS feed:
```
https://github.com/ColinKennedy/cursor-text-objects.nvim/commits/main/doc/news.txt.atom
```


# Other Plugins
This plugin is a sort-of successor to [vim-ninja-feet](https://github.com/tommcdo/vim-ninja-feet) with some notable differences

- visual mode support
- better edge-case handling
- (IMO) better documenting what the code does / how it works
