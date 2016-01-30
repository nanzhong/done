require 'time'

module Done
  class Context
    module Patterns
      PREFIX = '#'
      TITLE = /^#{PREFIX}\s*Done\s+(\d+\.\d+.\d+)(\s+\[(.+)\])?$/
      PROPERTY = /^#{PREFIX}\s*%\s*(\w+):(.+)$/
    end

    attr_reader :stack, :version, :timestamp, :properties

    def initialize(version = Done::VERSION, stack = Done::Stack.new, timestamp: Time.now, properties: {})
      @stack = stack
      @version = version
      @timestamp = timestamp || Time.now
      @properties = properties
    end

    class << self
      def parse(text)
        version = nil
        timestamp = nil
        properties = {}

        lines = text.lines.group_by do |line|
          case line
          when Patterns::TITLE
            matches = line.match(Patterns::TITLE)
            version = matches[1].strip
            timestamp =
              if matches[2]
                begin
                  Time.parse(matches[2].strip)
                rescue ArgumentError
                  nil
                end
              else
                Time.now
              end

            :title
          when Patterns::PROPERTY
            matches = line.match(Patterns::PROPERTY)
            properties[matches[1].strip] = matches[2].strip
            :property
          when /^\s*$/
            :blank
          else
            :body
          end
        end

        stack = Done::Stack.parse((lines[:body] || []).join("\n"))

        Context.new(version, stack, timestamp: timestamp, properties: properties)
      end
    end
  end
end
