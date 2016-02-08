require 'thor'
require 'erb'
require 'ostruct'

module Done
  module Renderers
    class CLI < Thor::Shell::Color
      class Binding < Thor::Shell::Color
        def self.bind(variables)
          new(variables).instance_eval { binding }
        end

        def initialize(variables)
          @variables = OpenStruct.new(variables)
        end

        def method_missing(method, *args, &block)
          @variables.send(method, *args, &block)
        end

        def respond_to_missing?(method_name, include_private = false)
          @variables.respont_to?(method_name, include_private) || super
        end

        def color_for_task(task)
          case task.type
          when Done::Task::Types::DOING then :green
          when Done::Task::Types::BLOCKED then :red
          when Done::Task::Types::TODO then :blue
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
      end

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
            render_stack(@context.stack)
          when :show_task
            render_task_detail(@context.stack[target])
          when :show_type
          end

        lines.join("\n")
      end

      private

      def path_for_template(template)
        template_file =
          case template
          when :stack       then 'stack.txt.erb'
          when :task_detail then 'task_detail.txt.erb'
          when :task        then 'task.txt.erb'
          end

        File.expand_path("../../templates/#{template_file}", __FILE__)
      end

      def erb_for(template)
        @templates ||= {}
        @templates[template] ||= ERB.new(File.read(path_for_template(template)), nil, '-')
      end

      def render_task(task)
        erb_for(:task).result(Binding.bind(task: task))
      end

      def render_task_detail(task)
        erb_for(:task_detail).result(Binding.bind(task: task))
      end

      def render_stack(stack)
        tasks_by_type = stack.tasks_by_type
        doing_tasks = (tasks_by_type[Done::Task::Types::DOING] || []).map { |task| render_task(task) }
        blocked_tasks = (tasks_by_type[Done::Task::Types::BLOCKED] || []).map { |task| render_task(task) }
        todo_tasks = (tasks_by_type[Done::Task::Types::TODO] || []).map { |task| render_task(task) }

        erb_for(:stack).result(Binding.bind(doing_tasks: doing_tasks,
                                            blocked_tasks: blocked_tasks,
                                            todo_tasks: todo_tasks))
      end
    end
  end
end
