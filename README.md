# My Dots

## How This Works

The simple single file PowerShell module does the following:

- `Initialize-Dots` - Ensures you have a `git` repository and creates a local tracking file (_dots.json_).
- `Add-Dots` - Adds config files that need to be tracked to _dots.json_ and copies them to the `git` repo location.
- `Sync-Dots` - Syncs the **repo** to local files if there is a SHA256 checksum hash difference.

## What Needs to Be Done _Eventually_

- Alias the functions
- Alias the parameters
- A metric TON of cleanup
- Better error handling
- Functions that are missing and need to be added
  * `Update-Dots` - Update dots from Local to the Repo when Local is newer (or the desired version)
  * `Remote-Dots` - Remove dots from being tracked
- Add help


## Machine Profiles

Machine profiles alleviate the need for templating, git branches, and other similar work arounds.
Yes, this is a different form complexity, but it works _EXACTLY_ for what I need and to be selfish, I wrote this for me.
If you can use it, I hope it helps.  If not, there are TONS of tools and patterns that might suit you better!

- _common_ for shared files, these file need to be the same on ALL of my machines.
- _desktop_ for desktop specific configs (generally window manager related items)
- _laptop_ for laptop specific configs (generally window manager related items)

You can add a 'Machine Profile' with any name really.  I just keep it simple.

## Non-Useful History

How I ended up here.

- I found `chezmoi` extremely annoying to use.
  * I don't want to manage numerous templates for small differences in something like a Hyprland/sway/i3 config.
  * Templating my dotfiles makes abstracts it and makes it a pain to clearly see what is applied where.
- I tried other tools like `stow`.
  * I found them also to be a bit too perscriptive with things like symlinking.
- I need to manage similar yet different files between my desktop and laptop.
  * I found the [bare git repository] to be super annoying for managing differences.
  * I won't entertain using git branches since managing gitflow just for dotfiles feels insane.

I completely admit and probably agree if you are reading this I am being too picky.
Choice and customization are beautiful things, and this is what I choose.

Simple. Done.  No more non-sense with solutions in search of problems.

Also if this breaks it's 100% on me and I can live with that.
