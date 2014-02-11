#!/bin/sh
# Purpose: Simple script to start irssi at bootime
# Link:    http://dragula.viettug.org/blogs/672
# Date:    2011 March 17th
# Author:  Anh K. Huynh
# License: Fair license

tmux new-session -d -s 0
tmux new-window -t 0:1 -n 'irssi' 'irssi'
tmux select-window -t 0:1
tmux detach-client
