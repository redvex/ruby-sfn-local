require 'spec_helper'
require 'json'

describe 'Sfn::MockData' do
  let(:state_machine_name) { "MyStateMachine" }
  let(:context) { "MyContext" }
  let(:mock_file_json_content) { File.read(Sfn.configuration.mock_file_path) }
  let(:base_expected_data) do
    {
      "StateMachines" => {
        "#{state_machine_name}" => {
          "TestCases" => {
            "#{context}" => {
              "foo" => "bar"
            }
          }
        }
      },
      "MockedResponses" => {
        "bar" => {}
      }
    }
  end

  context 'mock_data is an empty array' do
    it 'the mock_data file has been written correctly' do
      Sfn::MockData.write_context(state_machine_name, context)
      expect(JSON.parse(mock_file_json_content)).to eq(base_expected_data) 
    end
  end

  context 'mock_data contains some data' do
    let(:mock_data) do
      {
        "first state" => { "Return" => { "Payload" => "hello", "StatusCode" => 200 } },
        "second state" => { "Return" => { "Payload" => "world", "StatusCode" => 200 } }
      }
    end
    let(:expected_data) do
      expected_data = base_expected_data
      mock_data.each do |step, response|
        uuid = OpenSSL::Digest::SHA512.digest({ step: step }.merge(response).to_json).camelize
        expected_data["StateMachines"][state_machine_name.to_s]["TestCases"][context.to_s][step.to_s] = uuid
        expected_data["MockedResponses"][uuid.to_s] = response
      end
      expected_data
    end
    it 'the mock_data file has been written correctly' do
      Sfn::MockData.write_context(state_machine_name, context, mock_data)
      expect(JSON.parse(mock_file_json_content)).to eq(expected_data) 
    end
  end
end