# Purpose  : Play with nutshell
# Author   : ArchLinuxVn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2013 Feb 21st sleepless night

class Nutshell
  include Cinch::Plugin

  set :help => "Play with your nutshells. Syntax: `!nutshell <someone>`, You can also use a short version `!ns <foobar>`. To find the richest guy use `!ns :max`. To check the status of the master bank, use `!ns :masterbank`. The master bank will hold nutshells used in xy-game, and will gather nutshell from bad guys who meets sensors' condition. See more with `!help sensor`."

  match /nutshell ([^ ]+)/,   :method => :query_nutshell
  match /ns ([^ ]+)/,   :method => :query_nutshell

  def query_nutshell(m, someone)
    if someone == ":max"
      ret = Nutshell::find_max
      if ret[0] == nil
        m.reply "#{m.user.nick}: Couldn't find the richest guy"
      else
        m.reply "#{m.user.nick}: The richest guy is '#{ret[0]}' (#{ret[1]} nutshells)"
      end
    else
      someone = m.user.nick if %w{me /me}.include?(someone)
      score = bot_score!(someone || m.user.nick, 0)
      m.reply "#{someone} has #{score} nutshell(s)"
    end
  end

  class << self
    def find_max
      ret = [nil, 0]
      (BOT_RC[:score] || {}).each do |user,score|
        ret = [user, score] if score > ret[1] and user != :masterbank
      end
      ret
    end
  end
end
