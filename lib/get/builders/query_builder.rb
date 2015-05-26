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

          def initialize(params)
            @params = params
            super(query_params)
          end

          private

          def query_params
            { query_action => conditions }
          end

          def query_action
            self.class.collection ? :find_all : :find_first!
          end

          # find_first
          def conditions
            return @params unless self.class.field
            { self.class.field => @params }
          end

          def single_params
            return {} if self.class.collection
            { limit: 1, first: true }
          end
        end
      end
    end
  end
end
