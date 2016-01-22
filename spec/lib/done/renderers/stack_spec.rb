require 'spec_helper'

describe Done::Renderers::Stack do

  let(:tasks) do
    [
      Done::Task.new(name: 'test', type: Done::Task::Types::DOING),
      Done::Task.new(name: 'test', type: Done::Task::Types::BLOCKED),
      Done::Task.new(name: 'test', type: Done::Task::Types::TODO),
      Done::Task.new(name: 'test', type: Done::Task::Types::DONE)
    ]
  end

  let(:stack) { Done::Stack.new(tasks) }

  subject(:renderer) { described_class.new(stack) }


  describe '#to_s' do
    it 'returns a string representation of the stack' do
      expect(renderer.to_s).to eq(tasks.map { |task| Done::Renderers::Task.new(task).to_s }.join("\n"))
    end
  end
end
