require 'thor'

module Done
  module Renderers
    # TODO: refactor this once the desired output is determined. The current mess
    # that is thisrenderer exists because even I'm not sure what the final
    # format should look like yet.
    class CLI < Thor::Shell::Color
      def initialize(context, properties)
        @context = context
        @stack = context.stack
        @properties = properties
      end

      def to_s(command, target = nil)
        lines = []

        lines <<
          case command
          when :list
            render_stack
          when :show_task
            render_task_detail(@context.stack[target])
          when :show_type
          end

        lines.join("\n")
      end

      private

      def header
        time = Time.now.strftime('%r - %A, %F')
        "Hi #{@properties[:name]}! #{time}\n"
      end

      def footer
        "Done #{Done::VERSION}"
      end

      def render_task(task)
        lines = []

        task_s = "#{pad_task_id(task.id)}: #{task.name}"
        task_s += ' [...]' if task.notes.any?

        # add timestamp date
        padding_width = terminal_width - task_s.length - task.timestamp.to_s.length
        padding = ' ' * [padding_width, 1].max

        timestamp = task.timestamp.to_s

        line = set_color(task_s, color_for_task(task)) + padding + timestamp

        lines << line

        lines.join("\n")
      end

      def render_task_detail(task)
        lines = []

        lines << "ID:   #{set_color(task.id, color_for_task(task))}"
        lines << "Name: #{set_color(task.name, color_for_task(task))}"
        lines << "Type: #{set_color(name_for_type(task.type), color_for_task(task))}"

        unless task.properties.empty?
          lines << "\n#{set_color('Properties', :yellow)}"
          task.properties.each do |k, v|
            lines << "#{k}: #{v}"
          end
        end

        unless task.notes.empty?
          lines << "\n#{set_color('Notes', :yellow)}"
          task.notes.each_with_index do |note, i|
            lines << "[#{pad_note_id(i, task)}] - #{note}"
          end
        end

        lines.join("\n")
      end

      def color_for_task(task)
        case task.type
        when Done::Task::Types::DOING then :green
        when Done::Task::Types::BLOCKED then :red
        when Done::Task::Types::TODO then :blue
        else
          nil
        end
      end

      def name_for_type(type)
        case type
        when Done::Task::Types::DOING then 'Doing'
        when Done::Task::Types::BLOCKED then 'Blocked'
        when Done::Task::Types::TODO then 'Todo'
        when Done::Task::Types::DONE then 'Done'
        end
      end

      def pad_note_id(id, task)
        notes_id_max_width = (task.notes.count - 1).to_s.length
        padding = notes_id_max_width - id.to_s.length

        ' ' * padding + id.to_s
      end

      def pad_task_id(id)
        padding = max_task_id_width - id.to_s.length

        ' ' * padding + id.to_s
      end

      def max_task_id_width
        @stack.tasks.reduce(0) do |max, task|
          length = task.id.to_s.length
          length > max ? length : max
        end
      end

      def render_current_task(task)
        render_task(task).lines
      end

      def render_stack
        lines = []
        @stack.tasks.each_with_index do |task, i|
          next if task.type == Done::Task::Types::DONE

          if i == 0
            lines += render_current_task(task)
          else
            lines << render_task(task)
          end
        end

        lines.join("\n")
      end
    end
  end
end
