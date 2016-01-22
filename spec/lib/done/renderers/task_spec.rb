require 'spec_helper'

describe Done::Renderers::Task do
  let(:name) { 'task name' }
  let(:type) { Done::Task::Types::DOING }
  let!(:timestamp) { Time.now }
  let(:notes) { ['a note'] }
  let(:properties) { { 'key' => 'value' } }

  let(:task_s) do
    "#{type} #{name}\n" \
    "  [#{timestamp}]\n" \
    "  % #{properties.keys.first}: #{properties.values.first}\n" \
    "  #{notes.first}\n"
  end

  let(:task) do
    Done::Task.new(
      name: name,
      type: type,
      timestamp: timestamp,
      notes: notes,
      properties: properties
    )
  end

  subject(:renderer) { described_class.new(task) }

  describe '#to_s' do
    it 'correctly renders the task in string format' do
      expect(renderer.to_s).to eq(task_s)
    end
  end
end
