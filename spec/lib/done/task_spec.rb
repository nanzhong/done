require 'spec_helper'

describe Done::Task do
  let(:name) { 'task name' }
  let(:type) { Done::Task::Types::DOING }
  let!(:timestamp) { Time.now }
  let(:notes) { ['a note'] }
  let(:properties) { { 'key' => 'value' } }

  let(:task_s) do
    "#{type} #{name}\n" \
    "  [#{timestamp}]\n" \
    "  % #{properties.keys.first}: #{properties.values.first}\n" \
    "  #{notes.first}"
  end

  subject(:task) do
    described_class.new(
      name: name,
      type: type,
      timestamp: timestamp,
      notes: notes,
      properties: properties
    )
  end

  describe '#initialize' do
    it 'initializes all the attributes' do
      expect(task.name).to eq(name)
      expect(task.type).to eq(type)
      expect(task.timestamp).to eq(timestamp)
      expect(task.notes).to eq(notes)
      expect(task.properties).to eq(properties)
    end

    context 'without timestamp' do
      let(:timestamp) { nil }

      it 'uses the current time' do
        expect(task.timestamp).not_to be_nil
      end
    end
  end

  describe '#touch' do
    it 'updates the timestamp of the task to the current time' do
      expect(Time).to receive(:now).and_return(Time.at(1))

      expect do
        task.touch
      end.to change { task.timestamp }.to(Time.at(1))
    end
  end

  describe '#<=>' do
    let(:doing) { Done::Task.new(name: 'task', type: Done::Task::Types::DOING) }
    let(:blocked) { Done::Task.new(name: 'task', type: Done::Task::Types::BLOCKED) }
    let(:todo) { Done::Task.new(name: 'task', type: Done::Task::Types::TODO) }
    let(:done) { Done::Task.new(name: 'task', type: Done::Task::Types::DONE) }

    it 'correctly compares against doing tasks' do
      expect(doing <=> doing).to eq(0)
      expect(blocked <=> doing).to eq(1)
      expect(todo <=> doing).to eq(1)
      expect(done <=> doing).to eq(1)
    end

    it 'correctly compares against blocked tasks' do
      expect(doing <=> blocked).to eq(-1)
      expect(blocked <=> blocked).to eq(0)
      expect(todo <=> blocked).to eq(1)
      expect(done <=> blocked).to eq(1)
    end

    it 'correctly compares against todo tasks' do
      expect(doing <=> todo).to eq(-1)
      expect(blocked <=> todo).to eq(-1)
      expect(todo <=> todo).to eq(0)
      expect(done <=> todo).to eq(1)
    end

    it 'correctly compares against done tasks' do
      expect(doing <=> done).to eq(-1)
      expect(blocked <=> done).to eq(-1)
      expect(todo <=> done).to eq(-1)
      expect(done <=> done).to eq(0)
    end
  end

  describe '.parse' do
    it 'correctly parses a task' do
      parsed_task = described_class.parse(task_s)

      expect(parsed_task.name).to eq(task.name)
      expect(parsed_task.type).to eq(task.type)
      expect(parsed_task.timestamp.to_i).to eq(task.timestamp.to_i)
      expect(parsed_task.properties).to eq(task.properties)
      expect(parsed_task.notes).to eq(task.notes)
    end

    [
      Done::Task::Types::DOING,
      Done::Task::Types::BLOCKED,
      Done::Task::Types::TODO,
      Done::Task::Types::DONE
    ].each do |type|
      context "with #{type} type" do
        it 'correctly parses the type' do
          task_s[0] = type

          expect(described_class.parse(task_s).type).to eq(type)
        end
      end
    end

    context 'with invalid task format' do
      it 'throws a ParseError' do
        expect do
          described_class.parse('invalid')
        end.to raise_error(Done::Task::ParseError)
      end
    end

    context 'with missing name' do
      let(:name) { '' }

      it 'throws a ParseError' do
        expect do
          described_class.parse(task_s)
        end.to raise_error(Done::Task::ParseError)
      end
    end

    context 'with missing type' do
      let(:type) { '' }

      it 'throws a ParseError' do
        expect do
          described_class.parse(task_s)
        end.to raise_error(Done::Task::ParseError)
      end
    end

    context 'with invalid timestamp' do
      let(:timestamp) { 'invalid time' }

      it 'throws a ParseError' do
        expect do
          described_class.parse(task_s)
        end.to raise_error(Done::Task::ParseError)
      end
    end
  end

  describe '#short_padded_name' do
    it 'pads short names with spaces' do
      task.name = '*'

      expect(task.short_padded_name).to eq('*' + ' ' * 49)
    end

    it 'truncates long names' do
      task.name = '*' * 100

      expect(task.short_padded_name).to eq('*' * 47 + '...')
    end
  end

  describe '#start' do
    it 'sets the task type to Types::DOING' do
      # set task to a different type first since it's set to DOING to start
      task.stop

      expect do
        task.start
      end.to change { task.type }.to(described_class::Types::DOING)
    end

    it 'touches the task' do
      expect(task).to receive(:touch).once

      task.start
    end
  end

  describe '#stop' do
    it 'sets the task type to Types::DOING' do
      expect do
        task.stop
      end.to change { task.type }.to(described_class::Types::TODO)
    end

    it 'touches the task' do
      expect(task).to receive(:touch).once

      task.stop
    end
  end

  describe '#finish' do
    it 'sets the task type to Types::DOING' do
      expect do
        task.finish
      end.to change { task.type }.to(described_class::Types::DONE)
    end

    it 'touches the task' do
      expect(task).to receive(:touch).once

      task.finish
    end
  end

  describe '#block' do
    it 'sets the task type to Types::BLOCKED' do
      expect do
        task.block
      end.to change { task.type }.to(described_class::Types::BLOCKED)
    end

    it 'touches the task' do
      expect(task).to receive(:touch).once

      task.block
    end
  end
end
