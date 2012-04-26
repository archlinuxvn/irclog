# Purpose  : Provide command !give foobar
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michale Learns To Rock)

class Give
  include Cinch::Plugin

  set :help => "Give something to someone. Syntax: `!give <someone> <section> <arguments>`. <section> may be `wiki`, `tinyurl`, `some`. For <some>, there are some predefined messages: `thanks`, `shit`, `hugs`, `kiss`, `helps`."

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
        when "thanks" then "thank you very much"
        when "shit"   then "oh, you ... s^ck"
        when "hugs"   then "oh, let me hold you tight"
        when "kiss"   then "kiss you a thousand times"
        when "helps"  then "you wanna try google instead"
        else
          if m.user.nick == someone
            "sorry #{someone}. I have nothing good for you"
          else
            "you've got some #{args} from #{m.user.nick}"
          end
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
