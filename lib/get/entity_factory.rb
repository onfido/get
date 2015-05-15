module Get
  class EntityFactory
    def initialize(entity, query_class_name, is_collection, result_key)
      @entity, @query_class_name, @is_collection, @result_key = entity, query_class_name, is_collection, result_key
    end

    def build(adapter_result)
      klass.new(db_result(adapter_result))
    end

    private

    def db_result(adapter_result)
      @is_collection ? adapter_result.context : adapter_result.to_hash
    end

    def klass
      Get.entity_for(key) || Get::Entities.const_get(dynamic_class)
    end

    def key
      @query_class_name.demodulize.symbolize
    end

    def dynamic_class
      "#{::Get::Entities::CLASS_PREFIX}#{dynamic_key.camelize}"
    end

    def dynamic_key
      return @result_key.to_s if @result_key # Special case for ancestor queries
      @is_collection ? @entity.to_s.pluralize : @entity.to_s
    end
  end
end
