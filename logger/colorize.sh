#!/bin/bash

# Purpose: Make chat log beautiful
# Author : Anh K. Huynh (kyanh@viettug.org)
# Date   : 2012 July 14th
# License: Fair license
# Link   : http://krazydad.com/tutorials/makecolors.php

_F_INPUT="$1"
_F_OUTPUT="$(dirname $_F_INPUT)/$(basename $_F_INPUT .txt).html"

[[ -f "$_F_INPUT"  ]]  || { echo >&2 "File not found $_F_INPUT"; exit 1; }
[[ ! -f "$_F_OUTPUT" ]]|| { echo >&2 "Output found $_F_OUTPUT"; exit 0; }

_C_SED="$(cat "$_F_INPUT" \
  | awk -F "<" '{print $2}' \
  | awk -F ">" '{print $1}' \
  | sed -e "s#_\+\$##g" \
        -e "s#[ ]\+##g" \
        -e "s#^@##g" \
  | grep -E "[a-z0-9]" \
  | sort -u \
  | sed -e "s!#!\\\\#!g" \
  | awk -vFREQ=$_FREQ '{printf("-e \"s#\\([ @~!]\\)\\(%s_*\\>\\)\\b#\\1<span style=\\\"color:rgb\\(%d,%d,%d\\)\\\">\\2</span>#g\" ", $0, 128 + 127*sin(NR*0.6), 128 + 127*sin(NR*0.6+2), 128 + 127*sin(NR*0.6 +4))}')"

{
  echo "<html><head>"
  echo "<title>ArchLinuxvn: IrcLogs: $(basename $_F_INPUT .txt)</title>"
  echo '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
  echo '<meta name="generator" content="git@github.com:archlinuxvn/irclog.git">'
  echo "</head><body>"
  echo "<h1>Statistics</h1>"
  echo "<pre>"
  cat "$_F_INPUT" \
  | awk -F "<" '{print $2}' \
  | awk -F ">" '{print $1}' \
    | sed -e "s#_\+\$##g" \
          -e "s#[ ]\+##g" \
          -e "s#^@##g" \
    | grep -E "[a-z0-9]" \
    | sort \
    | uniq -c \
    | sort -k 1 -n -r
  echo "</pre>"
  echo "<h1>Discussion</h1>"
  echo "<pre>"
  eval "cat $_F_INPUT | sed -e 's#<#\&lt;#g' -e 's#>#\&gt;#g' $_C_SED" \
    | sed -e "s#\(https\?://[^ <>]\+\)#<a href=\"\1\">\1</a>#g" \
    | sed -e "s#^\([ ]*\)\([0-9]\+0\)\t#\1<strong>\2</strong>\t#g"
  echo "</pre>"
  echo "</body></html>"
} > $_F_OUTPUT

touch -r $_F_INPUT $_F_OUTPUT
echo >&2 "Output written to $_F_OUTPUT"
