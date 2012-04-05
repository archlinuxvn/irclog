#!/usr/bin/env ruby

# Purpose: Provide simple bot for #archlinuxvn
# Author : Anh K. Huynh <@archlinuxvn>
# License: Fair license
# Date   : 2012 April 05

require 'rubygems'
require 'cinch'
require 'uri'

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

  on :message, /([^ ]+) \[(.+)@(.+)\] entered the room/ do |m, nick, user, host|
    m.reply "Hello, #{nick}. You come from #{host} using username = #{user}."
  end

  on :message, /hello[\t ,]*([^\t ]+)/i do |m, text|
    if text.match("archl0n0xvn")
      m.reply "Hello, #{m.user.nick}"
    else
      m.reply "Hello, #{text}"
    end
  end

  on :message, /archl0n0xvn: hello.*/i do |m|
    m.reply "Hello, #{m.user.nick}"
  end

  on :message, /vcl/i do |m|
    m.reply "#{m.user.nick}: ba.n la.i du`ng Vcl de^? xem ph1m chon^'ng my~ a?"
  end

  on :message, /^:(.+)!(.+)@(.+) JOIN #archlinuxvn/ do |m, nick, user, host|
    m.reply "Hello, #{nick}. You come from #{host}. Are you #{user}?"
  end

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
