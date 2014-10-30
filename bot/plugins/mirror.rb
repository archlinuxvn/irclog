# Purpose  : Get our mirror status (f.archlinuxvn.org)
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2014 Aug 09th

require 'json'
require 'time'

class Mirror
  include Cinch::Plugin

  set :help => "Get mirror status (http://f.archlinuxvn.org/). Available command: status, config"

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

  def mirror_monitor(m, cache_time = 1800)
    if gs = @curl_data["f"]["report_time"].to_s.match(/^([0-9]{8})-([0-9]{2})([0-9]{2})([0-9]{2})/)
      date, h, min, s = gs[1], gs[2], gs[3], gs[4]
      offset = Time.now - Time.parse(sprintf("%s %s:%s:%s", date, h, min, s))
      offset = offset / 60
      offset = offset.to_i
      if offset >= 90 # 90 minutes aka 1.5 hour
        m.reply "!! Warning: Mirror is out-of-sync. The last update is #{offset} minutes ago" \
          if _cache_expired?(:mirror, "cron_warning", :cache_time => cache_time)
      end
    else
      m.reply "!! Error: Invalid curl data found" \
        if _cache_expired?(:mirror, "cron_error", :cache_time => cache_time)
    end

    offset = Time.now - Time.parse(@curl_data["f"]["the_latest_package_time"])
    offset = (offset / 3600).to_i
    if offset > 24
      m.reply "!! Warning: The last package is updated #{offset} hours ago" \
        if _cache_expired?(:mirror, "cron_warn_lastpkg", :cache_time => cache_time)
    end

    return @curl_data
  end

  # Update data every 0.5 hour
  def mirror_cron(m)
    if not _cache_expired?(:mirror, "cron", :cache_time => 1800)
      # If @curl_data is good, we just return because we're in cache window
      if not @curl_data["f"]["report_time"].to_s.empty?
        return @curl_data
      # Otherwise, we will try to update @curl_data.
      # However, we don't that too often. We will try after 10 minutes
      elsif not _cache_expired?(:mirror, "cron_retry", :cache_time => 600)
        return @curl_data
      end
    end

    url = "http://f.archlinuxvn.org/archlinux/status.json"
    fpt = "http://mirror-fpt-telecom.fpt.net/archlinux/lastsync"

    json_data = %x[curl --connect-timeout 3 -A "bot/#{BOT_NAME}" -s #{url}]
    begin
      @curl_data["f"] = JSON.parse(json_data)
    rescue => e
      @curl_data["f"] = {}
    end

    fpt_lastsync_i = %x[curl -s --connect-timeout 3 -A "archlinuxvn/bot/#{BOT_NAME}" #{fpt}].strip.to_i
    fpt_lastsync_s = Time.at(fpt_lastsync_i).localtime("+07:00").strftime("%Y%m%d-%H%M%S")
    @curl_data["fpt"] = fpt_lastsync_s

    return @curl_data
  end

  def mirror_status(m, msg)
    real_user = bot_real_user(m.user.nick).to_s.gsub(/_+$/, '')

    if not _cache_expired?(:mirror, "#{real_user}.#{msg}", :cache_time => 65)
      m.reply "#{m.user.nick}: please wait some seconds..."
      return
    end

    @curl_data = mirror_cron(m)
    offset = Time.now - Time.parse(@curl_data["f"]["the_latest_package_time"])
    offset = (offset / 60).to_i

    echo = case msg.strip
      when "config" then @curl_data["f"]["mirror_config"] || "error"
      when "status" then
        sprintf("synced @ %s (last package: %s minutes ago); size: %s; FPT synced @ %s", \
          @curl_data["f"]["report_time"],
          offset,
          @curl_data["f"]["repo_total_size_in_name"],
          @curl_data["fpt"])
    end

    m.reply "#{m.user.nick}: #{echo}"
    mirror_monitor(m, 65)
  end
end
