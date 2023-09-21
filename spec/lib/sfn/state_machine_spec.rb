# frozen_string_literal: true

require 'spec_helper'

describe 'Sfn::StateMachine' do
  let(:name) { 'test' }
  let(:variables) do
    {
      'variable_one' => 'some string',
      'variable_two' => '5'
    }
  end
  let(:arn) { nil }

  describe '.new' do
    subject { Sfn::StateMachine.new(name, variables, arn) }
    context 'the state machine does not exist' do
      context 'when the name contains a path' do
        let(:name) { 'test/hello' }
        it { expect(subject.path).to eq('./spec/support/definitions/test/hello.json') }
        it { expect(subject.name).to eq('test-hello') }
        it { expect(subject.executions).to eq({}) }
      end

      context 'when the name does not contain a path' do
        let(:name) { 'hello' }
        it { expect(subject.path).to eq('./spec/support/definitions/hello.json') }
        it { expect(subject.name).to eq('hello') }
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
      it { expect(Sfn::StateMachine.all.count).to eq(4) }
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
    subject { Sfn::StateMachine.new(name, variables, arn) }

    describe '#dry_run' do
      it { expect(subject.run).to be_an_instance_of(Sfn::Execution) }
    end

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

    describe 'load_definition' do
      let(:name) { 'map_and_wait' }
      before do
        local_definition = subject.send(:load_definition)
        state_machine_file = File.read(local_definition.gsub('file://', ''))
        @parsed_state_machine = JSON.parse(state_machine_file)
      end

      it 'sets MaxConcurrency to 1' do
        expect(@parsed_state_machine['States']['Map']['MaxConcurrency']).to be(1)
      end

      it 'converts the Wait state to a Pass state and remove the Seconds' do
        expect(@parsed_state_machine['States']['Map']['Iterator']['States']['Wait for interval']).to eq({
                                                                                                          'Type' => 'Pass',
                                                                                                          'Next' => 'Wait for date'
                                                                                                        })
      end

      it 'converts the Wait state to a Pass state and remove the Timestamp' do
        expect(@parsed_state_machine['States']['Map']['Iterator']['States']['Wait for date']).to eq({
                                                                                                      'Type' => 'Pass',
                                                                                                      'Next' => 'Wait for input'
                                                                                                    })
      end

      it 'converts the Wait state to a Pass state and remove the TimestampPath' do
        expect(@parsed_state_machine['States']['Map']['Iterator']['States']['Wait for input']).to eq({
                                                                                                       'Type' => 'Pass',
                                                                                                       'End' => true
                                                                                                     })
      end

      it 'converts the new Map state to the old one' do
        expect(@parsed_state_machine['States']['NewMap']['ItemProcessor']).not_to be
        expect(@parsed_state_machine['States']['NewMap']['Label']).not_to be
        expect(@parsed_state_machine['States']['NewMap']['Iterator']).to be
        expect(@parsed_state_machine['States']['NewMap']['Iterator']['Parameters']).not_to be
        expect(@parsed_state_machine['States']['NewMap']['Iterator']['ProcessorConfig']).not_to be
        expect(@parsed_state_machine['States']['NewMap']['Iterator']['ItemSelector']).not_to be
      end

      it 'converts the new Distributed Map state to the old one' do
        expect(@parsed_state_machine['States']['NewDistributedMap']['ItemProcessor']).not_to be
        expect(@parsed_state_machine['States']['NewDistributedMap']['Label']).not_to be
        expect(@parsed_state_machine['States']['NewDistributedMap']['Iterator']).to be
        expect(@parsed_state_machine['States']['NewDistributedMap']['Iterator']['Parameters']).not_to be
        expect(@parsed_state_machine['States']['NewDistributedMap']['Iterator']['ProcessorConfig']).not_to be
        expect(@parsed_state_machine['States']['NewDistributedMap']['Iterator']['ItemSelector']).not_to be
      end

      it 'replaces variables' do
        expect(@parsed_state_machine['States']['NewDistributedMap']['Iterator']['States']['Pass distributed State']['Parameters']['var1']).to eq('some string')
        expect(@parsed_state_machine['States']['NewDistributedMap']['Iterator']['States']['Pass distributed State']['Parameters']['var2']).to eq('5')
        expect(@parsed_state_machine['States']['NewDistributedMap']['Iterator']['States']['Pass distributed State']['Parameters']['var3']).to eq('${variable_three}')
      end
    end
  end
end
