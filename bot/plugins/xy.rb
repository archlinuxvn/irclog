# Purpose  : A simple game
# Author   : ArchLinuxvn
# Developer: icy
# License  : GPLv2
# Date     : 2012 July 19th

class Xy
  include Cinch::Plugin

  set :help => "Play XY-game with the bot. To start the game, type `!xy <flag> [<bet>]`, where `<flag>` is `bao`, `keo`, `bua`. The bot will randomly choose its flag and find the winner. The rule is very simple: `bua > keo > bao > bua`. The winner will get/lost a random number of nutshells (5, 10 or 15). You can also give a bet number, for example `!xy bua 50`. The bet number should not excess 100 or your currrent number of nutshells."

  match /xy ([^[:space:]]+)([[:space:]]+[0-9]+)?\b/,  :method => :xy_play

  def xy_play(m, flag, mscore)
    # return unless _cache_expired?(:xy, "#{m.user.nick}", :cache_time => 30)

    flag = flag.strip.downcase
    flag = "bua" if flag.match(/^b.a$/)
    flag = "keo" if flag.match(/^k.o$/)
    flag = "bao" if flag.match(/^b.o$/)

    if mscore
      mscore = mscore.strip.to_i.abs
      if mscore > 100 or mscore > bot_score!(m.user.nick,0)
        m.reply "#{m.user.nick}: You can't bet more than 100 or more than you have."
        return
      end
    end

    bot_flag   = %w{bua bao keo}[rand(3)]
    user_index = %w{bua keo bao bua}.index(flag)
    bot_index  = %w{bua keo bao bua}.index(bot_flag)

    nutshell, ret = \
      if user_index
        case (user_index - bot_index).abs
          when 0,3 then Xy::_win?(0)
          when 1   then Xy::_win?(bot_index - user_index, mscore)
          when 2   then Xy::_win?(user_index - bot_index, mscore)
          else     [10, "Oops, the bot is buggy"]
        end
      else
        [-1, "Wanna a trick?"]
      end

    bot_nutshell_give!(:masterbank, m.user.nick, nutshell, :allow_doubt => true, :reason => "xy_play")
    m.reply "#{m.user.nick}: #{ret}. Got #{nutshell}. Now have #{bot_score!(m.user.nick, 0)} nutshell(s)"
  end

  class << self
    # Return [score, message]
    # Score > 0: Win, get a positive number of nutshells (up to 3)
    # Score < 0: Loose, get a negative number of nutshells (up to 2)
    # Mscore: nil or the amount that user bet
    def _win?(score, mscore = nil)
      mscore = 5 * (1+rand(3)) if not mscore or mscore == 0
      if score > 0
        [mscore, "You win"]
      elsif score < 0
        [- mscore, "You loose"]
      else
        [0, "Draw"]
      end
    end
  end
end
