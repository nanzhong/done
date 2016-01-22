require 'spec_helper'

describe Done::Stack do
  let(:unordered_tasks) do
    [
      Done::Task.new(name: 'test', type: Done::Task::Types::BLOCKED),
      Done::Task.new(name: 'test', type: Done::Task::Types::DOING),
      Done::Task.new(name: 'test', type: Done::Task::Types::TODO),
      Done::Task.new(name: 'test', type: Done::Task::Types::DONE)
    ]
  end

  let(:tasks) do
    [
      Done::Task.new(name: 'test', type: Done::Task::Types::DOING),
      Done::Task.new(name: 'test', type: Done::Task::Types::BLOCKED),
      Done::Task.new(name: 'test', type: Done::Task::Types::TODO),
      Done::Task.new(name: 'test', type: Done::Task::Types::DONE)
    ]
  end

  subject(:stack) { described_class.new(tasks) }

  describe '#initialize' do
    subject(:stack) { described_class.new(unordered_tasks) }

    it 'sets and sorts the tasks associated with the stack' do
      expect(stack[0].type).to eq Done::Task::Types::DOING
    end
  end

  describe '#[]' do
    it 'returns the nth task on the stack' do
      expect(stack[0].type).to eq Done::Task::Types::DOING
    end
  end

  describe '#tasks_of_type' do
    it 'returns the type of tasks of the given type' do
      stack.tasks_of_type(Done::Task::Types::TODO).each do |task|
        expect(task.type).to eq(Done::Task::Types::TODO)
      end
    end
  end

  describe '.parse' do
    it 'correctly parses a txt representation of a stack' do
      stack_s =
        "* doing task\n" \
        "\n" \
        "  [2014-01-01 10:10:10]\n" \
        "! blocked task\n" \
        "- todo task\n" \
        "~ done task\n"
      parsed_stack = described_class.parse(stack_s)

      expect(parsed_stack[0].type).to eq(Done::Task::Types::DOING)
      expect(parsed_stack[0].name).to eq('doing task')
      expect(parsed_stack[1].type).to eq(Done::Task::Types::BLOCKED)
      expect(parsed_stack[1].name).to eq('blocked task')
      expect(parsed_stack[2].type).to eq(Done::Task::Types::TODO)
      expect(parsed_stack[2].name).to eq('todo task')
      expect(parsed_stack[3].type).to eq(Done::Task::Types::DONE)
      expect(parsed_stack[3].name).to eq('done task')
    end
  end
end
