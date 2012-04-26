# Purpose  : Provide basic commands
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michale Learns To Rock)

class Info
  include Cinch::Plugin

  set(:help => "Provide basic information about ArchLinuxVn. Syntax: `!info <section>`. <section> may be: `home`, `list`, `repo`, `botsrc` or empty. If you want to find helps about the bot, try `!bot help` instead.")

  match /info (.+)/,  :method => :bot_info

  def bot_info(m, section)
    text = case section
      when "home"   then "http://archlinuxvn.tuxfamily.org/"
      when "list"   then "http://groups.google.com/group/archlinuxvn"
      when "repo"   then "http://github.com/archlinuxvn/"
      when "botsrc" then "http://github.com/archlinuxvn/irclog/"
      else nil
    end
    m.reply "#{m.user.nick}: #{text}" if text
  end
end
