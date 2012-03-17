#!/bin/bash

# Purpose: Get the chat logs of the last day from `archlinuxvn.log.gz`.
#          You need to fix the log format in irrssi by
#               /SET log_timestamp = %Y-%m-%d %H:%S
# Author : Anh K. Huynh (kyanh@viettug.org)
# Date   : 2012 Mar 17th
# License: Fair license


_D_OUTPUT="./archives/"                    # output directory
_F_OUTPUT="./archives/output.txt"          # output file
_YESTERDAY="$(date -d yesterday +"%Y-%m-%d")"

if [[ -f "$_D_OUTPUT/$_YESTERDAY.txt" ]]; then
  echo >&2 ":: The file $_D_OUTPUT/$_YESTERDAY.txt does exist"
  echo >&2 ":: You must examine and remove that file to continue"
  echo >&2 ":: The program now exit (0)."
  exit 0
fi

# list all days
cat \
  | grep "^$_YESTERDAY " \
  | sed -e "s#^$_YESTERDAY ##g" \
  > $_F_OUTPUT
