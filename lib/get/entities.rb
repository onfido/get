module Get
  module Entities
    CLASS_PREFIX = 'Get'

    class << self
      def const_missing(name)
        return super(name) unless name.to_s.match(/^#{CLASS_PREFIX}/)

        parent_klass = name.to_s.plural? ? Get::Entities::Collection : Get::Entities::Single
        Get::Entities.const_set(name, Class.new(parent_klass))
      end
    end
  end
end
