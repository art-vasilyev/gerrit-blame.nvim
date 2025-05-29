# gerrit-blame.nvim

A Neovim plugin that enables quick navigation from `:Git blame` (fugitive blame) to the corresponding Gerrit review page.

---

## What it does

This plugin adds a keybinding `gR` in the `fugitiveblame` buffer that opens your web browser to the Gerrit review for the commit under the cursor.

By default, it targets the OpenStack Gerrit instance at [review.opendev.org](https://review.opendev.org), but it is configurable for other Gerrit installations.

---

## Installation

Use your preferred plugin manager, for example [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "art-vasilyev/gerrit-blame.nvim",
  dependencies = { "tpope/vim-fugitive" },
  config = function()
    require("gerrit-blame").setup()
  end,
}
```

---

## Usage

* Open `:Git blame` in a git repository (requires vim-fugitive).
* Move the cursor to the line with the commit you want to inspect.
* Press `gR` to open the corresponding Gerrit review page in your default browser.

---

## Configuration

```lua
require("gerrit-blame").setup({
  gerrit_hosts = { "review.opendev.org", "gerrit.mycompany.com" }, -- List of Gerrit hosts to recognize
  default_host = "review.opendev.org",                             -- Default host if origin remote is unrecognized
})
```

---

## Features

* Extracts the Change-Id from the commit message.
* Determines Gerrit host from the `origin` remote or falls back to the configured default.
* Only active in fugitiveblame buffers.
* Depends on `vim-fugitive`.

---

## Requirements

* [vim-fugitive](https://github.com/tpope/vim-fugitive)

---

## License

MIT
