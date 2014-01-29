require "yaml"
require "docker"
require "ostruct"
require "logger"
require_relative "monkey"

class DockerManage

    attr_reader :config
    @config
    @config_file

    attr_reader :logger
    @logger

    def initialize(config_file)
        @logger = ::Logger::new(STDOUT)

        @config_file = config_file
        self.load_config

        Docker.validate_version!
    end

    def load_config
        _log_with_exception "Config file not found" if !File.exists? @config_file

        File.open(@config_file) do |file|
            config_hash = YAML.load(file.read.gsub(/\{\$(.+)\$\}/) { ENV[$1.strip!] })
            @config = OpenStruct.new(config_hash)
        end

        if @config.name.nil? || @config.url.nil? || @config.containers.nil?
            _log_with_exception "Config requires a name, url and containers"
        else
            Docker.url = @config.url
        end
    end

    def valid_container_name? name
        _container_exists? name
    end

    def get name
        if name.is_a? String
            return unless _container_exists_without_exception? name
            return Docker::Container.get(name)
        elsif name.is_a? Docker::Container
            return name
        else
            _log_with_exception "Expected a container name!"
            return nil
        end
    end

    def running? name
        if container = get(name)
            return container.json["State"]["Running"]
        else
            return false
        end
    end

    def status
        @config.containers.each do |name, value|
            puts "#{name.titleize}: #{running? name ? "Running" : "Stopped"}"
        end
    end

    def build name
        dockerfile_path = @config.dockerfile_path ? @config.dockerfile_path : "."
        Docker::Image.build_from_dir("#{dockerfile_path}/#{name}", {"t" => "#{@config.name}/#{name}"})
    end

    def create name
        config = @config.containers[name]

        if config
            options = {
                "Hostname"     => "",
                "User"         => "",
                "Memory"       => 0,
                "MemorySwap"   => 0,
                "AttachStdin"  => false,
                "AttachStdout" => true,
                "AttachStderr" => true,
                "ExposedPorts" => {},
                "Tty"          => false,
                "OpenStdin"    => false,
                "StdinOnce"    => false,
                "Env"          => nil,
                "Cmd"          => nil,
                "Dns"          => nil,
                "Volumes"      => {},
                "VolumesFrom"  => "",
                "WorkingDir"   => ""
            }

            options["Image"] = "#{@config.name}/#{name}"
            options["VolumesFrom"] = config["volumes_from"] if config["volumes_from"].is_a? String
            options["Env"] = config["env"] if config["env"].is_a? Array
            options["Cmd"] = config["cmd"] if config["cmd"].is_a? Array

            if config["port_bindings"].is_a? Hash
                config["port_bindings"].keys.each{|key| options["ExposedPorts"][key] = {}}
            end

            options["name"] = name

            @logger.info(name.titleize) { "creating" }
            Docker::Container.create options
        end
    end

    def start(name, skip=false)
        container = get(name)

        if !container
            if create name && container = get(name)
                start(name, skip) and return
            end
            @logger.info(name.titleize) { "failed to create" }

        elsif container.stopped?
            unless skip
               _required_containers(name).each{|d| start(d, true)}
            end

            config = @config.containers[name]

            if config
                @logger.info(name.titleize) { "data-only container already alive" } and return if config["data-only"]

                options = {
                    "Binds" => nil,
                    "LxcConf" => [],
                    "ContainerIDFile" => "",
                    "Privileged" => false,
                    "PortBindings" => {},
                    "Links" => nil,
                    "PublishAllPorts" => false
                }

                if config["links"].is_a? Array
                    options["Links"] = config["links"].collect{|link| "#{link["name"]}:#{link["alias"]}"}
                end

                if config["port_bindings"].is_a? Hash
                    ports = config["port_bindings"].clone
                    options["PortBindings"] = ports.camelize_keys
                end

                @logger.info(name.titleize) { "starting" }
                container.start options
                @logger.info(name.titleize) { container.running? ? "running" : "failed to start" }
            end
        else
            @logger.info(name.titleize) { "already running" }
        end
    end

    def stop(name, skip=false)
        container = get(name)

        if container && container.running?
            unless skip
               _dependent_containers(name).each{|d| stop(d, true)}
            end

            @logger.info(name.titleize) { "stopping" }
            container.stop
        end
    end

    def delete name
        container = get(name)
            
        if container
            stop container, true if container.running?

            @logger.info(name.titleize) { "deleting" }
            container.delete
        end
    end

    private

    def _required_containers name
        required = []

        if name.is_a? Docker::Container
            name = name.name
        end
        
        if container_config = @config.containers[name]
            required.concat([container_config["volumes_from"]] || []).concat(container_config["link"].try(:collect){|link| link["name"]} || [])
        end
    end

    def _dependent_containers name
        dependents = []

        if name.is_a? Docker::Container
            name = name.name
        end

        @config.containers.each do |key, value|
            if key != name
                if value["volumes_from"] == name ||
                   (value["link"] && value["link"].any?{|item| item.try(:[], "name") == name})
                    dependents << key
                end
            end
        end

        return dependents
    end

    def _container_exists_without_exception? name
        if _container_exists? name
            return true
        else
            _log_with_exception("Container does not exist in config!")
            return false
        end
    end

    def _container_exists? name
        _config_containers.include?(name)
    end

    def _config_containers
        @config.containers.try(:keys) || []
    end

    def _log_with_exception(message)
        @logger.error(message) and raise message
    end

end