require 'spec_helper'

describe 'Sfn::Collection' do
  subject { Class.new(Sfn::Collection).instance }
  let(:state_machine) { Sfn::StateMachine.new( 'test', 'arn:aws:states:us-east-1:123456789012:stateMachine:test') }
  let(:aws_cli) { "empty_aws" }
  before {
    Sfn.configure do |sf_config|
      sf_config.aws_command = "./spec/support/#{aws_cli}"
    end
  }
  after(:all) {
    Sfn.configure do |sf_config|
      sf_config.aws_command = './spec/support/aws'
      sf_config.definition_path = './spec/support/definitions'
      sf_config.mock_file_path = './spec/support/tmp/MockFile.json'
    end
  }
  describe '.new' do
    context 'aws cli returns some state machines' do
      let(:aws_cli) { "aws" }
      it { expect(subject.all.count).to eq(3) }
    end

    context 'aws cli does return no state machine' do
      it { expect(subject.all).to eq([]) }
    end
  end

  describe '#add' do
    before {
      subject.add(state_machine.to_hash)
    }
    it { expect(subject.all).to eq([state_machine.to_hash])}
  end

  describe '#delete_by_arn' do
    before {
      subject.delete_by_arn(state_machine.arn)
    }
    it { expect(subject.all).to eq([])}
  end
end