# Purpose  : Provide command !give foobar
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2012, Somedays (Michael Learns To Rock)

class Give
  include Cinch::Plugin

  set :help => "Give something to someone. Syntax: `!give <someone> <something> <others>`. <something> may be `wiki`, `tinyurl`, `some`. When `<something>` is `some`, `<others>` may be `thanks`, `shit`, `hugs`, `kiss`, `help`. If you want to give some nutshell to someone, use `!give <someone> <number> nutshell|nutshells|shell`"

  match /give ([^ ]+) ([^ ]+)(.*)/, :method => :give_something

  def give_something(m, someone, section, args)
    args.strip!
    someone = "#{m.user.nick}" if %{me /me}.include?(someone)

    text = case section
    when "wiki" then
      wiki = args.gsub(" ", "%20")
      wiki ? "https://wiki.archlinux.org/index.php/Special:Search/#{wiki}" : nil
    when "tinyurl" then
      tinyurl(args)
    when "some"
      case args
        when "thanks" then "Thank you very much"
        when "shit"   then "Oh, you ... s^ck"
        when "hugs"   then "Oh, let me hold you tight"
        when "kiss"   then "Kiss you a thousand times"
        when "help"   then "You wanna try google instead"
        else
          m.user.nick == someone \
            ? "Sorry #{someone}. I have nothing good for you" \
            : "You've got some `#{args}` from #{m.user.nick}"
      end
    # Give someone some nutshell
    # For example: !give foobar 3 shells
    else
      if section.match(/^[0-9]+$/) and args.match(/(nut)?shells?/)
        section = section.to_i.abs
        cache_name = "#{m.user.data["host"]}"
        time_wait = section / 10
        if _cache_expired?(:give_nutshell, cache_name, 60 * time_wait)
          bot_nutshell_give!(m.user.nick, someone, section)
        else
          "#{m.user.nick}: You can't give nutshell too often. Need to wait (1 + $/10) minutes from the last transaction."
        end
      else
        "#{m.user.nick}: Unknown section = #{section}"
      end
    end

    m.reply "#{text}" if text and not text.empty?
  end
end
