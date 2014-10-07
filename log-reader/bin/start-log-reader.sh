#!/bin/sh
# Purpose: Simple script to start irssi at bootime
# Link:    http://dragula.viettug.org/blogs/672
# Date:    2011 March 17th
# Author:  Anh K. Huynh
# License: Fair license

export _HOSTNAME="$(hostname -s)"

# Change irrsi username according to the hostname
sed -i \
  -e "s/_HOSTNAME_/$_HOSTNAME/g" \
  ~/.irssi/config

# On l00s5r, we doesn't save any log
if [ "$_HOSTNAME" = "l00s5r" ]; then
  sed -i -e '/\log open/d' ~/.irssi/startup
  sed -i -e '$ a/log open -targets #theslinux   /dev/null' ~/.irssi/startup
  sed -i -e '$ a/log open -targets #archlinuxvn /dev/null' ~/.irssi/startup
fi

# Disable loggers on some nodes.
if [ "$_HOSTNAME" = "l00s7r" -o "$_HOSTNAME" == "l00s5r" ]; then
  sed -i -e '/archlinuxvn/d' ~/.irssi/startup
fi

# Kill all previous session (if any)
killall irssi >/dev/null 2>&1
killall tmux  >/dev/null 2>&1

# Start new tmux session
tmux new-session -d -s 0
tmux new-window -t 0:1 -n 'irssi' 'irssi'
tmux select-window -t 0:1
tmux detach-client
