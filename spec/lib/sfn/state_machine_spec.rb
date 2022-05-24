# frozen_string_literal: true

require 'spec_helper'

describe 'Sfn::StateMachine' do
  let(:name) { 'test' }
  let(:arn)  { nil }

  describe '.new' do
    subject { Sfn::StateMachine.new(name, arn) }
    context 'the state machine does not exist' do
      context 'when the name contains a path' do
        let(:name) { 'test/hello' }
        it { expect(subject.path).to eq("./spec/support/definitions/test/hello.json") }
        it { expect(subject.name).to eq("hello") }
        it { expect(subject.executions).to eq({}) }
      end

      context 'when the name does not contain a path' do
        let(:name) { 'hello' }
        it { expect(subject.path).to eq("./spec/support/definitions/hello.json") }
        it { expect(subject.name).to eq("hello") }
        it { expect(subject.executions).to eq({}) }
      end
    end

    context 'the state machine exist' do
      it { expect(Sfn::AwsCli).not_to receive(:run) }
      it { expect(subject.name).to eq(name) }
      it { expect(subject.executions).to eq({}) }
    end

    context 'a specific arn is passed' do
      let(:arn) { 'arn:aws:states:us-east-1:123456789012:stateMachine:test' }
      it { expect(Sfn::AwsCli).not_to receive(:run) }
      it { expect(subject.arn).to eq(arn) }
      it { expect(subject.executions).to eq({}) }
    end
  end

  context 'class methods based on collection' do
    describe '.all' do
      it { expect(Sfn::StateMachine.all.count).to eq(3) }
    end

    describe '.find_by_name' do
      subject { Sfn::StateMachine.find_by_name('test') }

      it { expect(subject.name).to eq('test') }
      it { expect(subject.arn).to eq('arn:aws:states:eu-west-1:123456789012:stateMachine:test') }
      it { expect(subject.executions).to eq({}) }
    end

    describe '.find_by_arn' do
      subject { Sfn::StateMachine.find_by_arn('arn:aws:states:eu-west-1:123456789012:stateMachine:test') }

      it { expect(subject.name).to eq('test') }
      it { expect(subject.arn).to eq('arn:aws:states:eu-west-1:123456789012:stateMachine:test') }
      it { expect(subject.executions).to eq({}) }
    end

    describe '.destroy_all' do
      let!(:all_state_machines) { Sfn::StateMachine.all }
      before do
        Sfn::StateMachine.destroy_all
      end
      it { expect(Sfn::StateMachine.all.count).to eq(0) }
    end
  end

  context 'instance method' do
    subject { Sfn::StateMachine.new(name, arn) }

    describe '#run' do
      it { expect(subject.run).to be_an_instance_of(Sfn::Execution) }
    end

    describe '#destroy' do
      it { expect(subject.destroy).to be }
    end

    describe '#to_hash' do
      it {
        expect(subject.to_hash).to eq({ 'stateMachineArn' => 'arn:aws:states:eu-west-1:123456789012:stateMachine:test',
                                        'name' => 'test' })
      }
    end
  end
end
