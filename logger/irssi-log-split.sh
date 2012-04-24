#!/bin/bash

# Purpose: Get the chat logs of the last day from `archlinuxvn.log.gz`.
#          You need to fix the log format in irrssi by
#               /SET log_timestamp = %Y-%m-%d %H:%S
# Author : Anh K. Huynh (kyanh@viettug.org)
# Date   : 2012 Mar 17th
# License: Fair license

_YESTERDAY="$(date -d yesterday +"%Y-%m-%d")"
_DATE="${DATE:-$_YESTERDAY}"
_D_OUTPUT="./archives/"                    # output directory
_F_OUTPUT="$_D_OUTPUT/$_DATE.txt"     # output file

if [[ -f "$_F_OUTPUT.gz" ]]; then
  echo >&2 ":: The file $_D_OUTPUT/$_DATE.txt.gz does exist"
  echo >&2 ":: You must examine and remove that file to continue"
  echo >&2 ":: The program now exit (0)."
  exit 0
fi

# list all days
cat \
  | grep "^$_DATE " \
  | sed -e "s#^$_DATE ##g" \
  | gzip -9c \
  > $_F_OUTPUT.gz
