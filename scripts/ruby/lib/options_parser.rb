require_relative "docker_manage"

class OptionsParser

    attr_accessor :options, :docker_manage, :config_path

    def initialize(options)

        if options[:cmd]
            @cmd = options[:cmd]
        else
            puts "++ No command provided" and return
        end

        @options = options
        @config_path = "#{File.dirname($0)}/../config/underplan.yaml.template"

        if _global_option?(:config)
            puts "++ Config file does not exist" and return unless File.exists?(_global_option(:config))
            @config_path = _global_option(:config)
        end

        puts "++ Initialising with config: #{@config_path}"
        @docker_manage = DockerManage.new(@config_path)

    end

    def parse

        if _cmd_option?(:name)
            name = _cmd_option(:name)
            only = _cmd_option(:only)

            if @docker_manage.valid_container_name? name
                cmd = @cmd.to_sym
                case cmd
                when :delete, :create
                    @docker_manage.send(cmd, name)
                else
                    @docker_manage.send(cmd, name, only)
                end
            else
                puts "++ Container not found with name '#{name}'"
            end
        else
            puts "++ No name specified. See --help for options"
        end

    end

    private

    def _global_option?(name)
        options[:global_opts]["#{name}_given".to_sym]
    end

    def _cmd_option?(name)
        options[:cmd_opts]["#{name}_given".to_sym]
    end

    def _global_option(name)
        options[:global_opts][name.to_sym]
    end

    def _cmd_option(name)
        options[:cmd_opts][name.to_sym]
    end

end