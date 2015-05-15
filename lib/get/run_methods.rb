module Get
  module RunMethods
    def run(*context)
      new(*context).run
    end

    def run!(*context)
      new(*context).run!
    end
  end
end
