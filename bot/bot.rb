#!/usr/bin/env ruby

# Purpose: Provide simple bot for #archlinuxvn
# Author : Anh K. Huynh <@archlinuxvn>
# License: Fair license
# Date   : 2012 April 05
# NOTE   : the intial code is based on Cinch example

require 'rubygems'
require 'cinch'
require 'uri'
require 'open-uri'

# FIXME: Don't say hello too much
class Hello
  include Cinch::Plugin

  match /hello/

  def execute(m)
    m.reply "Hello, #{m.user.nick}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = ["#archlinuxvn"]
    c.nick = "archl0n0xvn"
    c.user = "archl0n0xvn"
    c.realname = "archl0n0xvn"
    c.plugins.plugins = [Hello]
  end

  # Say hello when someone has logged in

  # FIXME: This doesn't work
  on :message, /([^ ]+) \[(.+)@(.+)\] entered the room/ do |m, nick, user, host|
    m.reply "Hello, #{nick}. You come from #{host} using username = #{user}."
  end

  # FIXME: This doesn't work
  on :message, /^:(.+)!(.+)@(.+) JOIN #archlinuxvn/ do |m, nick, user, host|
    m.reply "Hello, #{nick}. You come from #{host}. Are you #{user}?"
  end

  # Say another hello to follow a previous Hello message
  # If A says Hi to B, the bot also says Hi to B (unless B is the bot itself)
  on :message, /^hello[\t ,]*([^\t ]+)/i do |m, text|
    if text.match("archl0n0xvn")
      m.reply "Hello, #{m.user.nick}"
    else
      m.reply "Hello, #{text}"
    end
  end

  # Same as above, with another form.
  # FIXME: Why not support two patterns in the same block?
  on :message, /^([^ ]: hello)/i do |m, nick|
    if nick.match("archl0n0xvn")
      m.reply "Hello, #{m.user.nick}"
    else
      m.reply "Hello, #{nick}"
    end
  end

  # Sensored words
  on :message, /(vcl|wtf|sh[1i]t|f.ck|d?k)/i do |m, text|
    m.reply "#{m.user.nick}: take it easy. don't say #{text}"
  end

  # A simple helper
  helpers do
    def shorten(url)
      url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
      url == "Error" ? nil : url
    rescue OpenURI::HTTPError
      nil
    end
  end

  on :channel do |m|
    urls = URI.extract(m.message, "http")

    unless urls.empty?
      short_urls = urls.map {|url| shorten(url) }.compact

      unless short_urls.empty?
        m.reply short_urls.join(", ")
      end
    end
  end
end

bot.start
