module Get
  module Entities
    class Collection
      def initialize(collection)
        @collection = collection
      end

      def each
        @collection.each do |result|
          yield singular_entity(result)
        end
      end

      def [](index)
        singular_entity(@collection[index])
      end

      private

      def method_missing(method)
        if [:length, :size, :empty?, :present?].include? method
          @collection.send(method)
        elsif [:first, :last].include? method
          singular_entity(@collection.send(method))
        end
      end

      def singular_entity(record)
        singular_entity_class.new(Get.adapter.new(record).to_hash)
      end

      # Collection classes have the form Get::Entities::TypesMapper
      # Single output requires the form Get::Entities::TypeMapper
      def singular_entity_class
        @singular_entity ||= Kernel.const_get('Get').const_get('Entities').const_get(self.class.name.demodulize.singularize)
      end
    end
  end
end
