#!/bin/sh
# Stubs the OS tools on PATH and asserts the script's single output line.
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail=0
stub() { printf '#!/bin/sh\n%s\n' "$2" >"$tmp/$1"; chmod +x "$tmp/$1"; }
reset() { rm -f "$tmp"/*; : >"$tmp/calls"; }

run() { # name expected session [env...]
  name=$1 want=$2 sid=$3; shift 3
  got=$(env "$@" PATH="$tmp:$PATH" sh "$here/open-in-kepler.sh" "$sid")
  if [ "$got" = "$want" ]; then echo "ok   $name"; else echo "FAIL $name: got '$got', want '$want'"; fail=1; fi
}
called() { grep -q "$1" "$tmp/calls"; }

KEPLER_OPENED="Moving this session to Kepler. This terminal will close."
KEPLER_NOT_INSTALLED="Kepler isn't installed. Download it at https://www.gitkraken.com/kepler"
KEPLER_BAD_SESSION="Kepler could not be opened from this session."
S=abc-123_X
reset; stub uname 'echo Darwin'; stub open 'exit 0'
run "macOS opened" "$KEPLER_OPENED" $S X=1
reset; stub uname 'echo Darwin'; stub open 'exit 1'
run "macOS not installed" "$KEPLER_NOT_INSTALLED" $S X=1

reset; stub uname 'echo Linux'; stub xdg-mime 'echo kepler.desktop'; stub xdg-open "echo xdg-open >>$tmp/calls"
run "Linux handler present" "$KEPLER_OPENED" $S X=1
called xdg-open && echo "ok   xdg-open called" || { echo "FAIL xdg-open not called"; fail=1; }
reset; stub uname 'echo Linux'; stub xdg-mime 'exit 0'; stub xdg-open "echo xdg-open >>$tmp/calls"
run "Linux handler absent" "$KEPLER_NOT_INSTALLED" $S X=1
called xdg-open && { echo "FAIL xdg-open called without handler"; fail=1; } || echo "ok   xdg-open not called"

reset; stub uname 'echo MINGW64_NT-10.0'; stub powershell.exe 'exit 0'
run "Windows success" "$KEPLER_OPENED" $S X=1
reset; stub uname 'echo MINGW64_NT-10.0'; stub powershell.exe 'exit 1'
run "Windows failure" "$KEPLER_NOT_INSTALLED" $S X=1

reset; stub uname 'echo Darwin'; stub open "echo open >>$tmp/calls"
run "bad session id" "$KEPLER_BAD_SESSION" 'a;b' X=1
run "empty session id" "$KEPLER_BAD_SESSION" '' X=1
run "bad scheme" "$KEPLER_BAD_SESSION" $S KEPLER_SCHEME='x://;rm'
run "uppercase scheme" "$KEPLER_BAD_SESSION" $S KEPLER_SCHEME=Kepler
called open && { echo "FAIL open called on invalid input"; fail=1; } || echo "ok   open not called on invalid input"

exit $fail
