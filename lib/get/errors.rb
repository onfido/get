module Get
  module Errors
    class Base < StandardError
    end

    class MethodNotImplemented < StandardError
    end

    class InvalidAncestry < StandardError
    end

    class RecordNotFound < StandardError
    end
  end
end
