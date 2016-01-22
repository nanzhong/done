require 'spec_helper'

describe Done::Context do
  let(:version) { Done::VERSION }
  let(:stack) { Done::Stack.new }
  let(:timestamp) { Time.now }
  let(:properties) { { 'key' => 'value' } }

  subject(:context) { described_class.new(version, stack, timestamp: timestamp, properties: properties) }

  describe '#initialize' do
    it 'initializes all the attributes' do
      expect(context.version).to eq(version)
      expect(context.timestamp).to eq(timestamp)
      expect(context.properties).to eq('key' => 'value')
    end
  end

  describe '.parse' do
    it 'correctly parses a context' do
      context_s =
        "# Done 0.0.1 [2014-01-01 10:10:10]\n" \
        "# % key: value\n"

      parsed_context = Done::Context.parse(context_s)
      expect(parsed_context.version).to eq('0.0.1')
      expect(parsed_context.timestamp).to eq(Time.parse('2014-01-01 10:10:10'))
      expect(parsed_context.properties).to eq('key' => 'value')
    end
  end
end
