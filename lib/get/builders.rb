module Get
  module Builders
    class << self
      def generate_class(name)
        method = name.to_s.match(GET_CLASS_REGEX)[2]
        Get.const_set(name, builder_for_method(method).new(name).class)
      end

      def builder_for_method(method)
        case method
        when 'By'
          QueryBuilder
        when 'From'
          AncestryBuilder
        end
      end
    end
  end
end
