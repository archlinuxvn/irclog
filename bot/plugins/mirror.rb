# Purpose  : Get our mirror status (f.archlinuxvn.org)
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2014 Aug 09th

# NOTE: This is a very buggy and messy plugin. It should be rewritten.

require 'json'
require 'time'

class Mirror
  include Cinch::Plugin

  set :help => "Get mirror statuses. Available command: status, config. Actual data come from http://icy.theslinux.org/wohstatus/."

  listen_to :message
  match /mirror (.+)/, :method => :mirror_status
  match /mirror$/, :method => :mirror_default

  def initialize(*args)
    super
    @curl_data = {"f" => {},"fpt" => 0}
  end

  def listen(m)
    mirror_cron(m)
    mirror_monitor(m)
  end

  def mirror_default(m)
    mirror_status(m, "status")
  end

  def mirror_monitor(m, cache_time = 900)
    if _cache_expired?(:mirror, "monitor", :cache_time => 900)
      if @curl_data["error_code"].to_i > 200
        m.reply "WARNING: The bot failed to fetch wohstatus. Please help to inform our sysadmins."
      end
    end
  end

  # Update data every 900 seconds aka 15 minutes
  def mirror_cron(m)
    if not _cache_expired?(:mirror, "cron", :cache_time => 900)
      return @curl_data
    end

    url = "http://icy.theslinux.org/wohstatus/api/status.yaml"
    api_data = %x[curl -s --connect-timeout 3 -A "archlinuxvn/bot/#{BOT_NAME}" #{url}].strip

    begin
      @curl_data = YAML.load(api_data)
    rescue => e
      @curl_data = {"error_code" => 500, "error_message" => "#{e}"}
    end

    return @curl_data
  end

  def mirror_status(m, msg)
    real_user = bot_real_user(m.user.nick).to_s.gsub(/_+$/, '')

    if not _cache_expired?(:mirror, "#{real_user}.#{msg}", :cache_time => 65)
      m.reply "#{m.user.nick}: please wait some seconds..."
      return
    end

    echo = case msg.strip
      when "config" then
        "See also http://f.archlinuxvn.org/config/."
      when "status" then
        if @curl_data["error_code"].to_i > 200
          "#{m.user.nick}: The bot failed to fetch wohstatus."
        else
          @curl_data.keys.select{|key| key.match(/mirror-/)}.map do |key|
            mirror_name = key.sub(/mirror-/, '')
            status = @curl_data[key]["status"]
            message = @curl_data[key]["message"]
            if status == "up"
              "#{mirror_name} (up)"
            else
              "#{mirror_name} (#{status})"
            end
          end.join("; ")
        end
    end

    m.reply "#{m.user.nick}: #{echo}"
  end
end
