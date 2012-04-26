# Purpose  : Track user's activities
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michale Learns To Rock)

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
