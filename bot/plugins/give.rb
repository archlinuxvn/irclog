# Purpose  : Provide command !give foobar
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2012, Somedays (Michael Learns To Rock)

class Give
  include Cinch::Plugin

  set :help => "Give something to someone. Syntax: `!give <someone> <something> <others>`. <something> may be `wiki`, `tinyurl`, `some`. When `<something>` is `some`, `<others>` may be `thanks`, `shit`, `hugs`, `kiss`, `help`. If you want to give some nutshell to someone, use `!give <someone> <number> nutshell|nutshells|shell [reason]`. The `reason` is optional but you should give that to help the bot to improve the audit process."

  match /give ([^ ]+) ([^ ]+)(.*)/, :method => :give_something

  def give_something(m, someone, section, args)
    args.strip!
    someone = "#{m.user.nick}" if %{me /me}.include?(someone)

    text = case section
    when "wiki" then
      wiki = args.gsub(" ", "%20")
      wiki ? "#{someone}: https://wiki.archlinux.org/index.php/Special:Search/#{wiki}" : nil
    when "tinyurl" then
      "#{someone}: tinyurl(args)"
    when "some"
      case args
        when "thanks" then "#{someone}: Thank you very much"
        when "shit"   then "#{someone}: Oh, you ... s^ck"
        when "hugs"   then "#{someone}: Oh, let me hold you tight"
        when "kiss"   then "#{someone}: Kiss you a thousand times"
        when "help"   then "#{someone}: You wanna try google instead"
        else
          m.user.nick == someone \
            ? "#{someone}: I have nothing good for you" \
            : "#{someone}: You've got some `#{args}` from #{m.user.nick}"
      end
    # Give someone some nutshell
    # For example: !give foobar 3 shells
    else
      if section.match(/^[0-9]+$/) and gs = args.match(/(nut)?shells?( .*)?$/)
        section = section.to_i.abs
        cache_name = m.user.data["host"] || "localhost"
        time_wait = section / 10
        reason = gs[2].to_s.strip
        if _cache_expired?(:give_nutshell, cache_name,
                           :cache_time => 60 * time_wait + 10,
                           :cache_counter => 4,
                           :cache_type => :COUNTER)
          bot_nutshell_give!(m.user.nick, someone, section, :reason => reason)
        else
          "#{m.user.nick}: You can't give 4 times in ($/10 minutes + 10 seconds)"
        end
      else
        "#{m.user.nick}: Unknown section = #{section}"
      end
    end

    m.reply "#{text}" if text and not text.empty?
  end
end
