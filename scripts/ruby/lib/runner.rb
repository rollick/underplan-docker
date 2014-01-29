require "trollop"
require_relative "options_parser"

SUB_COMMANDS = %w(start stop create delete)
global_opts = Trollop::options do
      banner "Manage a Docker App Stack"
      opt :config, "Path to container configuration", :short => "-c", :type => :string
      stop_on SUB_COMMANDS
end

cmd = ARGV.shift
cmd_opts = case cmd
    when "start"
        Trollop::options do
            opt :name, "Start container (name) and required container", :short => "-n", :type => :string
            opt :only, "Only start container (name) - skip required containers", :short => "-o"
        end
    when "stop"
        Trollop::options do
            opt :name, "Stop container (name) and dependent containers", :short => "-n", :type => :string
            opt :only, "Only start container (name) - skip dependent containers", :short => "-o"
        end
    when "delete"
        Trollop::options do
            opt :name, "Delete container (name)", :short => "-n", :type => :string
        end
    when "create"
        Trollop::options do
            opt :name, "Create container (name)", :short => "-n", :type => :string
        end
    else
        raise Trollop::HelpNeeded
    end

options = {
      cmd: cmd,
      global_opts: global_opts,
      cmd_opts: cmd_opts
    }

OptionsParser.new(options).parse