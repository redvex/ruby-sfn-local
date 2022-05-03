# frozen_string_literal: true

module Sfn
  class Execution
    attr_accessor :uuid, :state_machine, :test_case, :arn, :output, :profile

    def self.call(state_machine, test_case, mock_data, input)
      new(state_machine, test_case).exec(mock_data, input)
    end

    def initialize(state_machine, test_case)
      self.uuid = SecureRandom.uuid
      self.state_machine = state_machine
      self.test_case = test_case.camelize
    end

    def exec(mock_data, input)
      MockData.write_context(state_machine.name, test_case, mock_data)
      self.arn = AwsCli.run("stepfunctions", "start-execution",
                            { name: uuid,
                              "state-machine": "#{state_machine.arn}##{test_case}",
                              input: "'#{input.to_json}'" },
                            "executionArn")
      self.output, self.profile = ExecutionLog.parse(arn)
      self
    end
  end
end
