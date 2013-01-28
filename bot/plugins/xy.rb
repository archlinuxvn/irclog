# Purpose  : A simple game
# Author   : ArchLinuxvn
# Developer: icy
# License  : Fair license
# Date     : 2012 July 19th

class Xy
  include Cinch::Plugin

  set :help => "Play XY-game with the bot. To start the game, type `!xy <flag>`, where `<flag>` is `bao`, `keo`, `bua`. The bot will randomly choose its flag and find the winner. The rule is very simple: `bua > keo > bao > bua`."

  match /xy (.+)/,  :method => :xy_play

  def xy_play(m, flag)
    flag = flag.strip.downcase
    flag = "bua" if flag.match(/^b.a$/)
    flag = "keo" if flag.match(/^k.o$/)
    bot_flag   = %w{bua bao keo}[rand(3)]
    user_index = %w{bua keo bao bua}.index(flag)
    bot_index  = %w{bua keo bao bua}.index(bot_flag)
    if user_index
      distance = (user_index - bot_index).abs
      ret = case distance
        when 0,3 then "draw!"
        when 1 then user_index < bot_index ? "You win" : "You loose ('#{bot_flag}')"
        when 2 then user_index > bot_index ? "You win" : "You loose ('#{bot_flag}')"
        else  "Oops, the bot is buggy. You win!"
      end
    else
      ret = "Do you try to trick the bot?"
    end
    m.reply "#{m.user.nick}: #{ret}"
  end
end
