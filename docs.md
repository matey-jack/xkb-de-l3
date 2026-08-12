
# how to select xkb options at runtime

If your desired functionality already exists among xkb's numerous options, 
this is your easy solution.
It's also helpful if you made a few options and made them available with a single reboot,
because you can then toggle them on and off without additional reboots.

Example:

    gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:lsgt_switch']"

GSettings is GNOME's configuration store; dconf-editor is a GUI for the same data.
It takes effect immediately, no logout. 
Check the current value first with `gsettings get ...` so you don't clobber existing entries — 
it's a list, and multiple options are fine.

(For the console and for X11 sessions, the system-wide equivalent is XKBOPTIONS in /etc/default/keyboard, applied with sudo dpkg-reconfigure keyboard-configuration (or setupcon). Under a GNOME Wayland session the GSettings value wins for the graphical session.)

Some of the useful existing options are: 
 - Both Shifts together enable Caps Lock; one Shift key disables it
 - Both Shifts together enable Shift Lock; one Shift key disables it
 - CAPS key has many variants of Caps Lock and Shift Lock, and can serve as Escape, Backspace and almost every other modifier, but not Shift!
 - Use <> key as AltGr. (But one needs to separately configure a keymap which makes then <>| characters accessible!)
 - Use <> key as Shift – this is the workaround for haters of the short ISO Shift key.
 - Choose if . or , is on the NumPad – and even make it a four-level key, so you can have everything... as long as you use your other hand to hold the right modifier.

Other available keys in this gsettings schema:

    $ gsettings list-keys org.gnome.desktop.input-sources
    current
    mru-sources
    per-window
    show-all-sources
    sources
    xkb-model
    xkb-options

    $ gsettings get org.gnome.desktop.input-sources sources
    [('xkb', 'de')]

# how the options are defined

right side of a rule in the form `+level3(lsgt_switch)` means:
use the config item "lsgt_switch" from file "symbols/level3"!

inside files in symbol, the same is meant by something like

        include "level3(ralt_switch)"

I used ralt_switch as an example, because that is actually included by many keymaps,
whereas the lsgt_switch is only and extra option.

# how to define personal additions to xkb without reboot

Maybe this is new since I first modded xkb in Wayland in 2018.

~/.config/xkb/ can contain the full file and folder structure of /usr/share/X11/xkb/

We can ignore the .xml files, because UI tools only read that from the global location.
And we can ignore `base`, because only `evdev` is used on Wayland.

Adding our own options allows selection using `gsettings ... xkb-options` as shown above.
This would work for caps_shift option.


## we can validate rules before activating the custom option!

    sudo apt install libxkbcommon-tools
    xkbcli compile-keymap --rules evdev --layout de --options caps:shift_modifier | grep -A3 'key <CAPS>'
    xkbcli compile-keymap --rules evdev --layout de --options caps:shift_modifier 2>&1 | less

## option groups, and why ours ended up in the stock `caps` group

The `foo:` prefix of an option name is nothing but a UI grouping key. It does not have to
match the symbols file the rule points at, and upstream does not keep them matched either:
`caps:none` is `+capslock(none)` while `caps:internal` is a *types* rule, `+caps(internal)`.

libxkbregistry merges `<optionList>` the same way it merges variant lists, so declaring a
group that already exists adds options to it instead of replacing it (verified: the `caps`
group goes 16 -> 17 options). Declaring `<group allowMultipleSelection="false">` with just
`<name>caps</name>` is enough; description and exclusivity come from the stock file.

That matters, because the caps group is exclusive and ours genuinely belongs there — every
`caps:` option rebinds the Caps Lock key, so they were mutually exclusive all along; as a
`custom:` option in a multi-select group that was simply undeclared.

Two things caught me out:

* `caps:shift` is already taken — "Caps Lock acts as Shift *with locking*" — so the option
  is `caps:shift_modifier`, matching the stock `caps:ctrl_modifier` naming.
* Options merge in **rules-file order**, not in the order they appear in the gsettings
  list. With our rule before `! include %S/evdev`, a stale `caps:none` won and our option
  silently did nothing; after the include, ours wins. Hence the unusual include-first
  layout of `rules/evdev`.

And an XML landmine: a `--` anywhere inside an XML comment invalidates `evdev.xml`, and
libxkbregistry then skips the file *without failing* — GNOME just silently offers nothing.
`test.sh` now prints the parser errors.

### weirdly xkb 'variants' are listed in evdev.lst in a single namespace, yet the names are local to the file they are defined in.

I haven't quite figured out how xkb actually defines a variant. 
I will delay implementation of de(coding) or de+coding to research it a bit more.
I would like the option of selecting it via Super+space...

RESOLVED — implemented as `de+prog`. A variant is not a first-class thing at all:

* `de+prog` is split by GNOME into layout=de, variant=prog. The `+` is a desktop
  convention; xkb never sees it. `setxkbmap -layout de -variant prog` is the same input.
* The rules file is the whole mechanism. `*  *  =  pc+%l%(v)` expands to `pc+de(prog)`,
  i.e. "section `prog` of file `symbols/de`". So a variant is just a named
  `xkb_symbols` section, and the single namespace in evdev.lst is only the registry's
  flat presentation of (layout, variant) pairs — the names really are file-local.
* Include paths are searched `~/.config/xkb`, `~/.xkb`, `/etc/xkb`, `/usr/share/X11/xkb`.
  A local `symbols/de` shadows the system one *per section*: if the requested section is
  missing, libxkbcommon continues to the next path. That is what lets us add `prog`
  without losing plain `de` or the 19 upstream variants.
* libxkbregistry merges `evdev.xml` variant lists, so registering `prog` under `de` adds
  to the stock list rather than replacing it (verified: de goes 20 -> 21 entries).

Two dead ends, both verified on libxkbcommon 1.6.0, worth not retrying:

* Keeping a distinctly-named file and redirecting to it from a user rule
  (`* de prog = pc+deprog(basic)`) works **only in layout slot 1**. For slots 2-4 the
  `! model layout[N] = symbols` catch-all `+%l[N]%(v[N]):N` always wins, so
  `! model layout[N] variant[N] = symbols` rules never fire. Not our bug: upstream's own
  `ro`+`de` -> `ro(winkeys)` rule fails the same way in slot 2 on a stock system.
* The combined `layout(variant)` match form upstream uses (`* gr(extended) = ...`) is an
  X-server rules idiom that libxkbcommon does not implement — it fails in every slot.

And one landmine: a section named `basic` doing `include "de(basic)"` inside a local
`symbols/de` self-includes and **segfaults** libxkbcommon 1.6.0 (SIGSEGV, core dumped)
instead of reporting recursion.