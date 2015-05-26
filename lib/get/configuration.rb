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
    attr_accessor :adapter

    def set_adapter(adapter)
      Horza.configure { |config| config.adapter = adapter }
      @adapter = Horza.adapter
    end
  end
end
