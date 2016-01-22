module Done
  module Renderers
    class Task
      DEFAULT_INDENTATION = '  '

      def initialize(task)
        @task = task
      end

      def to_s
        lines = []
        lines << "#{@task.type} #{@task.name}"
        lines << DEFAULT_INDENTATION + "[#{@task.timestamp}]"
        @task.properties.each do |k, v|
          lines << DEFAULT_INDENTATION + "% #{k}: #{v}"
        end
        @task.notes.each do |note|
          lines << DEFAULT_INDENTATION + note.to_s
        end

        lines.join("\n") + "\n"
      end
    end
  end
end
