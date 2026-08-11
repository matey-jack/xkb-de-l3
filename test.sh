#!/bin/bash
# Compile and inspect the keymaps in this repo without touching the running
# session.  Works straight from the checkout: pointing XDG_CONFIG_HOME at
# ./config makes ./config/xkb the xkb user configuration root, which is the same
# thing libxkbcommon reads from ~/.config/xkb at runtime.
#
# Usage:  ./test.sh [keymap]        default keymap: decoding
set -u

cd "$(dirname "$0")" || exit 1
export XDG_CONFIG_HOME="$PWD/config"

KEYMAP=${1:-decoding}
SECOND=us
SECOND_VARIANT=altgr-intl
OPTIONS=custom:caps_shift

# Keys this repo changes, plus the ones it deliberately leaves alone.
KEYS="TLDE AE01 AE02 AE03 AE04 AE05 AE06 AE07 AE08 AE09 AE10 AE11 AE12
      AD03 AD07 AD08 AD09 AD10
      AC01 AC02 AC03 AC04 AC05 AC07 AC08 AC09 AC10 AC11
      AB05 AB06 AB07 AB08 AB09 AB10 LSGT CAPS LFSH RTSH"

echo "== registry (what GNOME's UI will offer) =================================="
REGISTRY=$(xkbcli list 2>/dev/null)
echo "$REGISTRY" | grep -A3 "^- layout: '$KEYMAP'" | sed 's/^/  /'
echo "$REGISTRY" | grep -A2 "name: 'custom:" | grep -v "^\s*brief:" | sed 's/^/  /'
echo

echo "== compiling $KEYMAP,$SECOND($SECOND_VARIANT) with options=$OPTIONS ======="
if ! xkbcli compile-keymap --rules evdev \
        --layout "$KEYMAP,$SECOND" --variant ",$SECOND_VARIANT" \
        --options "$OPTIONS" > /tmp/$$.xkb 2> /tmp/$$.err; then
    echo "FAILED"; cat /tmp/$$.err; rm -f /tmp/$$.xkb /tmp/$$.err; exit 1
fi
if [ -s /tmp/$$.err ]; then echo "warnings:"; sed 's/^/  /' /tmp/$$.err; fi
echo "  ok - $(grep -c 'key <' /tmp/$$.xkb) keys, groups: $(grep -h 'name\[Group' /tmp/$$.xkb | tr -d '\t' | tr '\n' ' ')"
echo

echo "== group 1 levels: base / Shift / AltGr / AltGr+Shift ====================="
python3 - /tmp/$$.xkb $KEYS <<'PY'
import re, sys
text = open(sys.argv[1]).read()
# Collect each key's Group1 symbol list from the compiled keymap.
keys = {}
for m in re.finditer(r'key <(\w+)>\s*\{(.*?)\};', text, re.S):
    name, body = m.group(1), m.group(2)
    g1 = re.search(r'symbols\[Group1\]=\s*\[(.*?)\]', body, re.S) or \
         re.search(r'\[(.*?)\]', body, re.S)
    if g1:
        keys[name] = [s.strip() for s in g1.group(1).split(',')]
for name in sys.argv[2:]:
    lv = keys.get(name, [])
    print("  %-5s %s" % (name, "  ".join("%-16s" % s for s in lv[:4])))
PY
rm -f /tmp/$$.xkb /tmp/$$.err
echo
echo "Nothing above touched your session.  See ReadMe.md to install and reload."
