require 'spec_helper'

describe 'Sfn::Execution' do
  let(:state_machine) { Sfn::StateMachine.new("hello") }
  let(:mock_data) { {"mock": {"Return": "data"} } }
  let(:input) { {foo: "bar"} }
  subject { Sfn::Execution.new(state_machine, "test_case") }

  describe '.new' do
    it { expect(subject.uuid).to be }
    it { expect(subject.state_machine).to be(state_machine) }
    it { expect(subject.test_case).to eq("TestCase") }
  end

  describe '.call' do
    it 'an instance of Sfn::Execution to receive the exec method' do
      expect_any_instance_of(Sfn::Execution).to receive(:exec).with(mock_data, input)
      Sfn::Execution.call(state_machine, 'test_case', mock_data, input)
    end
  end

  describe '#exec' do
    it { expect(subject.exec(mock_data, input).output).to be }
    it { expect(subject.exec(mock_data, input).profile).to be }
  end
end