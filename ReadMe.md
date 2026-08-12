A German keymap with a reworked AltGr layer for programming, plus a Caps-Lock-as-Shift
option, both as a *user-local* xkb configuration — no root, no system files touched,
and nothing that a `xkeyboard-config` package update can overwrite.

Works on Wayland (`~/.config/xkb` is a libxkbcommon feature). An Xorg session and the
text console read only `/usr/share/X11/xkb` and will ignore all of this.

## What is here

    config/xkb/rules/evdev       maps the option name to its symbols
    config/xkb/rules/evdev.xml   registers both with GNOME's UI (libxkbregistry)
    config/xkb/symbols/custom    the option:  caps:shift_modifier
    config/xkb/symbols/de        the keymap:  de+prog  "Deutsch (Programmierung)"
    global-xkb/symbols/de        read-only reference copy of the stock German keymap
    test.sh                      compile and inspect without touching the session

`config/` is laid out so it can serve directly as `XDG_CONFIG_HOME`, which is what
`test.sh` does.

## How `de+prog` finds its way here

The `+` in `de+prog` is a GNOME convention, not xkb syntax: GNOME splits the input
source on it into layout `de` and variant `prog`, then the stock rule

    *  *  =  pc+%l%(v)

in `/usr/share/X11/xkb/rules/evdev` expands that to `pc+de(prog)`. Since `~/.config/xkb`
comes first in the include path and this repo has a `symbols/de`, the lookup lands on
`config/xkb/symbols/de`. Nothing in `rules/evdev` is needed for the keymap — only the
option needs a rule.

Shadowing the system's `symbols/de` sounds risky but is not, because libxkbcommon keeps
searching the remaining include paths when the *section* it wants is absent from the
first file it finds. Only `prog` is defined here, so plain `de` and every stock variant
(`neo`, `nodeadkeys`, …) still resolve to `/usr/share/X11/xkb/symbols/de`. `test.sh`
guards that explicitly. Two rules keep it that way:

* the `passthrough` section must stay marked `default`, otherwise plain `de` silently
  picks the first section in the file and becomes the coding keymap;
* no section here may be named `basic` — `include "de(basic)"` would then match itself
  and libxkbcommon 1.6.0 **segfaults** rather than reporting the recursion.

## Test

    ./test.sh

Compiles the keymap next to `us+altgr-intl`, prints what GNOME's UI will offer, checks
that plain `de` is still the stock German keymap, and shows a table of all four levels
of every key this repo changes. It never touches the running session.

## Install

    rm -rf ~/.config/xkb && cp config/xkb" ~/.config/xkb

If you already have any custom config there, you need to merge at least the `rules/evdev` file by hand.

If you like to live on the edge, you can also symlink:

    ln -sfn "$PWD/config/xkb" ~/.config/xkb

I am not doing that, because I want to run the tests (see `test.sh`) on any changes before they go live.
(And running tests might cause a reload of config already, since they call global commands, even if only with local data.)

Then select the keymaps and the option:

    gsettings set org.gnome.desktop.input-sources sources "[('xkb','de+prog'), ('xkb','us+altgr-intl'), ('xkb','de')]"
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:shift_modifier']"

`caps:shift_modifier` is registered into the stock `caps` option group, which is
`allowMultipleSelection="false"`, so the UI now shows it as one radio button next to
`caps:none`, `caps:escape` and the other thirteen. That is what it always was in
practice — all of them rebind Caps Lock — it just used to be undeclared.

It is *not* called `caps:shift`: upstream already uses that name for "Caps Lock acts as
Shift **with locking**". The suffix follows the stock `caps:ctrl_modifier` instead.

Because our rule sits after the include, it is merged last and wins, so a leftover
`'caps:none'` from earlier experiments can no longer silently disable the option — the
failure mode this repo hit before. `test.sh` checks that. Clearing the list is still
tidier, and `xkb-options` replaces rather than appends, so the command above does it.

Keeping plain `de` as a third entry is a safety net while the new keymap is still young;
drop it once you trust it.

**Log out once** after adding a *new* keymap name to `rules/evdev.xml` — GNOME reads the
registry at startup, so until then "Deutsch (Programmierung)" will not appear in Settings
or in the Super+Space switcher. It is listed under German, alongside Neo 2 and the other
`de` variants.

## Daily use

Super+Space switches between the keymaps. Nothing else to run — the option applies to
every keymap (it is about the hands, not the characters), while the AltGr work lives
inside the `prog` variant only, so `us+altgr-intl` for the external keyboard stays
untouched.

## Reload after editing

Editing `symbols/de` needs no logout, but mutter only recompiles when an input
setting changes. Toggle one:

    gsettings set org.gnome.desktop.input-sources xkb-options "[]" && \
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:shift_modifier']"

Run `./test.sh` first — a keymap that fails to compile leaves you with the previous one
and no obvious error.

## Reference

By the way, what already works on any system without this repo:

    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none']"
