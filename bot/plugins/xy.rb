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
    unless _cache_expired?(:xy, "play by #{m.user.nick}", 60)
      m.reply "Don't play too much"
      return
    end

    flag = flag.strip.downcase
    flag = "bua" if flag.match(/^b.a$/)
    flag = "keo" if flag.match(/^k.o$/)
    bot_flag   = %w{bua bao keo}[rand(3)]
    user_index = %w{bua keo bao bua}.index(flag)
    bot_index  = %w{bua keo bao bua}.index(bot_flag)

    nutshell, ret = \
      if user_index
        case (user_index - bot_index).abs
          when 0,3 then Xy::_win?(0)
          when 1   then Xy::_win?(bot_index - user_index)
          when 2   then Xy::_win?(user_index - bot_index)
          else     [10, "Oops, the bot is buggy"]
        end
      else
        [-1, "Do you try to trick the bot?"]
      end

    bot_nutshell_give!(:masterbank, m.user.nick, nutshell, :allow_doubt => true)
    new_score = bot_score!(m.user.nick, 0)
    m.reply "#{m.user.nick}: #{ret}. Got #{nutshell}. Now have #{new_score} nutshell(s)"
  end

  class << self
    # Return [score, message]
    # Score > 0: Win, get a positive number of nutshells (up to 3)
    # Score < 0: Loose, get a negative number of nutshells (up to 2)
    def _win?(score)
      if score > 0
        [1 + rand(3), "You win"]
      elsif score < 0
        [-1 - rand(2), "You loose"]
      else
        [0, "Draw"]
      end
    end
  end
end
