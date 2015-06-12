module Get
  module Configuration
    def configuration
      @configuration ||= Config.new
    end

    def reset
      @configuration = Config.new
      @adapter, @adapter_map = nil, nil # Class-level cache clear
    end

    def configure
      yield(configuration)
    end

    def adapter
      raise ::Get::Errors::Base.new('Adapter has not been configured') unless configuration.adapter
      @adapter ||= configuration.adapter
    end
  end

  class Config
    attr_accessor :adapter, :environment

    def adapter=(adapter)
      Horza.configure { |config| config.adapter = adapter }
      @adapter = Horza.adapter
    end

    def development_mode=(mode)
      Horza.configure { |config| config.development_mode = mode }
    end

    def namespaces=(namespaces)
      raise ::Get::Errors::Base.new('namespaces must be an array') unless namespaces.is_a? Array
      Horza.configure { |config| config.namespaces = namespaces }
    end
  end
end
