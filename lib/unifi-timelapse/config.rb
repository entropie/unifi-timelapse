module UTL

  class Config
    DEFAULT_CONFIG_FILE = File.expand_path("~/.utl.yaml")

    attr_reader :config_file, :config

    def initialize
      read_config
    end

    def config_file
      config_file = DEFAULT_CONFIG_FILE
    end

    def config
      (@config ||= {})
      @config
    end

    def merge_normalized(config_hash)
      result = {}
      config_hash.each_pair do |v, k|
        if v == :workdir
          k = File.expand_path(k)
        end
        result[v.to_sym] = k
      end
      config.merge!(result)
    end

    def read_config
      merge_normalized(YAML::load_file(config_file));

      Arguments.new(config)
    end


    def method_missing(k, *rest)
      ret = config[k.to_sym]
      super unless ret
      ret
    end
    
  end

end
