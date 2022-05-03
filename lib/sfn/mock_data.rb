# frozen_string_literal: true

require 'tempfile'
require 'openssl'

module Sfn
  module MockData
    def self.write_context(state_machine_name, context, mock_data = {})
      data = {
        'StateMachines' => {
          state_machine_name.to_s => {
            'TestCases' => {
              context.to_s => { 'foo' => 'bar' }
            }
          }
        },
        'MockedResponses' => { 'bar' => {} }
      }

      mock_data.each do |step, response|
        uuid = OpenSSL::Digest::SHA512.digest({ step: step }.merge(response).to_json).camelize
        data['StateMachines'][state_machine_name.to_s]['TestCases'][context.to_s][step.to_s] = uuid
        data['MockedResponses'][uuid] = response
      end
      File.write(Sfn.configuration.mock_file_path, JSON.pretty_generate(data))
    end
  end
end
