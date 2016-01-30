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

    it 'assigns ids to each task' do
      stack.tasks.each_with_index do |task, i|
        expect(task.id).to eq(i)
      end
    end
  end

  describe '#current_task' do
    it 'returns nil if there are no DOING Tasks' do
      stack = described_class.new([Done::Task.new(name: 'test', type: Done::Task::Types::TODO)])

      expect(stack.current_task).to eq(nil)
    end

    it 'returns the first DOING Tasks' do
      doing_task = Done::Task.new(name: 'test', type: Done::Task::Types::DOING)
      stack = described_class.new([doing_task])

      expect(stack.current_task).to eq(doing_task)
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

  describe '#add_task' do
    it 'adds a task to the stack fo tasks' do
      expect {
        stack.add_task('new task')
      }.to change { stack.tasks.size }.by(1)
    end

    it 'adds the task right before the first done task' do
      stack.add_task('new task')

      expect(stack[3].name).to eq('new task')
    end

    it 'returns the added task' do
      task = stack.add_task('new task')

      expect(task.name).to eq('new task')
    end

    it 'support setting the name, properties, and notes of the task' do
      stack.add_task('new task', { 'key' => 'value' }, ['note 1'])

      expect(stack[3].name).to eq('new task')
      expect(stack[3].properties).to eq('key' => 'value')
      expect(stack[3].notes).to eq(['note 1'])
    end

    it 'updates ids for tasks that need updating' do
      stack.add_task('new task')

      expect(stack[3].name).to eq('new task')
      expect(stack[3].id).to eq(3)
      expect(stack[4].id).to eq(4)
    end

    context 'no done tasks' do
      let(:tasks) do
        [
          Done::Task.new(name: 'test', type: Done::Task::Types::DOING),
          Done::Task.new(name: 'test', type: Done::Task::Types::BLOCKED),
          Done::Task.new(name: 'test', type: Done::Task::Types::TODO)
        ]
      end

      it 'adds the task at the end if there are no done tasks' do
        stack.add_task('new task')

        expect(stack[3].name).to eq('new task')
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
