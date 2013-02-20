# Global variable
# FIXME: flush the CACHE after sometime. Otherwise, the system would run
# FIXME: out of the memory :) Check with garbage collection.
# FIXME: This is not good way to place global variables
BOT_NAME       = "archl0n0xvn"
BOT_CACHE      = {}
BOT_CACHE_TIME = 600 # 600 seconds aka 10 minutes
BOT_RC         = {}
BOT_RC_FILE    = File.join(ENV["HOME"], "etc/archlinuxvn.yaml")
BOT_NUTSHELL   = 100 # Default number of nutshells of all people

# First event: old val. in the past : expired, allow
# Next  event: now - old > PERM     : expired, allow
# Next  event: now - old < PERM     : not expired, not allowed
def _cache_expired?(section, key)
  now = Time.now
  BOT_CACHE[section]      ||= {}
  if not BOT_CACHE[section][key]
    BOT_CACHE[section][key] = now
    true
  elsif now - BOT_CACHE[section][key] > BOT_CACHE_TIME
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
  BOT_RC = begin
    YAML::load_file(BOT_RC_FILE)
  rescue; nil
  end
end

def bot_rc_save!
  begin
    File.open(BOT_RC_FILE, "w") do |f|
      f.puts(YAML.dump(BOT_RC_FILE))
    end
    "Configuration saved"
  rescue e
    "Failed to save resource, err = #{e}"
  end
end

# Add/remove nutshells from a user
# FIXME: This is easily to cheat
def bot_score!(nickname, relative_score)
  nick = nickname.to_s.gsub(/_+$/, '')
  return "Bad nickname #{nick}" if nick.empty?

  BOT_RC[:score] = {} unless BOT_RC[:score]
  BOT_RC[:score][nick] ||= BOT_NUTSHELL
  BOT_RC[:score][nick] = BOT_RC_FILE[:score][nick].to_i + relative_score

  "Number of nutshells = #{BOT_RC[:score][nick]}"
end
