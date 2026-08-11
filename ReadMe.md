
Install with `cp -r xkb ~/.config`.

Enable with 

    gsettings set org.gnome.desktop.input-sources xkb-options "['custom:caps_shift', 'other:option', ...]"

For our first try, it's just

    gsettings set org.gnome.desktop.input-sources xkb-options "['custom:caps_shift']"

By the way, what already works on any system:

    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none']"
