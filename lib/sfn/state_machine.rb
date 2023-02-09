# frozen_string_literal: true

require 'tempfile'
require 'openssl'

module Sfn
  class DefinitionError < RuntimeError; end

  class StateMachine
    ROLE = 'arn:aws:iam::123456789012:role/DummyRole'

    attr_accessor :name, :path, :definition, :arn, :executions, :execution_arn

    def self.all
      Collection.instance.all.map { |sf| new(sf['name'], sf['stateMachineArn']) }
    end

    def self.destroy_all
      all.each(&:destroy)
    end

    def self.find_by_name(name)
      all.find { |sf| sf.name == name }
    end

    def self.find_by_arn(arn)
      all.find { |sf| sf.arn == arn }
    end

    def initialize(name, arn = nil)
      self.path = "#{Sfn.configuration.definition_path}/#{name}.json"
      self.name = name.split('/').last
      self.arn = arn || self.class.find_by_name(self.name)&.arn || create_state_machine
      self.executions = {}
    end

    def destroy
      AwsCli.run('stepfunctions', 'delete-state-machine',
                 { 'state-machine-arn': arn })
      Collection.instance.delete_by_arn(arn)
    end

    def dry_run(mock_data = {}, input = {}, test_name = nil)
      execution = run(mock_data, input, test_name, true)
    end
    
    def run(mock_data = {}, input = {}, test_name = nil, dry_run = false)
      test_name ||= OpenSSL::Digest::SHA512.digest(mock_data.merge({ input: input }).to_json)
      executions[test_name] ||= Execution.call(self, test_name, mock_data, input, dry_run)
      executions[test_name]
    end

    def to_hash
      { 'stateMachineArn' => arn, 'name' => name }
    end

    private

    def create_state_machine
      self.arn = AwsCli.run('stepfunctions', 'create-state-machine',
                            { definition: load_definition, name: name, 'role-arn': ROLE }, 'stateMachineArn')
      raise Sf::DefinitionError if arn.empty?

      Collection.instance.add(to_hash)
      arn
    end

    def load_definition
      local_definition_path = Tempfile.new(['name', '.json']).path

      definition = File.read(path)
      local_definition = definition
      local_definition = local_definition.gsub(/"MaxConcurrency": [0-9]+/, '"MaxConcurrency": 1')
      local_definition = local_definition.gsub(/"Type": "Wait"/, '"Type": "Pass"')
      local_definition = local_definition.gsub(/"Seconds": [0-9]+,*/, '')
      local_definition = local_definition.gsub(/"Timestamp": "[0-9\-T:+]+",*/, '')
      local_definition = local_definition.gsub(/"TimestampPath": "[^\"]+",*/, '')
      local_definition = local_definition.gsub("ItemProcessor", "Iterator")
      local_definition = local_definition.gsub("ItemSelector", "Parameters")
      local_definition = local_definition.gsub(/"ProcessorConfig":\s*{[\s"[A-Za-z:,]]+},*/, "")
      local_definition = local_definition.gsub(/"Label": "[A-Za-z]+",*/, "")
      local_definition = local_definition.gsub(/,[\s\n]+\}/, "\n}")
      
      File.open(local_definition_path, 'w') { |file| file.puts local_definition }
      "file://#{local_definition_path}"
    end
  end
end
