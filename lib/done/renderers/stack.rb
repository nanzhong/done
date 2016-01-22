module Done
  module Renderers
    class Stack
      def initialize(stack)
        @stack = stack
      end

      def to_s
        @stack.tasks.map do |task|
          Task.new(task).to_s
        end.join("\n")
      end
    end
  end
end
