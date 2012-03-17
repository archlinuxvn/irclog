#!/bin/bash

# Purpose: Clean up, remove all users's ip address
#          Move files to better hiearachy
# Author : Anh K. Huynh
# License: Fair license
# Date   : 2012 March 17th

for f in ./archives/*.txt; do
  _month="$(basename $f | awk -F '-' '{printf("%s/%s\n", $1, $2)}')"
  _d_month="./www/irclogs/$_month/"
  _f_output="$_d_month/$(basename $f)"

  if [[ ! -f $_f_output || $_f_output -ot $f ]]; then
    echo ":: Processing $f... -> ./www/irclogs/"
    mkdir -pv "$_d_month/"
    cat $f \
      | sed -e 's#[.0-9]\+\]#1.2.3.4]#g' \
      | fold -s -w 150 \
      > $_f_output
    touch -r $f $_f_output
  else
    echo ":: File $_f_output is newer than the source $f"
  fi
done
