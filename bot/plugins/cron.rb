# Purpose  : Very simple cron support
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2013 feb 23nd

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
    if @counter % 100 == 0
      ret = bot_rc_save!
      if @counter % 500 == 0
        m.reply "(bot.cron) #{ret}. Message count: #{@counter}"
      end
    end
  end
end
