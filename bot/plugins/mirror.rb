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

    if not _cache_expired?(:mirror, "#{real_user}.#{msg}", :cache_time => 65)
      m.reply "#{m.user.nick}: please wait some seconds..."
      return
    end

    json_data = %x[curl -s #{url}]
    begin
      status = JSON.parse(json_data)
    rescue => e
      m.reply "#{m.user.nick}: unable to fetch status from f.archlinuxvn.org"
      return
    end

    echo = case msg.strip
      when "config" then status["mirror_config"]
      when "status" then
        sprintf("updated %s; packages: %d (64), %d (32), %d (any); size: %s", \
          status["report_time"], status["number_of_packages_x86_64"],
          status["number_of_packages_i686"], status["number_of_packages_any"],
          status["number_of_packages_x86_64"])
    end

    m.reply "#{m.user.nick}: #{echo}"
  end
end
