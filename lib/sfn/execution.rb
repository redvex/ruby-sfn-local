# frozen_string_literal: true

module Sfn
  class Execution
    attr_accessor :id, :start_date, :uuid, :state_machine, :test_case, :arn, :output, :profile

    def self.call(state_machine, test_case, mock_data, input, dry_run = false)
      new(state_machine, test_case).exec(mock_data, input, dry_run)
    end

    def initialize(state_machine, test_case)
      self.uuid = SecureRandom.uuid
      self.state_machine = state_machine
      self.id = "#{self.state_machine.arn.gsub("stateMachine","execution")}:#{self.uuid}"
      self.test_case = test_case.camelize
    end

    def exec(mock_data, input, dry_run = false)
      MockData.write_context(state_machine.name, test_case, mock_data)
      out = AwsCli.run('stepfunctions', 'start-execution',
                            { name: uuid,
                              'state-machine': "#{state_machine.arn}##{test_case}",
                              input: "'#{input.to_json}'" 
                            })
      decoded = JSON.parse(out)
      self.arn = decoded["executionArn"]
      self.start_date = decoded["startDate"].gsub("000+00:00", "Z")
      self.output, self.profile = ExecutionLog.parse(arn, dry_run)
      self
    end
  end
end
