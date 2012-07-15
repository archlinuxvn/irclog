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

plugins = Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].map do |p|
  require p
  begin
    p_name = File.basename(p, ".rb").camelize
    Object.const_get(p_name)
  rescue => e
    STDERR.puts ":: Error: camelized class '#{p_name}' not found in '#{p}'"
    exit 1
  end
end

########################################################################
#                               MAIN BOT                               #
########################################################################

channels = Array.new(ARGV).map{|p| "##{p}"}
channels.uniq!

if channels.empty?
  STDERR.puts ":: Error: No channel specified"
  exit 1
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server, c.ssl.use = "irc.freenode.org", true
    c.port, c.channels = 6697, channels
    c.nick = c.user = c.realname = BOT_NAME
    c.prefix = /^!/
    c.plugins.plugins = plugins
  end
end

bot.start
