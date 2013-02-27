#!/usr/bin/env ruby

# Purpose: Provide simple bot for #archlinuxvn
# Author : Anh K. Huynh <@archlinuxvn>
# License: GPLv2
# Date   : 2012 April 05
# NOTE   : the initial code is based on Cinch example

require 'rubygems'
require 'cinch'
require 'uri'
require 'open-uri'
require 'yaml'

require "#{File.dirname(__FILE__)}/lib/core.rb"

# Global variable
# FIXME: flush the CACHE after sometime. Otherwise, the system would run
# FIXME: out of the memory :) Check with garbage collection.
# FIXME: This is not good way to place global variables
BOT_NAME       = "archl0n0xvn"
BOT_CACHE      = {}
BOT_CACHE_TIME = 600 # 600 seconds aka 10 minutes
BOT_RC         = {}
BOT_RC_FILE    = File.join(ENV["HOME"], "etc/archlinuxvn.yaml")
BOT_NUTSHELL   = 100 # Default number of nutshells of all people

# FIXME: Logging support
BOT_LOGGER = File.open(File.join(File.dirname(__FILE__), "var/channels.log"), "a")
"Can't open log file 'var/channels.log' in a mode".die unless BOT_LOGGER
BOT_LOGGER.sync = false

# Plugin black list
BOT_PLUGINS_BLACKLIST = %w{log user_monitor}

# Load configuration from file
bot_rc_reload!

# List of channels
channels = Array.new(ARGV).map{|p| "##{p}"}.compact.uniq
"No channel specified".die if channels.empty?

plugins = Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].map do |p|
  p_name = File.basename(p, ".rb")
  class_name = p_name.camelize
  if BOT_PLUGINS_BLACKLIST.include?(p_name)
    nil
  else
    require p
    begin
      Object.const_get(class_name)
    rescue
      "Camelized class '#{class_name}' not found in '#{p}'".die
    end
  end
end.compact

bot = Cinch::Bot.new do
  configure do |c|
    c.server, c.ssl.use = "irc.freenode.org", true
    c.port, c.channels = 6697, channels
    c.nick = c.user = c.realname = BOT_NAME
    c.prefix = /^!/
    c.plugins.plugins = plugins
  end
end

# bot.loggers.level, bot.loggers.first.level = :warn, :warn
bot.start

BOT_LOGGER.close
