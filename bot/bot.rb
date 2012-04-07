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

BOT_NAME = "archl0n0xvn"

########################################################################
#                               PLUGINS                                #
########################################################################

class IcyUserMonitor
  include Cinch::Plugin

  listen_to :connect, method: :on_connect
  listen_to :online,  method: :on_online
  #listen_to :offline, method: :on_offline

  # def on_offline(m, user)
  #   @bot.loggers.info "I miss my master :("
  # end

  def on_connect(m)
    User(m.user.nick).monitor
  end

  # Say hello when someone has logged in
  def on_online(m, user)
    user.send "Hello #{m.user.nick}"
  end
end

# Say another hello to follow a previous Hello message
# If A says Hi to B, the bot also says Hi to B (unless B is the bot itself)
class IcyHello
  include Cinch::Plugin

  listen_to :message

  def listen(m)
    text = nil
    if gs = m.message.match(/^hello[\t ,]*([^\t ]+)/i)
      text = gs[1]
    elsif gs = m.message.match(/^([^ ]: hello)/i)
      text = gs[1]
    end

    return unless text

    if text.match(BOT_NAME)
      m.reply "Hello, #{m.user.nick}"
    else
      m.reply "Hello, #{text}"
    end
  end
end

# Provice command !tinyurl
class IcyCmdTinyURL
  include Cinch::Plugin

  listen_to :message

  # Provide a simple command , example
  # botname: tinyrul <your_url>. The bot will reply to the author
  # a tiny version of your URL. HTTP and HTTPS only.
  def tinyurl(url)
    url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
    url == "Error" ? nil : url
  rescue OpenURI::HTTPError
    nil
  end

  def listen(m)
    if gs = m.message.match(/^!tinyurl (https?:\/\/[^ ]+)/)
      url = gs[1]
      if url_ = tinyurl(url)
        m.reply "#{url_} <- #{url.slice(0, 20)}"
      end
    end
  end
end

# Micesslaneous commands to interact with Arch wiki, forum,...
class IcyCmdArchStuff
  include Cinch::Plugin

  listen_to :message

  def listen(m)
    if gs = m.message.match(/^!arch (.+)/)
      m.reply "https://wiki.archlinux.org/index.php/Special:Search/#{gs[1].strip}"
    elsif gs = m.message.match(/!give ([^ ]+) wiki (.+)/)
      someone, wiki = gs[1].strip, gs[2].strip
      m.reply "#{someone}: https://wiki.archlinux.org/index.php/Special:Search/#{wiki}"
    end
  end
end

# Provide basic commands
class IcyCmdBasic
  include Cinch::Plugin

  listen_to :message

  def listen(m)
    if m.message.match(/^!info/)
      m.reply "ArchLinuxVn aka Vietnamese Groups of ArchLinux Users"
      m.reply " * irc channel #archlinuxvn on irc.freenode.net"
      m.reply " * homepage http://archlinuxvn.tuxfamily.org/"
      m.reply " * mailing list http://groups.google.com/group/archlinuxvn"
      m.reply " * source code http://github.com/archlinuxvn/"
    elsif m.message.match(/^!help/)
      m.reply "To send command, use !command."
      m.reply "Available commands: info, help, tinyurl, arch"
      m.reply "The bot will say hello sometimes."
      m.reply "To fix the bot's behavior, visit http://github.com/archlinuxvn/irclog"
    end
  end
end

# Provide basic sensor :)
class IcySensor
  include Cinch::Plugin

  listen_to :message

  def listen(m)
    if gs = m.message.match(/\b(vcl|wtf|sh[1i]t|f.ck|d[e3]k|clgt)\b/i)
      m.reply "#{m.user.nick}: take it easy. don't say #{gs[1]}"
    end
  end
end

########################################################################
#                               MAIN BOT                               #
########################################################################

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = ["#archlinuxvn"]
    c.nick = c.user = c.realname = BOT_NAME
    c.plugins.plugins = [
        IcyHello,
        IcySensor,
        IcyUserMonitor,
        IcyCmdTinyURL,
        IcyCmdBasic,
        IcyCmdArchStuff,
      ]
  end
end

bot.start
