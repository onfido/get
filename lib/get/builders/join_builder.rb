module Get
  module Builders
    class JoinBuilder < BaseBuilder
      private

      def class_args
        {
          base_table: @result_entity.symbolize,
          join_table: @key,
          store: Get.adapter.context_for_entity(@result_entity.singularize)
        }
      end

      def template_class(args)
        Class.new(::Get::Db) do
          include Get

          class << self
            attr_reader :base_table, :join_table
          end

          @base_table, @join_table, @store = args[:base_table], args[:join_table], args[:store]

          def initialize(options)
            @options = options.merge(with: self.class.join_table)
            super(query_params)
          end

          private

          def query_params
            { join: @options }
          end
        end
      end
    end
  end
end
