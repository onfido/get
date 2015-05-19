module Get
  module Builders
    class AncestryBuilder < BaseBuilder
      private

      def class_args
        {
          key: @key,
          collection: @result_entity.plural?,
          result_entity: @result_entity.symbolize,
          store: Get.adapter.context_for_entity(@key.to_s.singularize.symbolize)
        }
      end

      def template_class(args)
        Class.new(::Get::Db) do
          include Get

          class << self
            attr_reader :result_key
          end

          @entity, @result_key, @collection, @store = args[:key], args[:result_entity], args[:collection], args[:store]

          def initialize(model, options = {})
            @model, @options = model, options
            super(query_params)
          end

          private

          def id
            return @model.id if @model.respond_to? :id
            @model
          end

          def query_params
            options = @options.except(:via) || {}
            { ancestors: ancestor_params }.merge(options)
          end

          def ancestor_params
            {
              id: id,
              via: via,
              result_key: self.class.result_key
            }
          end

          def via
            case @options[:via]
            when Symbol
              [@options[:via]]
            when Array
              @options[:via]
            else
              []
            end
          end
        end
      end
    end
  end
end
