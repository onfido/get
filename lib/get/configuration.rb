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

    def entity_for(model)
      configuration.entity_for(model)
    end
  end

  class Config
    attr_accessor :adapter

    def initialize
      @registered_entities = {}
    end

    def set_adapter(adapter)
      Horza.configure { |config| config.adapter = adapter }
      @adapter = Horza.adapter
    end

    def entity_for(model)
      @registered_entities[model]
    end

    def register_entity(model, klass)
      @registered_entities[model] = klass
    end
  end
end
