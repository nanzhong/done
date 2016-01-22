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
end
