module Get
  class Parser
    CLASS_REGEX = /^(.*)(By|From)(.*)/
    CLASS_NAME_BY_ERROR = 'You have multiple instances of "By" in your class. Please use open-ended form ie. Get::UserBy.run(params)'
    attr_accessor :class_name, :result_entity, :method

    def initialize(class_name)
      raise Get::Errors::InvalidClassName.new(CLASS_NAME_BY_ERROR) if class_name.to_s.split('By').length > 2

      @class_name = class_name
      @match = class_name.to_s.match(CLASS_REGEX)
      @result_entity, @method, @key_string = @match.values_at(1, 2, 3) if @match
    end

    def match?
      !!@match
    end

    def key
      @key_string.present? ? @key_string.symbolize : nil
    end
  end
end
