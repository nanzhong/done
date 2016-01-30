require 'time'

module Done
  class Task
    class ParseError < ArgumentError; end

    module Types
      DOING = '*'
      BLOCKED = '!'
      TODO = '-'
      DONE = '~'
    end

    module Patterns
      NAME      = /^([#{Regexp.escape(Types::DOING + Types::BLOCKED + Types::TODO + Types::DONE)}])\s*(\S.+)$/
      TIMESTAMP = /^\s*\[(.+)\]$/
      PROPERTY  = /^\s*%\s*(\w+):(.+)$/
      NOTE      = /^\s*(.+)$/
    end

    attr_accessor :id, :name
    attr_reader :type, :timestamp, :notes, :properties

    def initialize(name:, type:, timestamp: Time.now, notes: [], properties: {})
      @name = name
      @type = type
      @timestamp = timestamp || Time.now
      @notes = notes
      @properties = properties
    end

    def touch
      @timestamp = Time.now
    end

    def start
      @type = Types::DOING
      touch
    end

    def block
      @type = Types::BLOCKED
      touch
    end

    def stop
      @type = Types::TODO
      touch
    end

    def finish
      @type = Types::DONE
      touch
    end

    def ==(other)
      name == other.name &&
        type == other.type &&
        timestamp == other.timestamp &&
        properties == other.properties &&
        notes == other.notes
    end

    def <=>(other)
      return 0 if type == other.type
      return -1 if type == Types::DOING
      return 1 if type == Types::DONE

      if type == Types::BLOCKED
        return 1 if other.type == Types::DOING
        return -1
      end

      if type == Types::TODO
        return 1 if [Types::DOING, Types::BLOCKED].include? other.type
        return -1
      end
    end

    class << self
      def parse(text)
        task_data = {
          type: nil,
          name: nil,
          timestamp: nil,
          properties: {},
          notes: []
        }

        task_data = text.split("\n").each_with_object(task_data) do |line, task|
          if name = parse_name(line)
            task[:type], task[:name] = name
          elsif timestamp = parse_timestamp(line)
            task[:timestamp] = timestamp
          elsif property = parse_property(line)
            task[:properties].merge!(property)
          elsif note = parse_note(line)
            task[:notes] << note
          else
            fail ParseError, 'Could not parse task.'
          end
        end

        fail ParseError, 'Task must have a name' unless task_data[:name]
        fail ParseError, 'Task must have a type' unless task_data[:type]

        Task.new(
          name: task_data[:name],
          type: task_data[:type],
          timestamp: task_data[:timestamp],
          notes: task_data[:notes],
          properties: task_data[:properties]
        )
      end

      private

      def parse_name(line)
        matches = line.match(Patterns::NAME)
        return nil unless matches

        [matches[1].strip, matches[2].strip]
      end

      def parse_timestamp(line)
        matches = line.match(Patterns::TIMESTAMP)
        return nil unless matches

        Time.parse(matches[1].strip)
      rescue ArgumentError
        raise ParseError, 'Task does not have a valid timestamp'
      end

      def parse_property(line)
        matches = line.match(Patterns::PROPERTY)
        return nil unless matches

        { matches[1].strip => matches[2].strip }
      end

      def parse_note(line)
        matches = line.match(Patterns::NOTE)
        return nil unless matches

        matches[1].strip
      end
    end
  end
end
