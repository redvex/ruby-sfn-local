# frozen_string_literal: true

require 'spec_helper'

describe 'Sfn::Execution' do
  let(:state_machine) { Sfn::StateMachine.new('hello') }
  let(:mock_data) { { mock: { Return: 'data' } } }
  let(:input) { { foo: 'bar' } }
  subject { Sfn::Execution.new(state_machine, 'test_case') }

  describe '.new' do
    it { expect(subject.uuid).to be }
    it { expect(subject.state_machine).to be(state_machine) }
    it { expect(subject.id).to eq("arn:aws:states:eu-west-1:123456789012:execution:hello:#{subject.uuid}") }
    it { expect(subject.start_date).not_to be }
    it { expect(subject.test_case).to eq('TestCase') }
  end

  describe '.call' do
    it 'an instance of Sfn::Execution to receive the exec method' do
      expect_any_instance_of(Sfn::Execution).to receive(:exec).with(mock_data, input, false)
      Sfn::Execution.call(state_machine, 'test_case', mock_data, input)
    end
  end

  describe '#exec' do
    it { expect(subject.exec(mock_data, input).output).to be }
    it { expect(subject.exec(mock_data, input).profile).to be }
    it { expect(subject.exec(mock_data, input).start_date).to eq('2022-04-30T03:35:08.683Z') }
  end
end
