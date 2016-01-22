module Done
  class Stack
    attr_reader :tasks

    def initialize(tasks = [])
      @tasks = tasks

      sort_tasks!
    end

    def [](index)
      @tasks[index]
    end

    def tasks_of_type(type)
      @tasks.select { |task| task.type == type }
    end

    private

    def sort_tasks!
      @tasks = [
        Task::Types::DOING,
        Task::Types::BLOCKED,
        Task::Types::TODO,
        Task::Types::DONE
      ].map do |type|
        tasks_of_type(type)
      end.flatten
    end

    class << self
      def parse(text)
        task = nil
        tasks_lines = text.lines.each_with_object([]) do |line, tasks|
          line.strip!

          next if line.empty?

          if new_task_start?(line)
            tasks << task if task
            task = [line]
          else
            task << line
          end
        end
        tasks_lines << task if task

        tasks = tasks_lines.map do |task_lines|
          Task.parse(task_lines.join("\n"))
        end

        Stack.new(tasks)
      end

      private

      def new_task_start?(line)
        [
          Task::Types::DOING,
          Task::Types::BLOCKED,
          Task::Types::TODO,
          Task::Types::DONE
        ].include?(line[0])
      end
    end
  end
end
