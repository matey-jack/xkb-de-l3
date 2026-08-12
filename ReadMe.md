# Deutsches Tastaturlayout mit besserem Zugriff auf Sonderzeichen für Programmierer

Dieses Repo ist für Linux mit Wayland. Ein ähnliches Konzept für Windows findet sich unter [matey-jack/keyboard-layer3](https://github.com/matey-jack/keyboard-layer3).

Viele deutsche Software-Entwickler benutzen das Amerikanische Tastaturlayout, weil dort die typischen Sonderzeichen für Programmierer leichter erreichbar sind:
 `{}[]\|^` und auch der Backtick \`, der z.B. hier in Markdown eine spezielle Funktion hat. Dieses Repo bietet eine bessere Lösung, da die Zeichen für Programmierer sogar eine noch bessere Position erhalten als auf der Amerikanischen Tastatur und gleichzeitig alle anderen Zeichen, insbesondere Umlaute und die beschrifteten Zeichen der Zahlenreihe erhalten bleiben! Erreicht wird das durch eine bessere Nutzung der AltGr-Ebene – und diese Ebene wird leichter erreichbar durch eine zweite AltGr-Taste für die linke Hand!

Die Belegung im Detail:
 * Die Symbole `^` und \` werden zu Belegungen der ersten Ebene auf ihren gewöhnlichen Tasten. Wenn man sie als Akzenttaste braucht, einfach AltGr+Taste drücken!
 * Shift+3 wird zu @ und das deutsche § wandert stattdessen auf AltGr+3.
 * `'` und `#` wechseln ihre Plätze, so dass der Apostroph bzw. 'single quote' ohne Shift erreichbar ist. `#` braucht dann wie im US Layout ein Shift. Beide bleiben aber auf derselben Taste.
 * (Wie man sieht, liegen die meisten geänderten Zeichen immer noch auf der Taste auf der sie auch beschriftet sind!)
 * Die Taste `<>|` wird zu AltGr.

TODO: bring remainder from plan.

## Belegung von CapsLock und andere Optionen

Man kann bereits im Standard-xkb sehr viele Varianten zur Nutzung der CapsLock-Taste auswählen:
 * TODO: copy

Man kann das aktivieren durch die "Gnome Tweaks" GUI Anwendung, oder folgenden Befehl:

        gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none']"

Nach Installation dieses Repos kommt noch eine Option hinzu, die leider im Standard fehlt:

        gsettings set org.gnome.desktop.input-sources xkb-options "['custom:caps_shift']"

Nach Installation und einem Neustart von Wayland wird diese auch in der Gnome Tweaks GUI angezeigt.

Auch eine andere Nutzung der Taste `<>|` ist im xkb Standard schon in verschiedenen Varianten enthalten:
 * als Shift (dann wird es ähnlich dem US Layout). TODO: option name
 * als AltGr (aber leider gehen ohne das Layout aus diesem Repo die Zeichen `<>|` dann verloren)
 * weitere: TODO

# Technical Implementation
A German keymap with a reworked AltGr layer for programming, plus a Caps-Lock-as-Shift
option, both as a *user-local* xkb configuration — no root, no system files touched,
and nothing that a `xkeyboard-config` package update can overwrite.

Works on Wayland (`~/.config/xkb` is a libxkbcommon feature). An Xorg session and the
text console read only `/usr/share/X11/xkb` and will ignore all of this.

## What is here

    config/xkb/rules/evdev       maps the option name to its symbols
    config/xkb/rules/evdev.xml   registers both with GNOME's UI (libxkbregistry)
    config/xkb/symbols/custom    the option:  custom:caps_shift
    config/xkb/symbols/decoding  the keymap:  German (coding)
    global-xkb/symbols/de        read-only reference copy of the stock German keymap
    test.sh                      compile and inspect without touching the session

`config/` is laid out so it can serve directly as `XDG_CONFIG_HOME`, which is what
`test.sh` does.

## Test

    ./test.sh

Compiles the keymap next to `us+altgr-intl`, prints what GNOME's UI will offer and a
table of all four levels of every key this repo changes. It never touches the running
session.

## Install

    ln -sfn "$PWD/config/xkb" ~/.config/xkb

A symlink means editing a file in the repo is immediately live — no re-copying. If you
already have a `~/.config/xkb`, merge by hand instead; `rules/evdev` in particular must
keep its `! include %S/evdev` line last.

Then select the keymaps and the option:

    gsettings set org.gnome.desktop.input-sources sources "[('xkb','decoding'), ('xkb','us+altgr-intl'), ('xkb','de')]"
    gsettings set org.gnome.desktop.input-sources xkb-options "['custom:caps_shift']"

Note `xkb-options` is a list that replaces the previous value, so a leftover
`'caps:none'` from earlier experiments has to go: it maps `<CAPS>` to `VoidSymbol` and
silently wins over `custom:caps_shift`, because options are merged in rules-file order
and this repo's rules come before the system ones.

Keeping plain `de` as a third entry is a safety net while the new keymap is still young;
drop it once you trust it.

**Log out once** after adding a *new* keymap name to `rules/evdev.xml` — GNOME reads the
registry at startup, so until then "German (coding)" will not appear in Settings or in the
Super+Space switcher.

## Daily use

Super+Space switches between the keymaps. Nothing else to run — the option applies to
every keymap (it is about the hands, not the characters), while the AltGr work lives
inside `decoding` only, so `us+altgr-intl` for the external keyboard stays untouched.

## Reload after editing

Editing `symbols/decoding` needs no logout, but mutter only recompiles when an input
setting changes. Toggle one:

    gsettings set org.gnome.desktop.input-sources xkb-options "[]" && \
    gsettings set org.gnome.desktop.input-sources xkb-options "['custom:caps_shift']"

Run `./test.sh` first — a keymap that fails to compile leaves you with the previous one
and no obvious error.

## Reference

By the way, what already works on any system without this repo:

    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none']"
