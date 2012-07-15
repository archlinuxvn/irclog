# Global variable
# FIXME: flush the CACHE after sometime. Otherwise, the system would run
# FIXME: out of the memory :) Check with garbage collection.
BOT_NAME       = "archl0n0xvn"
BOT_CACHE      = {}
BOT_CACHE_TIME = 600 # 600 seconds aka 10 minutes

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
end
