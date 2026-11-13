#!/bin/sh
# Prints one of KEPLER_OPENED, KEPLER_NOT_INSTALLED, KEPLER_BAD_SESSION.
# KEPLER_SCHEME overrides the URL scheme for tests and source builds only.
LC_ALL=C; export LC_ALL # byte ranges, so [a-z] cannot match uppercase
scheme=${KEPLER_SCHEME:-kepler}
case $scheme in
  [a-z]*) ;;
  *) echo KEPLER_BAD_SESSION; exit 0 ;;
esac
case $scheme in
  *[!a-z0-9+.-]*) echo KEPLER_BAD_SESSION; exit 0 ;;
esac
id=$1
case $id in
  ''|*[!A-Za-z0-9_-]*) echo KEPLER_BAD_SESSION; exit 0 ;;
esac
url="$scheme://session?agent=claude-code&id=$id&new=1"

report() { if [ "$1" -eq 0 ]; then echo KEPLER_OPENED; else echo KEPLER_NOT_INSTALLED; fi; }

case $(uname -s) in
  Darwin)
    open "$url" >/dev/null 2>&1; report $? ;;
  Linux)
    # xdg-open exits 0 or prompts even with no handler, so ask for the handler first
    if [ -z "$(xdg-mime query default "x-scheme-handler/$scheme" 2>/dev/null)" ]; then
      echo KEPLER_NOT_INSTALLED
    else
      xdg-open "$url" >/dev/null 2>&1; report $?
    fi ;;
  MINGW*|MSYS*|CYGWIN*)
    powershell.exe -NoProfile -Command "Start-Process '$url'" >/dev/null 2>&1; report $? ;;
  *) echo KEPLER_NOT_INSTALLED ;;
esac
