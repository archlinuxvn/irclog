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

# Load core library and all plugins
require "#{File.dirname(__FILE__)}/lib/core.rb"
Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each {|file| require file }

########################################################################
#                               MAIN BOT                               #
########################################################################

channels = Array.new(ARGV).map{|p| "##{p}"}
channels.uniq!

if channels.empty?
  STDERR.write(":: Error: You must specify at least on channel at command line.\n")
  exit 1
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.port = 6697
    c.channels = channels
    c.nick = c.user = c.realname = BOT_NAME
    c.prefix = /^!/
    c.ssl.use = true
    c.plugins.plugins = [
        Hello,
        Sensor,
        UserMonitor,
        TinyURL,
        Info,
        Give,
        Bot,
      ]
  end
end

bot.start
