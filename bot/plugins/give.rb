# Purpose  : Provide command !give foobar
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michael Learns To Rock)

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
    # Give someone some nutshell
    # For example: !give foobar 3 shells
    else
      if section.match(/^[0-9]+$/) and args.match(/(nut)?shells?/)
        if %w{me /me}.include?(someone) \
            or someone.gsub(/_+$/, '') == m.user.nick.gsub(/_+$/, '')
          "#{m.user.nick}: Give s***t to yourself!"
        else
          if @bot.user_list.find(someone)
            offset_score = section.to_i
            if offset_score > bot_score!(m.user.nick, 0).to_i
              "#{m.user.nick}: You can't love more than you can say..."
            else
              theirs = bot_score!(someone, offset_score)
              if theirs.is_a?(String) # For any kind of errors!
                "#{m.user.nick}: Error happened = #{theirs}"
              else
                yours = bot_score!(m.user.nick, - offset_score)
                "#{someone}: You got #{offset_score} nutshell(s) from #{m.user.nick}"
              end
            end
          else
            "#{m.user.nick}: User '#{someone}' not found or offline"
          end
        end
      else
        "#{m.user.nick}: Unknown section = #{section}"
      end
    end

    m.reply "#{text}" if text and not text.empty?
  end
end
