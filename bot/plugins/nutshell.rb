# Purpose  : Play with nutshell
# Author   : ArchLinuxVn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2013 Feb 21st sleepless night

class Nutshell
  include Cinch::Plugin

  set :help => "Play with your nutshells. Syntax: `!nutshell guy [guy]...`, You can also use a short version `!ns <foobar>`. To find the richest guy use `!ns :max`. To check the status of the master bank, use `!ns :masterbank`. The master bank will hold nutshells used in xy-game, and will gather nutshell from bad guys who meets sensors' condition. See more with `!help sensor`."

  match /nutshell ([^ ]+)/,   :method => :query_nutshell
  match /ns (.+)/,   :method => :query_nutshell

  def query_nutshell(m, guys)
    ret = []
    guys.split.each do |guy|
      if guy == ":max"
        max_ret = Nutshell::find_max
        if max_ret[0] == nil
          ret << ":max -> nil"
        else
          ret << ":max -> #{max_ret[0]} @ #{max_ret[1]} ns"
        end
      else
        guy = m.user.nick if %w{me /me}.include?(guy)
        score = bot_score!(guy || m.user.nick, 0)
        ret << "#{guy} @ #{score} ns"
      end
    end
    m.reply "#{m.user.nick}: #{ret.join(", ")}" unless ret.empty?
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
