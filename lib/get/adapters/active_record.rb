module Get
  module Adapters
    class ActiveRecord < AbstractAdapter
      class << self
        def expected_errors
          [::ActiveRecord::RecordNotFound]
        end

        def context_for_entity(entity)
          entity_context_map[entity]
        end

        def entity_context_map
          @map ||= ::ActiveRecord::Base.descendants.reduce({}) { |hash, (klass)| hash.merge(klass.name.split('::').last.underscore.to_sym => klass) }
        end
      end

      def get!(options = {})
        @context = @context.find(options[:id])
      end

      def find_first(options = {})
        @context = find_all(options).limit(1).first!
      end

      def find_all(options = {})
        @context = @context.where(options[:conditions]).order('ID DESC')
      end

      def ancestors(options = {})
        get!(options)
        walk_family_tree(options)
        rescue NoMethodError
          raise ::Get::Errors::InvalidAncestry.new('Invalid relation. Ensure that the plurality of your associations is correct.')
      end

      def to_hash
        @context.attributes
      end

      private

      def walk_family_tree(options)
        options[:via].push(options[:result_key]).each { |relation| @context = @context.send(relation) }
      end
    end
  end
end
