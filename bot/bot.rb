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
#                              HELPERS                                 #
########################################################################

# Provide a simple command , example
# botname: tinyrul <your_url>. The bot will reply to the author
# a tiny version of your URL. HTTP and HTTPS only.
def tinyurl(url)
  url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
  url == "Error" ? nil : url
rescue OpenURI::HTTPError
  nil
end

########################################################################
#                               PLUGINS                                #
########################################################################

class UserMonitor
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
class Hello
  include Cinch::Plugin

  listen_to :message

  set(:help => "Say Hello if someone says hello to someone else")

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
class TinyURL
  include Cinch::Plugin

  set :help => "Make a shorten version of an URL. Syntax: !tinyurl <long URL>. To send the output to someone, try !give <someone> tinyurl <long URL>."

  match /tinyurl (https?:\/\/[^ ]+)/, :method => :simple_form

  def simple_form(m, url)
    if url_ = tinyurl(url)
      m.reply "#{url_} <- #{url.slice(0, 20)}"
    end
  end
end

# Micesslaneous commands to interact with Arch wiki, forum,...
class Give
  include Cinch::Plugin

  set :help => "Give something to someone. Syntax: !give <someone> <section> <arguments>. <section> may be wiki, tinyurl, some."

  match /give ([^ ]+) ([^ ]+)(.*)/, :method => :give_something

  def give_something(m, someone, section, args)
    args.strip!
    someone = "#{m.user.nick}" if %{me /me}.include?(someone)

    text = case section
    when "wiki" then
      wiki = args.gsub(" ", "%20")
      wiki ? "https://wiki.archlinux.org/index.php/Special:Search/#{wiki}" : nil
    when "tinyurl" then
      tinyurl(args)
    when "some"
      case args
        when "thanks" then "Thank you very much"
        when "shit"   then "Oh, you ... s^ck"
        when "hugs"   then "Oh, let me hold you tight"
        when "kiss"   then "Kiss you a thousand times"
        when "helps"  then "You wanna try google instead"
        else
          if m.user.nick == someone
            "Sorry #{someone}. I have nothing good for you"
          else
            "#{m.user.nick} wants me to delivery to you some #{args}"
          end
      end
    else
      ""
    end

    if text
      if not text.empty?
        m.reply "#{someone}: #{text}"
      else
        m.reply "#{m.user.nick}: nothing to give to #{someone}"
      end
    end
  end
end

# Provide basic commands
class Basic
  include Cinch::Plugin

  set(:help => "Provide basic information about ArchLinuxVn. Syntax: !info <section>. <section> may be: home, list, repo or empty. If you want to find helps about the bot, try `!bot help` instead.")

  match /info (.+)/,  :method => :bot_info

  def bot_info(m, section)
    text = case section
      when "home" then "http://archlinuxvn.tuxfamily.org/"
      when "list" then "http://groups.google.com/group/archlinuxvn"
      when "repo" then "http://github.com/archlinuxvn/"
      else nil
    end
    m.reply "#{m.user.nick}: #{text}" if text
  end
end

# Provide basic sensor :)
class Sensor
  include Cinch::Plugin

  set :help => "Send warning if user says bad words."
  listen_to :message

  def listen(m)
    if gs = m.message.match(/\b(vcl|wtf|sh[1i]t|f.ck|d[e3]k|clgt)\b/i)
      m.reply "#{m.user.nick}: take it easy. don't say #{gs[1]}"
    end
  end
end

class BotUtils
  include Cinch::Plugin

  set :help => "Query bot information. Syntax: !bot <section>, where section is: help, uptime, uname"

  match /bot (.+)/, :method => :give_bot_info

  def give_bot_info(m, cmd)
    text = case cmd
      when "uptime"   then %x{uptime}.strip
      when "uname"    then %x{uname -a}.strip
      when "help"     then "Commands are provided by plugins. " <<
                            "To send command, use !command. " <<
                            "To get help message, type !help <plugin name in lowercase>. " <<
                            "Available plugins: Hello, TinyUrl, Give, BotUtils, Sensor, Basic. " <<
                            "To test the development bot, join #archlinuxvn_bot_devel. " <<
                            "To fix the bot's behavior, visit http://github.com/archlinuxvn/irclog."
      else nil
    end
    m.reply "#{m.user.nick}: #{text}" if text
  end
end

########################################################################
#                               MAIN BOT                               #
########################################################################

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.port = 6697
    c.channels = ["#archlinuxvn", "#archlinuxvn_bot_devel"]
    c.nick = c.user = c.realname = BOT_NAME
    c.prefix = /^!/
    c.ssl.use = true
    c.plugins.plugins = [
        Hello,
        Sensor,
        UserMonitor,
        TinyURL,
        Basic,
        Give,
        BotUtils,
      ]
  end
end

bot.start
