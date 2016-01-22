require 'spec_helper'

describe Done::Renderers::Context do
  let(:version) { Done::VERSION }
  let(:stack) { Done::Stack.new([Done::Task.new(name: 'task name', type: Done::Task::Types::DOING, timestamp: timestamp)]) }
  let(:timestamp) { Time.parse('2014-01-01 10:10:10 -0500') }
  let(:properties) { { 'key' => 'value' } }

  let(:context_s) do
    "# Done 0.0.1 [2014-01-01 10:10:10 -0500]\n" \
    "# % key: value\n" \
    "\n" \
    "* task name\n" \
    "  [2014-01-01 10:10:10 -0500]\n"
  end

  let(:context) { Done::Context.new(version, stack, timestamp: timestamp, properties: properties) }

  subject(:renderer) { described_class.new(context) }

  describe '#to_s' do
    it 'returns a string representation of a context' do
      expect(renderer.to_s).to eq(context_s)
    end
  end
end
