# Purpose  : Core library for bot's plugins
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2012 2013

# First event: old val. in the past : expired, allow
# Next  event: now - old > PERM     : expired, allow
# Next  event: now - old < PERM     : not expired, not allowed
def _cache_expired?(section, key, cache_time = BOT_CACHE_TIME)
  now = Time.now
  BOT_CACHE[section]      ||= {}
  if not BOT_CACHE[section][key]
    BOT_CACHE[section][key] = now
    true
  elsif now - BOT_CACHE[section][key] > cache_time
    BOT_CACHE[section][key] = now
    true
  else
    false
  end
end

# Provide a simple command , example
# botname: tinyrul <your_url>. The bot will reply to the author
# a tiny version of your URL. HTTP and HTTPS only.
def tinyurl(url)
  url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
  url == "Error" ? nil : url
rescue OpenURI::HTTPError
  nil
end

class String
  # Convert foobar_test  to FooBar
  def camelize
    self.split("::").map{|p| p.split("_").map(&:capitalize).join}.flatten.join("::")
  end

  # Say the last words before exit
  def die(ret = 1)
    STDERR.puts ":: #{self}"
    exit ret
  end
end

def bot_rc_reload!
  rc = begin
    YAML::load_file(BOT_RC_FILE)
  rescue => e
    {}
  end
  BOT_RC.merge! rc
end

def bot_rc_save!
  begin
    File.open(BOT_RC_FILE, "w") do |f|
      f.puts(YAML.dump(BOT_RC))
    end
    "Configuration saved"
  rescue => e
    "Failed to save resource, err = #{e}"
  end
end

# Return a Symbol or a nickname
def bot_real_user(nickname)
  nickname = nickname.slice(1,nickname.size).to_sym if nickname.slice(0,1) == ":"
  nickname
end

# Return true if user is virtual (Symbol) or online
# FIXME: All symbol is a valid user
def bot_user_or_virtual_found?(nickname)
  nickname = bot_real_user(nickname)

  (nickname.is_a?(Symbol) and nickname == :masterbank) \
    or (nickname.is_a?(String) \
        and @bot.user_list.find(nickname) \
        and true) \
    or false
end

# Add/remove nutshells from a user
# FIXME: This is easily to cheat
def bot_score!(nickname, relative_score)
  nickname = bot_real_user(nickname)

  # This is to avoid some aliases of user.
  # FIXME: need a better way to track user nick
  nick = nickname.is_a?(String) ? nickname.to_s.gsub(/_+$/, '') : nickname

  return "Bad nickname #{nick.to_s}" if nick.to_s.empty?

  BOT_RC[:score] = {} unless BOT_RC[:score]

  # Query only available user
  if bot_user_or_virtual_found?(nickname)
    BOT_RC[:score][nick] ||= BOT_NUTSHELL
  end

  if BOT_RC[:score][nick]
    BOT_RC[:score][nick] = BOT_RC[:score][nick].to_i + relative_score
    BOT_RC[:score][nick]
  else
    0
  end
end

def bot_user_similar?(from,to)
  from.to_s.gsub(/_+$/, '') == to.to_s.gsub(/_+$/, '')
end

# Amount should be positive!
def bot_nutshell_give!(from, someone, amount = 0, params = {})
  from = bot_real_user(from)
  someone = bot_real_user(someone)

  return bot_nutshell_give!(someone, from, amount.abs, params) if amount < 0

  allow_offline = params[:allow_offline] || false
  allow_doubt   = params[:allow_doubt] || false
  reason = params[:reason].to_s
  reason = ", reason: #{reason}" unless reason.empty?

  if %w{me /me}.include?(someone) or bot_user_similar?(someone,from)
    "#{from}: Give s***t to yourself!"
  else
    if allow_offline or (bot_user_or_virtual_found?(someone) and bot_user_or_virtual_found?(from))
      if (not allow_doubt) and (amount > bot_score!(from, 0).to_i)
        "#{from}: Don't have enough nutshell to give"
      else
        theirs = bot_score!(someone, amount)
        if theirs.is_a?(String) # For any kind of errors!
          "#{from}: Error happened = #{theirs}"
        else
          yours = bot_score!(from, - amount)
          BOT_LOGGER.write "#{Time.now}: Transfer #{amount} ns from '#{from}' to '#{someone}'#{reason}}\n"
          if someone == :masterbank
            "#{from}: You've transferred #{amount} nutshell(s) to masterbank"
          else
            "#{someone}: You got #{amount} nutshell(s) from #{from}"
          end
        end
      end
    else
      "#{from}: User '#{someone}' or '#{from}' not found or offline"
    end
  end
end
