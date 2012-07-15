# Purpose  : Provide command !give foobar
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michale Learns To Rock)

class Give
  include Cinch::Plugin

  set :help => "Give something to someone. Syntax: `!give <someone> <something> <others>`. <something> may be `wiki`, `tinyurl`, `some`. When `<something>` is `some`, `<others>` may be `thanks`, `shit`, `hugs`, `kiss`, `help`."

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
    else
      ""
    end

    if text
      if not text.empty?
        m.reply "#{someone}: #{text}"
      else
        m.reply "#{m.user.nick}: nothing to give to #{someone}"
      end
    end
  end
end
