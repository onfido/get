module Get
  module Builders
    class << self
      def generate_class(name, method)
        Get.const_set(name, builder_for_method(method).new(name).class)
      end

      def builder_for_method(method)
        case method
        when 'By', 'All'
          QueryBuilder
        when 'From'
          AncestryBuilder
        when 'JoinedWith'
          JoinBuilder
        end
      end
    end
  end
end
