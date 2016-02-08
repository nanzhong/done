module Done
  class Stack
    def initialize(tasks = [])
      @tasks = tasks

      process_tasks
    end

    def tasks
      @tasks.each
    end

    def current_task
      tasks_of_type(Done::Task::Types::DOING).first
    end

    def [](index)
      @tasks[index]
    end

    def tasks_of_type(type)
      @tasks.select { |task| task.type == type }
    end

    def tasks_by_type
      @tasks.group_by { |task| task.type }
    end

    def add_task(name, properties = {}, notes = [])
      task = Done::Task.new(
        name: name,
        type: Done::Task::Types::TODO,
        properties: properties,
        notes: notes
      )

      @tasks.insert(index_of_first_done, task)

      process_tasks

      task
    end

    def start_task(id)
      task = self[id]
      task.start

      process_tasks

      task
    end

    def block_task(id)
      task = self[id]
      task.block

      process_tasks

      task
    end

    def stop_task(id)
      task = self[id]
      task.stop

      process_tasks

      task
    end

    def finish_task(id)
      task = self[id]
      task.finish

      process_tasks

      task
    end

    private

    def index_of_first_done
      @tasks.find_index do |task|
        task.type == Done::Task::Types::DONE
      end || -1
    end

    def process_tasks
      sort_tasks!
      assign_task_ids
    end

    def sort_tasks!
      @tasks.sort!
    end

    def assign_task_ids
      @tasks.each_with_index do |task, i|
        task.id = i
      end
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
