# Purpose  : Get our mirror status (f.archlinuxvn.org)
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2014 Aug 09th

require 'json'

class Mirror
  include Cinch::Plugin

  set :help => "Get mirror status (http://f.archlinuxvn.org/). Available command: status, config"

  match /mirror (.+)/, :method => :mirror_status
  match /mirror$/, :method => :mirror_default

  def mirror_default(m)
    mirror_status(m, "status")
  end

  def mirror_status(m, msg)
    real_user = bot_real_user(m.user.nick).to_s.gsub(/_+$/, '')
    url = "http://f.archlinuxvn.org/archlinux/status.json"
    fpt = "http://mirror-fpt-telecom.fpt.net/archlinux/lastsync"

    if not _cache_expired?(:mirror, "#{real_user}.#{msg}", :cache_time => 65)
      m.reply "#{m.user.nick}: please wait some seconds..."
      return
    end

    json_data = %x[curl --connect-timeout 3 -A "bot/#{BOT_NAME}" -s #{url}]
    begin
      status = JSON.parse(json_data)
    rescue => e
      m.reply "#{m.user.nick}: unable to fetch status from f.archlinuxvn.org"
      return
    end

    fpt_lastsync_i = %x[curl --connect-timeout 3 -A "archlinuxvn/bot/#{BOT_NAME}" #{fpt}].strip.to_i
    fpt_lastsync_s = Time.at(fpt_lastsync_i).localtime("+07:00").strftime("%Y%m%d-%H%M%S")

    echo = case msg.strip
      when "config" then status["mirror_config"]
      when "status" then
        sprintf("updated %s (up %s); packages: %s (64), %s (32), %s (any); size: %s; FPT updated %s", \
          status["report_time"],
          status["number_of_updated_packages"],
          status["number_of_packages_x86_64"],
          status["number_of_packages_i686"],
          status["number_of_packages_any"],
          status["repo_total_size_in_name"],
          fpt_lastsync_s)
    end

    m.reply "#{m.user.nick}: #{echo}"
  end
end
