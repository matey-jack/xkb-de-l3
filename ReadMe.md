
Install replacing your existing config (or when you don't have any yet):

    rm -r ~/.config/xkb ; cp -r local-xkb ~/.config/xkb

If you have something else there, at least the rules/ need manual merging.

Enable with 

    gsettings set org.gnome.desktop.input-sources xkb-options "['custom:caps_shift', 'other:option', ...]"

For our first try, it's just

    gsettings set org.gnome.desktop.input-sources xkb-options "['custom:caps_shift']"

By the way, what already works on any system:

    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none']"
