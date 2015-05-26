module Get
  class Parser
    CLASS_REGEX = /^(.*)(By|From)(.*)/
    attr_accessor :class_name, :result_entity, :method

    def initialize(class_name)
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
