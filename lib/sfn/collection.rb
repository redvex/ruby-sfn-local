# frozen_string_literal: true

require "singleton"

module Sfn
  class Collection
    include Singleton

    attr_reader :all

    def initialize
      response = AwsCli.run("stepfunctions", "list-state-machines", {})
      parsed_response = JSON.parse(response)
      @all = parsed_response["stateMachines"] || []
    end

    def add(state_machine)
      @all.push(state_machine.slice("stateMachineArn", "name"))
    end

    def delete_by_arn(state_machine_arn)
      @all.delete_if { |sf| sf["stateMachineArn"] == state_machine_arn }
    end
  end
end
