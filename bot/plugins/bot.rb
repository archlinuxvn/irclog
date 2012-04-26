# Purpose  : Provide basic bot information
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michale Learns To Rock)

class Bot
  include Cinch::Plugin

  set :help => "Query bot information. Syntax: !bot <section>, where section is: help, uptime, uname. You can also check the connection between you and the bot by the !ping command."

  match /bot ([^ ]+)(.*)/, :method => :give_bot_info
  match /ping/,            :method => :ping_pong
  match /help$/,           :method => :help_user

  def help_user(m)
    m.reply "#{m.user.nick}: try `/help` or `!help <plugin_name>`. The first command is the builtin command of your IRC client. The later will query the bot. If you are not sure, you may start with `!help bot` or `!bot help`."
  end

  def ping_pong(m)
    m.reply "#{m.user.nick}: pong"
  end

  def give_bot_info(m, cmd, args)
    text = case cmd
      when "uptime"   then %x{uptime}.strip
      when "uname"    then %x{uname -a}.strip
      when "help"     then "Commands are provided by plugins. " <<
                            "To send command, use `!command`. " <<
                            "To get help message, type `!help <plugin name in lowercase>` " <<
                            "Available plugins: Hello, TinyUrl, Give, Bot, Sensor, Info. " <<
                            "To test the development bot, join #archlinuxvn_bot_devel. " <<
                            "To fix the bot's behavior, visit http://github.com/archlinuxvn/irclog."
      else nil
    end
    m.reply "#{m.user.nick}: #{text}" if text
  end
end
