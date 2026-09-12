# frozen_string_literal: true

require 'tempfile'
require 'openssl'

module Sfn
  module MockData
    def self.write_context(state_machine_name, context, mock_data = {})
      test_case = {}
      mocked_responses = {}

      mock_data.each do |step, response|
        uuid = OpenSSL::Digest::SHA512.digest({ step: step }.merge(response).to_json).camelize
        test_case[step.to_s] = uuid
        mocked_responses[uuid] = response
      end

      data = {
        'StateMachines' => {
          state_machine_name.to_s => {
            'TestCases' => { context.to_s => test_case }
          }
        },
        'MockedResponses' => mocked_responses
      }
      File.write(Sfn.configuration.mock_file_path, JSON.pretty_generate(data))
    end
  end
end
