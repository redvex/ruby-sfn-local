# frozen_string_literal: true

require 'spec_helper'

describe 'Sfn::ExecutionLog' do
  describe '.parse' do
    let(:dry_run) { false }
    context 'sequential tasks' do
      before do
        Sfn.configure do |sf_config|
          sf_config.aws_command = './spec/support/task_aws'
        end
      end
      after do
        Sfn.configure do |sf_config|
          sf_config.aws_command = './spec/support/aws'
          sf_config.definition_path = './spec/support/definitions'
          sf_config.mock_file_path = './spec/support/tmp/MockFile.json'
        end
      end
      let(:arn) { 'some_valid_arn' }
      let(:expected_output) do
        {
          'id' => 1,
          'status' => 'sent'
        }
      end
      let(:expected_profile) do
        {
          'Get Sessions' => {
            'input' => [{ 'data_start' => '2022-01-01', 'data_end' => '2022-01-31', 'school_id' => 1 }],
            'output' => [{ 'data_start' => '2022-01-01', 'data_end' => '2022-01-31', 'attended' => 9, 'cancelled' => 1,
                           'sessions_ids' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }],
            'parameters' => [{ 'ApiEndpoint' => 'abcde1f2g3.execute-api.eu-west-1.amazonaws.com',
                               'Method' => 'GET',
                               'Headers' => { 'Content-Type' => ['application/json'] },
                               'Stage' => 'v1',
                               'QueryParameters' => {
                                 'data_end' => ['2022-01-31'],
                                 'data_start' => ['2022-01-01']
                               },
                               'Path' => '/schools/1/sessions/summary' }]
          },
          'Set Session Status' => {
            'input' => [{ 'data_start' => '2022-01-01', 'data_end' => '2022-01-31', 'attended' => 9, 'cancelled' => 1,
                          'sessions_ids' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }],
            'output' => [{ 'data_start' => '2022-01-01', 'data_end' => '2022-01-31', 'attended' => 9, 'cancelled' => 1,
                           'sessions_ids' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }],
            'parameters' => [{ 'ApiEndpoint' => 'abcde1f2g3.execute-api.eu-west-1.amazonaws.com',
                               'Method' => 'PUT',
                               'Headers' => { 'Content-Type' => ['application/json'] },
                               'Stage' => 'v1',
                               'RequestBody' => {
                                 'status' => 'processing',
                                 'sessions_ids' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                               },
                               'Path' => '/schools/1/sessions/bulk_updates' }]
          },
          'Fake output' => {
            'input' => [{ 'data_start' => '2022-01-01', 'data_end' => '2022-01-31', 'attended' => 9, 'cancelled' => 1,
                          'sessions_ids' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }],
            'output' => [{ 'id' => 1, 'status' => 'sent' }],
            'parameters' => []
          }
        }
      end
      it { expect(Sfn::ExecutionLog.parse(arn, dry_run)).to eq([expected_output, expected_profile]) }
    end

    context 'parallel tasks' do
      before do
        Sfn.configure do |sf_config|
          sf_config.aws_command = './spec/support/parallel_aws'
        end
      end
      after do
        Sfn.configure do |sf_config|
          sf_config.aws_command = './spec/support/aws'
          sf_config.definition_path = './spec/support/definitions'
          sf_config.mock_file_path = './spec/support/tmp/MockFile.json'
        end
      end
      let(:arn) { 'some_valid_arn' }
      let(:expected_output) do
        ['Response from API 1', 'Response from API 2', 'Response from API 3']
      end
      let(:expected_profile) do
        {
          'Parallel' => {
            'input' => [{}],
            'output' => [['Response from API 1', 'Response from API 2', 'Response from API 3']],
            'parameters' => []
          },
          'Step 1' => {
            'input' => [{}],
            'output' => [{ 'id' => 1, 'foo' => 'bar', 'hello' => 'world' }],
            'parameters' => []
          },
          'Filter 1' => {
            'input' => [{ 'id' => 1, 'foo' => 'bar', 'hello' => 'world' }],
            'output' => [1],
            'parameters' => []
          },
          'Api 1' => {
            'input' => [1],
            'output' => ['Response from API 1'],
            'parameters' => [{ 'ApiEndpoint' => 'abcde1f2g3.execute-api.eu-west-1.amazonaws.com',
                               'Method' => 'GET',
                               'Stage' => 'v1',
                               'Path' => '/endpoint/1' }]
          },
          'Step 2' => {
            'input' => [{}],
            'output' => [{ 'id' => 2, 'foo' => 'bear', 'hello' => 'war' }],
            'parameters' => []
          },
          'Filter 2' => {
            'input' => [{ 'id' => 2, 'foo' => 'bear', 'hello' => 'war' }],
            'output' => [2],
            'parameters' => []
          },
          'Api 2' => {
            'input' => [2],
            'output' => ['Response from API 2'],
            'parameters' => [{ 'ApiEndpoint' => 'abcde1f2g3.execute-api.eu-west-1.amazonaws.com',
                               'Method' => 'GET',
                               'Stage' => 'v1',
                               'Path' => '/endpoint/2' }]
          },
          'Step 3' => {
            'input' => [{}],
            'output' => [{ 'id' => 3, 'foo' => 'beard', 'hello' => 'wall' }],
            'parameters' => []
          },
          'Filter 3' => {
            'input' => [{ 'id' => 3, 'foo' => 'beard', 'hello' => 'wall' }],
            'output' => [3],
            'parameters' => []
          },
          'Api 3' => {
            'input' => [3],
            'output' => ['Response from API 3'],
            'parameters' => [{ 'ApiEndpoint' => 'abcde1f2g3.execute-api.eu-west-1.amazonaws.com',
                               'Method' => 'GET',
                               'Stage' => 'v1',
                               'Path' => '/endpoint/3' }]
          }
        }
      end
      it { expect(Sfn::ExecutionLog.parse(arn)).to eq([expected_output, expected_profile]) }
    end
  end

  context 'instance methods' do
    subject { Sfn::ExecutionLog.new(event) }
    describe '#state_name' do
      context 'when a stateEnteredEventDetails event is passed' do
        let(:event) do
          {
            'stateEnteredEventDetails' => {
              'name' => 'hello'
            },
            'stateExitedEventDetails' => nil
          }
        end
        it { expect(subject.state_name).to eq('hello') }
      end

      context 'when a stateExitedEventDetails event is passed' do
        let(:event) do
          {
            'stateEnteredEventDetails' => nil,
            'stateExitedEventDetails' => {
              'name' => 'hello'
            }
          }
        end
        it { expect(subject.state_name).to eq('hello') }
      end

      context 'when another event is passed' do
        let(:event) do
          {
            'stateEnteredEventDetails' => nil,
            'stateExitedEventDetails' => nil
          }
        end
        it { expect(subject.state_name).not_to be }
      end
    end

    describe '#output' do
      context 'wheh a executionSucceededEventDetails event is passed' do
        let(:event) do
          {
            'executionSucceededEventDetails' => {
              'output' => '"world"'
            }
          }
        end
        it { expect(subject.output).to eq('world') }
      end

      context 'when another event is passed' do
        let(:event) do
          {
            'executionSucceededEventDetails' => nil
          }
        end
        it { expect(subject.output).not_to be }
      end
    end

    describe '#error' do
      context 'wheh a executionFailedEventDetails event is passed' do
        let(:event) do
          {
            'executionFailedEventDetails' => {
              'error' => '"401"',
              'cause' => '"User is not authorised"'
            }
          }
        end
        context 'when dry_run is false' do
          it { expect { subject.error(event.to_json, false) }.to raise_error(Sfn::ExecutionError) }
        end

        context 'when dry_run is true' do
          it { expect { subject.error(event.to_json, true) }.not_to raise_error }
        end
      end

      context 'when another event is passed' do
        let(:event) do
          {
            'executionFailedEventDetails' => nil
          }
        end
        it { expect(subject.error).not_to be }
      end
    end

    describe '#profile' do
      context 'when a stateEnteredEventDetails event is passed' do
        let(:event) do
          {
            'stateEnteredEventDetails' => {
              'input' => '{}'
            },
            'stateExitedEventDetails' => nil
          }
        end
        it { expect(subject.profile).to eq({ 'input' => {} }) }
      end

      context 'when a stateExitedEventDetails event is passed' do
        let(:event) do
          {
            'stateEnteredEventDetails' => nil,
            'stateExitedEventDetails' => {
              'output' => '"world"'
            }
          }
        end
        it { expect(subject.profile).to eq({ 'output' => 'world' }) }
      end

      context 'when a stateExitedEventDetails event is passed' do
        let(:event) do
          {
            'taskScheduledEventDetails' => {
              'resourceType' => 'apigateway',
              'resource' => 'invoke',
              'region' => 'eu-west-1',
              'parameters' => '{"ApiEndpoint":"abcde1f2g3.execute-api.eu-west-1.amazonaws.com","Method":"GET","Headers":{"Content-Type":["application/json"]},"Stage":"v1","QueryParameters":{"data_end":["2022-01-31"],"data_start":["2022-01-01"]},"Path":"/schools/1/sessions/summary"}'
            }
          }
        end

        it {
          expect(subject.profile).to eq({ 'parameters' => {
                                          'ApiEndpoint' => 'abcde1f2g3.execute-api.eu-west-1.amazonaws.com',
                                          'Method' => 'GET',
                                          'Headers' => { 'Content-Type' => ['application/json'] },
                                          'Stage' => 'v1',
                                          'QueryParameters' => {
                                            'data_end' => ['2022-01-31'],
                                            'data_start' => ['2022-01-01']
                                          },
                                          'Path' => '/schools/1/sessions/summary'
                                        } })
        }
      end

      context 'when another event is passed' do
        let(:event) do
          {
            'stateEnteredEventDetails' => nil,
            'stateExitedEventDetails' => nil
          }
        end
        it { expect(subject.profile).to eq({}) }
      end
    end
  end
end
