module Get
  module Builders
    class QueryBuilder < BaseBuilder
      private

      def class_args
        {
          key: @key,
          collection: @result_entity.plural?,
          result_entity: @result_entity.singularize.symbolize,
          store: Get.adapter.context_for_entity(@result_entity.singularize.symbolize)
        }
      end

      def template_class(args)
        Class.new(::Get::Db) do
          include Get

          class << self
            attr_reader :field
          end

          @field, @entity, @collection, @store = args[:key], args[:result_entity], args[:collection], args[:store]

          def initialize(params, options = {})
            @params, @options = params, options
            super(query_params)
          end

          private

          def query_params
            { query_action => conditions.merge(@options) }
          end

          def query_action
            self.class.collection ? :find_all : :find_first!
          end

          # find_first
          def conditions
            return { conditions: @params } unless self.class.field
            { conditions: { self.class.field => @params } }
          end
        end
      end
    end
  end
end
