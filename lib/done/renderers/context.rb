module Done
  module Renderers
    class Context
      def initialize(context)
        @context = context
      end

      def to_s
        lines = []
        lines << "# Done #{Done::VERSION} [#{@context.timestamp}]"
        @context.properties.each do |k, v|
          lines << "# % #{k}: #{v}"
        end
        lines << "\n"

        lines.join("\n") + Stack.new(@context.stack).to_s
      end
    end
  end
end
