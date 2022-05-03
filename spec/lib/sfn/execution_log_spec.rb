require 'spec_helper'

describe 'Sfn::ExecutionLog' do
  describe '.parse' do
    let(:arn) { "some_valid_arn" }
    let(:expected_output) { "World" }
    let(:expected_profile) do
      {
        "Hello" => {
          input: [{}],
          output: [{}]
        },
        "World" => {
          input: [{}],
          output: ["World"]
        }
      }
    end
    it { expect(Sfn::ExecutionLog.parse(arn)).to eq([expected_output, expected_profile])}
  end

  context 'instance methods' do
    subject { Sfn::ExecutionLog.new(event) }
    describe '#state_name' do
      context 'when a stateEnteredEventDetails event is passed' do
        let(:event) do 
          {
            "stateEnteredEventDetails" => {
              "name" => "hello"
            }, 
            "stateExitedEventDetails" => nil
          }
        end
        it { expect(subject.state_name).to eq("hello") }
      end

      context 'when a stateExitedEventDetails event is passed' do
        let(:event) do 
          {
            "stateEnteredEventDetails" => nil, 
            "stateExitedEventDetails" => {
              "name" => "hello"
            }
          }
        end
        it { expect(subject.state_name).to eq("hello") }
      end

      context 'when another event is passed' do
        let(:event) do 
          {
            "stateEnteredEventDetails" => nil, 
            "stateExitedEventDetails" => nil
          }
        end
        it { expect(subject.state_name).not_to be }
      end
    end

    describe '#output' do
      context 'wheh a executionSucceededEventDetails event is passed' do
        let(:event) do
          {
            "executionSucceededEventDetails" => {
              "output" => "\"world\""
            }
          }
        end
        it { expect(subject.output).to eq("world") }
      end

      context 'when another event is passed' do
        let(:event) do 
          {
            "executionSucceededEventDetails" => nil
          }
        end
        it { expect(subject.output).not_to be }
      end
    end

    describe '#error' do
      context 'wheh a executionSucceededEventDetails event is passed' do
        let(:event) do
          {
            "executionFailedEventDetails" => {
              "error" => "\"401\"",
              "cause" => "\"User is not authorised\""
            }
          }
        end
        it { expect{subject.error}.to raise_error(Sfn::ExecutionError) }
      end

      context 'when another event is passed' do
        let(:event) do 
          {
            "executionFailedEventDetails" => nil
          }
        end
        it { expect(subject.error).not_to be }
      end
    end

    describe '#profile' do
      context 'when a stateEnteredEventDetails event is passed' do
        let(:event) do 
          {
            "stateEnteredEventDetails" => {
              "input" => "{}"
            }, 
            "stateExitedEventDetails" => nil
          }
        end
        it { expect(subject.profile).to eq({ input: {} }) }
      end

      context 'when a stateExitedEventDetails event is passed' do
        let(:event) do 
          {
            "stateEnteredEventDetails" => nil, 
            "stateExitedEventDetails" => {
              "output" => "\"world\""
            }
          }
        end
        it { expect(subject.profile).to eq( { output: "world" } ) }
      end

      context 'when another event is passed' do
        let(:event) do 
          {
            "stateEnteredEventDetails" => nil, 
            "stateExitedEventDetails" => nil
          }
        end
        it { expect(subject.profile).to eq( {} ) }
      end
    end
  end
end