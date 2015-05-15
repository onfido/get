module Get
  module CoreExtensions
    module String
      def singular?
        singularize == self
      end

      def plural?
        pluralize == self
      end

      def symbolize
        underscore.to_sym
      end
    end
  end
end
