module Get
  class Db
    class << self
      attr_accessor :entity, :query_key, :collection, :store

      def entity_factory
        @factory ||= EntityFactory.new(entity, name, collection, query_key)
      end
    end

    def initialize(actions)
      @actions = actions
      @query = Get.adapter.new(self.class.store)
    end

    def call
      execute_queries
      self.class.entity_factory.build(@query)
    rescue Horza::Errors::InvalidAncestry
      raise Get::Errors::InvalidAncestry
    end

    private

    def execute_queries
      @actions.each do |action, options|
        @query.send(action, options)
      end
    end
  end
end
