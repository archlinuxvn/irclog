# Purpose  : Very simple cron support
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michael Learns To Rock)


class Cron
  include Cinch::Plugin

  listen_to :message

  set(:help => "Simple cron support for channel.")

  def initialize(*args)
    super
    @counter = 0
  end

  def listen(m)
    @counter += 1

    # every 17 messages
    if @counter % 10 == 0
      ret = bot_rc_save!
      m.reply "!!! (cron) #{ret}" if ret.match(/Failed/)
    end
  end
end
