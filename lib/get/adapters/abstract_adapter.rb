module Get
  module Adapters
    class AbstractAdapter
      attr_reader :context

      class << self
        def expected_errors
          not_implemented_error
        end

        def context_for_entity(entity)
          not_implemented_error
        end

        def entity_context_map
          not_implemented_error
        end

        def not_implemented_error
          raise ::Get::Errors::MethodNotImplemented, 'You must implement this method in your adapter.'
        end

        def descendants
          descendants = []
          ObjectSpace.each_object(singleton_class) do |k|
            descendants.unshift k unless k == self
          end
          descendants
        end
      end

      def initialize(context)
        @context = context
      end

      def get!(options = {})
        not_implemented_error
      end

      def find_first(options = {})
        not_implemented_error
      end

      def find_all(options = {})
        not_implemented_error
      end

      def ancestors(options = {})
        not_implemented_error
      end

      def eager_load(options = {})
        not_implemented_error
      end

      def to_hash
        not_implemented_error
      end

      private

      def not_implemented_error
        self.class.not_implemented_error
      end
    end
  end
end
