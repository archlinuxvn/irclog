#!/bin/bash

# Purpose: Read the password save in the external file htpasswd
#          and generate the crypt form which is ready for basic
#          authentication on web server
# Author : Anh K. Huynh
# Date   : 2011 March 17th
# License: Fair license

printf "foobar:$(openssl passwd -crypt $(head -1 htpasswd))\n"
