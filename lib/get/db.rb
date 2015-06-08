module Get
  class Db
    class << self
      attr_accessor :entity, :query_key, :collection, :store
    end

    def initialize(actions)
      @actions = actions
      @adapter = Get.adapter.new(self.class.store)
    end

    def call
      execute_queries
    rescue Horza::Errors::InvalidAncestry
      raise Get::Errors::InvalidAncestry
    end

    private

    def execute_queries
      res = nil
      @actions.each do |action, options|
        res = @adapter.send(action, options)
      end
      res
    end
  end
end
