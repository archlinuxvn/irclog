# Purpose  : Send email to ircbot@localhost
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2014 April 17th

class Mail
  include Cinch::Plugin

  set :help => "Send an email to ircbot@localhost"

  match /mail (.+)/, :method => :send_email

  def send_email(m, msg)
    if not _cache_expired?(:bot, "send_email", :cache_time => 120)
      m.reply "#{m.user.nick}: please wait some minutes and don't spam"
      return
    end

    # FIXME: pls. make sure the user string is good
    subject = msg.gsub(/['"\\]/, '.').strip

    if subject.empty?
      m.reply "#{m.user.nick}: Subject is empty!"
      return
    end

    Thread.new do
      open("|mail -s '#{subject}' ircbot", 'w') do |io|
        io.puts "Message from user '#{m.user.nick}'"
        io.puts "Subject: #{msg}"
        io.puts "User information:\n"
        io.puts m.user.inspect
        io.puts m.user.data.inspect
      end
    end

    m.reply "#{m.user.nick}: Message (maybe) sent to the channel operator"
  end
end
