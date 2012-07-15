# Purpose  : Provide basic bot information
# Author   : ArchLinuxVn
# Developer: Anh K. Huynh
# License  : Fair license
# Date     : 2012, Somedays (Michale Learns To Rock)

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
              + " (to use with `!help`, use lowercase as in `!help tinyurl`. To `reload`, use non-camelized form in `!bot plugin reload tiny_url`)"
          else
            if gs = args.match(/^reload ([^ ]+)/)
              p_name = gs[1].strip
              Bot::_reload_plugin(@bot, p_name) if _cache_expired?(:bot_plugin_reload, p_name)
            else
              nil
            end
        end
      else nil
    end
    m.reply "#{m.user.nick}: #{text}" if text
  end

  class << self
    # List all available plugins
    def _list_plugins(bot)
      bot.config.plugins.plugins.map(&:to_s)
    end

    # Purpose: Reload a plugin. Load new plugin if it has never been loaded
    # Author : Anh K. Huynh
    # Date   : 2012 July 15th
    def _reload_plugin(bot, args)
      plugin_name = args.downcase
      return "Plugin name must be specified" if plugin_name.empty?
      return "Plugin is in the black list" if BOT_PLUGINS_BLACKLIST.include?(plugin_name)

      plugin_path = File.join(File.dirname(__FILE__), "#{plugin_name}.rb")
      return "Plugin file not found #{plugin_path}" unless File.file?(plugin_path)

      # Un-register the plugin if it is loaded
      plugin_class = begin
        Object.const_get(plugin_name.camelize)
      rescue
        nil
      end

      # reload = bot.config.plugins.plugins.include?(plugin_class)
      ObjectSpace.each_object(plugin_class).map(&:unregister)

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
