module Get
  module RunMethods
    ALL_CLASS_REGEX = /(All)(.*)/
    def run(*context)
      options_allowed if context.present?
      new(*context).run
    end

    def run!(*context)
      options_allowed if context
      new(*context).run!
    end

    def options_allowed
      raise ::Get::Errors::OptionsNotPermitted.new("Options not supported with 'All' queries") if self.to_s.match(ALL_CLASS_REGEX)
    end
  end
end
