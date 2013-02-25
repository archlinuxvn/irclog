# Purpose  : Send warning if user says badword(s)
# Author   : ArchLinuxvn
# Developer: icy, n0b0dyvn
# License  : GPLv2
# Date     : 2012, Somedays (Michael Learns To Rock)

class Sensor
  include Cinch::Plugin

  set :help => "Send warning if user says bad words. User will pay 1 nutshell for each warning (See `!help nutshell`.) After the warning is sent, the bot will record the event's time and it will not report again within #{BOT_CACHE_TIME} seconds. So... you are safe to say anything you want in #{BOT_CACHE_TIME} seconds without bothering the bot :D. BUG: if your nick matches the pattern '#{BOT_NAME}', the bot will simply ignore anything you say. This is a KNOWN bug, so it isn't funny if you are trying to trick the bot this way :)"

  listen_to :message

  def listen(m)
    # FIXME: some user can use the BOT_NAME to trick the bot
    return if m.user.nick.match(BOT_NAME)
    badwords = m.message.split.reject{|w| not w.match(/\b(vcl|wtf|sh[1i]t|f.ck|d[e3]k|clgt)\b/i)}
    badwords = badwords.uniq.sort

    if not badwords.empty? and _cache_expired?(:sensor, m.user.nick)
      bot_nutshell_give!(m.user.nick, :masterbank, 1, :allow_doubt => true)
      m.reply "#{m.user.nick}: Take it easy. Don't say #{badwords.join(", ")}. You've transferred 1 nutshell to masterbank."
    end
  end
end
