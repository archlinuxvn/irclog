# Purpose  : Provide basic bot information
# Author   : ArchLinuxVn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michael Learns To Rock)

require 'yaml'
require 'digest/sha1'

class Bot
  include Cinch::Plugin

  set :help => "Query bot information. Syntax: `!bot <cmd>`, where `<cmd>` is `uptime`, `uname` or `plugin`. To list all available plugins, try `!bot plugin list`. To reload a plugin, try `!bot plugin reload <plugin_name>`. To test connection between you and the bot , use `!ping`. To test the bot, please send private message to bot. To fix the bot's behavior, check its source code at http://github.com/archlinuxvn/irclog."

  match /bot ([^ ]+)(.*)/,    :method => :give_bot_info
  match /ping/,               :method => :ping_pong
  match /help$/,              :method => :help_user

  def help_user(m)
    m.reply "#{m.user.nick}: try `/help` or `!help <plugin_name>`. To list all plugins, try `!bot plugin list`."
  end

  def ping_pong(m)
    m.reply "#{m.user.nick}: pong"
  end

  def give_bot_info(m, cmd, args)
    args.strip!
    text = case cmd
      when "uptime"   then %x{uptime}.strip
      when "uname"    then %x{uname -a}.strip
      when "plugin"   then
        case args
          when "list" then
            Bot::_list_plugins(@bot).join(", ") \
              + " (to get help, use lowercase as in `!help tinyurl`. To `reload`, use non-camelized form as in `!bot plugin reload tiny_url`)"
          else
            if gs = args.match(/^reload ([^ ]+)/)
              p_name = gs[1].strip
              Bot::_reload_plugin(@bot, p_name) if _cache_expired?(:bot_plugin, "reload #{p_name}")
            elsif gs =  args.match(/^pull (.*)/)
              secret_key = gs[1].strip
              Bot::_src_update(secret_key)  if _cache_expired?(:bot_plugin, "src_update")
            else
              nil
            end
        end
      else nil
    end
    m.reply "#{m.user.nick}: #{text}" if text
  end

  class << self
    # WARNING: Update the source tree in remote!!!
    def _src_update(key)
      rc = begin
        YAML::load_file(File.join(ENV["HOME"], "etc/archlinuxvn.yaml"))
      rescue; nil
      end
      if rc and rc[:irclog] and rc[:irclog][:pull] and rc[:irclog][:pull][:key]
        if Digest::SHA1.hexdigest(key) == rc[:irclog][:pull][:key]
          %x{git pull origin master}.strip
        else
          "Invalid key"
        end
      else
        "Resource file not found"
      end
    end

    # List all available plugins
    def _list_plugins(bot)
      bot.config.plugins.plugins.map(&:to_s)
    end

    # Purpose: Reload a plugin. Load new plugin if it has never been loaded
    # Author : Anh K. Huynh
    # Date   : 2012 July 15th
    def _reload_plugin(bot, args)
      plugin_name = args.downcase
      return "Plugin name must be specified" if plugin_name.empty? or not plugin_name.match(/^[0-9a-z_]+$/)
      return "Plugin is in the black list" if BOT_PLUGINS_BLACKLIST.include?(plugin_name)

      plugin_path = File.join(File.dirname(__FILE__), "#{plugin_name}.rb")
      return "Plugin file not found #{plugin_path}" unless File.file?(plugin_path)

      # Un-register the plugin if it is loaded
      plugin_class = begin
        Object.const_get(plugin_name.camelize)
      rescue
        nil
      end

      ObjectSpace.each_object(plugin_class).map(&:unregister) if plugin_class

      # Now load the plugin again
      begin
        load plugin_path
        plugin_class = begin
          Object.const_get(plugin_name.camelize)
        rescue
          nil
        end

        if plugin_class
          bot.plugins.register_plugin(plugin_class)
          bot.config.plugins.plugins |= [plugin_class]
          return "Plugin '#{plugin_name}' reloaded"
        else
          return "Plugin '#{plugin_name}' not loaded"
        end
      rescue => e
        return "Failed to load plugin #{plugin_name} after unloading it"
      end
    end
  end
end
