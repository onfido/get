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
            attr_reader :target
          end

          @entity, @target, @collection, @store = args[:key], args[:result_entity], args[:collection], args[:store]

          def initialize(model, options = {})
            @model, @options = model, options
            super(query_params)
          end

          private

          def query_params
            { association: ancestor_params }
          end

          def ancestor_params
            # Add options to hash only if they exist - empty objects/nil values can wreak havoc
            [:conditions, :limit, :offset, :order].reduce(required_params) do |params, key|
              @options[key] ? params.merge(key => @options[key]) : params
            end
          end

          def required_params
            {
              id: id,
              via: via,
              target: self.class.target
            }
          end

          def id
            return @model.id if @model.respond_to? :id
            @model
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
