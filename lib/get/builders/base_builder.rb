module Get
  module Builders
    class BaseBuilder
      def initialize(class_name)
        parser = ::Get::Parser.new(class_name)
        @result_entity = parser.result_entity
        @key = parser.key
      end

      def class
        template_class(class_args)
      end

      private

      def parse_class_name(class_name)
        @result_entity, key = class_name.to_s.match(::Get::GET_CLASS_REGEX).values_at(1, 3)
        @key = key.present? ? key.symbolize : nil
      end
    end
  end
end
