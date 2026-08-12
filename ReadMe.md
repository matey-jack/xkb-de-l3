# Deutsches Tastaturlayout mit besserem Zugriff auf Sonderzeichen für Programmierer

Dieses Repo ist für Linux mit Wayland. Ein ähnliches Konzept für Windows findet sich unter [matey-jack/keyboard-layer3](https://github.com/matey-jack/keyboard-layer3).

Viele deutsche Software-Entwickler benutzen das Amerikanische Tastaturlayout, weil dort die typischen Sonderzeichen für Programmierer leichter erreichbar sind:
 `{}[]\|^` und auch der Backtick \`, der z.B. hier in Markdown eine spezielle Funktion hat. Dieses Repo bietet eine bessere Lösung, da die Zeichen für Programmierer sogar eine noch bessere Position erhalten als auf der Amerikanischen Tastatur und gleichzeitig alle anderen Zeichen, insbesondere Umlaute und die beschrifteten Zeichen der Zahlenreihe erhalten bleiben! Erreicht wird das durch eine bessere Nutzung der AltGr-Ebene – und diese Ebene wird leichter erreichbar durch eine zweite AltGr-Taste für die linke Hand!

Die Belegung im Detail:
 * Die Symbole `^` und \` werden zu Belegungen der ersten Ebene auf ihren gewöhnlichen Tasten. Wenn man sie als Akzenttaste braucht, einfach AltGr+Taste drücken!
 * Shift+3 wird zu @ und das deutsche § wandert stattdessen auf AltGr+3.
 * `'` und `#` wechseln ihre Plätze, sodass der Apostroph bzw. 'single quote' ohne Shift erreichbar ist. 
   `#` braucht dann wie im US Layout ein Shift. Beide bleiben aber auf derselben Taste.
 * (Wie man sieht, liegen die meisten geänderten Zeichen immer noch auf der Taste auf der sie auch beschriftet sind!)
 * Die Taste `<>|` wird zu AltGr.

## Basis- und Shift-Ebene

```
^°  1!  2"  3@  4$  5%  6&  7/  8(  9)  0=  ß?  `´   ⌫ ⌫
  ⇥   qQ  wW  eE  rR  tT  zZ  uU  iI  oO  pP  üÜ  +*  ↵↵
  ⇪⇪   aA  sS  dD  fF  gG  hH  jJ  kK  lL  öÖ  äÄ  '#  ↵
 ⇧⇧  ⎇   yY  xX  cC  vV  bB  nN  mM  ,;  .:  -_  ⇧⇧
```

Jede Taste ist vier Spalten breit (ein Zeichen = 1/4 Taste), daher sind die Zeilen
genauso versetzt wie auf der physischen Tastatur. Das erste Zeichen einer Taste ist
die Basis-, das zweite die Shift-Ebene. Modifikatoren: `⇥` Tab, `⇪⇪` CapsLock,
`⇧⇧` Shift, `⎇` AltGr, `↵` Enter, `⌫` Backspace.

## AltGr- und AltGr+Shift-Ebene

```
^    ¡  #¤  §£  €¢  ‰   |   {   [   ]   }   \¿  `  ⌫ ⌫
  ⇥           ↑               \   {   }   ~        ↵↵
  ⇪⇪   ⇱   ←   ↓   →   ⇲       /   (   )   ;        ↵
 ⇧⇧  ⎇                   ⌦   ×   =µ  <   >   –   ⇧⇧
```

Gleiche Darstellung, aber erstes Zeichen = AltGr, zweites = AltGr+Shift. Gezeigt ist
nur, was zur Programmier-Belegung gehört (einiges davon stimmt schon mit `de(basic)`
überein); alle übrigen Positionen behalten ihre Standard-Belegung und sind hier der
Übersicht halber leer gelassen.

 * `^` auf der `^`-Taste und `` ` `` auf der `´`-Taste sind hier ausschließlich die
   *Akzent*-Varianten (Tot-Tasten); die "lebenden" Zeichen gibt es nur einmal, auf
   der Basis-Ebene derselben Tasten.
 * Navigation: `⇱` Pos1, `⇲` Ende, `←` `↓` `↑` `→` Pfeile, `⌦` Entf. Diese liegen
   absichtlich auf beiden Ebenen, damit AltGr+Shift+s auch markiert.
 * Die Tasten `\`, `{` und `}` sind auf der AltGr-Ebene doppelt belegt 
   und `/`, `(`, `)`, `;`, `=` sind doppelt hier und auf der üblichen Position der Shift-Ebene belegt,
   damit die gewohnten Positionen aus dem deutschen Standard-Layout weiter funktionieren.

## Belegung von CapsLock und andere Optionen

Man kann bereits im Standard-xkb sehr viele Varianten zur Nutzung der CapsLock-Taste auswählen:
 * TODO: add screenshot from gnome-tweaks or list of options

Man kann das aktivieren durch die "Gnome Tweaks" GUI Anwendung, oder folgenden Befehl:

        gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none']"

Nach Installation dieses Repos kommt noch eine Option hinzu, die leider im Standard fehlt:

        gsettings set org.gnome.desktop.input-sources xkb-options "['custom:caps_shift']"

Nach Installation und einem Neustart von Wayland wird diese auch in der Gnome Tweaks GUI angezeigt.

Auch eine andere Nutzung der Taste `<>|` ist im xkb Standard schon in verschiedenen Varianten enthalten:
 * als Shift (dann wird es ähnlich dem US Layout). TODO: option name
 * als AltGr (aber leider gehen ohne das Layout aus diesem Repo die Zeichen `<>|` dann verloren)
 * weitere: TODO


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
