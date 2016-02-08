require 'thor'
require 'yaml'

module Done
  class CLI < Thor
    CONFIG_FILE_PATH = File.expand_path('~/.done.yml')

    include Thor::Actions

    def self.config
      @config ||= YAML.load_file(CONFIG_FILE_PATH)
    end

    def self.context
      unless @context
        @context =
          if File.exist?(config[:done_file_path])
            Context.parse(File.read(config[:done_file_path]))
          else
            Context.new
          end
      end

      @context
    end

    def self.save
      done_str = Done::Renderers::Context.new(context).to_s
      File.open(config[:done_file_path], 'w') do |file|
        file.puts done_str
      end
    end

    def self.renderer
      Done::Renderers::CLI.new(context, { name: config[:name] })
    end

    desc 'setup', 'Setup done interactively'
    def setup
      name = nil
      loop do
        name = ask('What is your name?')
        break unless name.strip.empty?
        say("Sorry, I didn't catch that...")
      end

      default_file_path = File.expand_path('~/') + '/' + name.split(/\W/).first.downcase + '.done'
      done_file_path = ask("Where would you like done to store your information? [#{default_file_path}]")
      done_file_path = default_file_path if done_file_path.strip.empty?

      config = {
        name: name,
        done_file_path: done_file_path
      }

      create_file(CONFIG_FILE_PATH, YAML.dump(config))
    end

    desc 'list', 'List aff of your tasks'
    def list
      say CLI.renderer.to_s(:list)
    end

    desc 'show [ID | TYPE]', 'Show your tasks'
    def show(target)
      target = target.strip.downcase

      if ['doing', 'blocked', 'todo', 'done'].include? target

      else
        say CLI.renderer.to_s(:show_task, target.to_i)
      end
    end

    desc 'add NAME', 'Add a task to your stack'
    method_option :notes, type: :array, default: [], aliases: '-n'
    method_option :properties, type: :hash, default: {}, aliases: '-p'
    def add(name)
      task = CLI.context.stack.add_task(name, options[:properties], options[:notes])
      show(task.id.to_s)
    end

    desc 'start ID', 'Start working on a task'
    def start(id)
      CLI.context.stack.start_task(id.to_i)
    end

    desc 'stop ID', 'Stop working on a task'
    def stop(id)
      CLI.context.stack.stop_task(id.to_i)
    end

    desc 'finish ID', 'Finish a task'
    def finish(id)
      CLI.context.stack.finish_task(id.to_i)
    end

    desc 'block ID', 'Block a task'
    def block(id)
      CLI.context.stack.block_task(id.to_i)
    end
  end
end
