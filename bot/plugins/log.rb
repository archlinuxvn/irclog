# Purpose  : Log all activities
# Author   : ArchLinuxVn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2012 July 15th

class Log
  include Cinch::Plugin

  set :help => "Write all messages to log file"
  listen_to :message

  def listen(m)
    BOT_LOGGER.puts m
  end
end
