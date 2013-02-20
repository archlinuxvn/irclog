# Purpose  : Play with nutshell
# Author   : ArchLinuxVn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2013 Feb 21st sleepless night


class Nutshell
  include Cinch::Plugin

  set :help => "Play with your nutshells. Syntax: !nutshell <someone>"

  match /nutshell ([^ ]+)/,   :method => :query_nutshell
  #match /nutshell/,              :method => :query_nutshell

  def query_nutshell(m, someone )
    someone = m.user.nick if %w{me /me}.include?(someone)
    score = bot_score!(someone || m.user.nick, 0)
    m.reply "#{someone} has #{score} nutshell(s)"
  end
end
