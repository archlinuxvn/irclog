#!/usr/bin/env ruby

# Purpose: Provide simple bot for #archlinuxvn
# Author : Anh K. Huynh <@archlinuxvn>
# License: Fair license
# Date   : 2012 April 05
# NOTE   : the initial code is based on Cinch example

require 'rubygems'
require 'cinch'
require 'uri'
require 'open-uri'

require "#{File.dirname(__FILE__)}/lib/core.rb"

# FIXME: Logging support
BOT_LOGGER = File.open(File.join(File.dirname(__FILE__), "var/channels.log"), "a")
"Can't open log file 'var/channels.log' in a mode".die unless BOT_LOGGER
BOT_LOGGER.sync = false

# List of channels
channels = Array.new(ARGV).map{|p| "##{p}"}.compact.uniq
"No channel specified".die if channels.empty?

# Plugin black list
BOT_PLUGINS_BLACKLIST = %w{log user_monitor}

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

bot.loggers.level, bot.loggers.first.level = :warn, :warn
bot.start

BOT_LOGGER.close
