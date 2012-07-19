# Purpose  : Say another hello to follow a previous Hello message.
#            If A says Hi to B, the bot also says Hi to B (unless B
#            is the bot itself)
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michael Learns To Rock)


class Hello
  include Cinch::Plugin

  listen_to :message

  set(:help => "Say `hello` as someone says hello to someone else.")

  def listen(m)
    text = nil
    if gs = m.message.match(/^hello[\t ,]*([^\t ]+)/i)
      text = gs[1]
    elsif gs = m.message.match(/^([^ ]: hello)/i)
      text = gs[1]
    end

    return unless text

    if text.match(BOT_NAME)
      m.reply "Hello, #{m.user.nick}" if _cache_expired?(:hello, m.user.nick)
    else
      m.reply "Hello, #{text}" if _cache_expired?(:hello, text)
    end
  end
end
