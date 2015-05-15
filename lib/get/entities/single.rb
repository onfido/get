require 'hashie'

module Get
  module Entities
    class Single < Hash
      include Hashie::Extensions::MethodAccess

      def initialize(attributes)
        update(attributes)
      end
    end
  end
end
