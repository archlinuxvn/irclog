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
  on :message, /(vcl|wtf|sh[1i]t|f.ck|d[e3]k|clgt)/i do |m, text|
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

  on :message, /^archl0n0xvn: info/ do |m|
    m.reply "ArchLinuxVn aka Vietnamese Groups of ArchLinux Users"
    m.reply " * irc channel  #archlinuxvn on irc.freenode.net"
    m.reply " * homepage     http://archlinuxvn.tuxfamily.org/"
    m.reply " * mailing list http://groups.google.com/group/archlinuxvn"
    m.reply " * source code  http://github.com/archlinuxvn/"
  end

  on :message, /^archl0n0xvn: help/ do |m|
    m.reply "Available commands: info, help, tinyurl"
    m.reply "The bot will say hello sometimes"
    m.reply "To fix the bot's behavior, visit http://github.com/archlinuxvn/irclog"
  end

  # Provide a simple command , example
  # botname: tinyrul <your_url>. The bot will reply to the author
  # a tiny version of your URL. HTTP and HTTPS only.
  on :message, /^archl0n0xvn: tinyurl (https?:\/\/[^ ]+)/ do |m, url|
    # urls = URI.extract(m.message, "http")
    # puts ":::: #{urls}"
    urls = [] << url.strip
    unless urls.empty?
      short_urls = urls.map {|url| shorten(url) }.compact

      unless short_urls.empty?
        m.reply short_urls.join(", ")
      end
    end
  end
end

bot.start
