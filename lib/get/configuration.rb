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
      @adapter ||= adapter_map[configuration.adapter]
    end

    def entity_for(model)
      configuration.entity_for(model)
    end

    def adapter_map
      @adapter_map ||= ::Get::Adapters::AbstractAdapter.descendants.reduce({}) { |hash, (klass)| hash.merge(klass.name.split('::').last.underscore.to_sym => klass) }
    end
  end

  class Config
    attr_accessor :adapter

    def initialize
      @registered_entities = {}
    end

    def entity_for(model)
      @registered_entities[model]
    end

    def register_entity(model, klass)
      @registered_entities[model] = klass
    end
  end
end
