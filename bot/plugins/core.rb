# Purpose  : A fake plugin to reload core configuration
# Author   : ArchLinuxvn
# Developer: Anh K. Huynh
# License  : GPLv2
# Date     : 2013 feb 22nd

core_path = File.join(File.dirname(__FILE__), "..", "lib", "core.rb")
load core_path

class Core
  include Cinch::Plugin
  set :help => "A fake plugin to reload core configuration. There is nothing for you in this plugin."
end
