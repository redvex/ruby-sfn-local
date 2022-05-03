# frozen_string_literal: true

require 'open3'

module Sfn
  class AwsCli
    class ExecutionError < StandardError; end

    def self.run(mod, command, params, key = nil, debug_info = '')
      command = "#{Sfn.configuration.aws_command || 'aws'} #{mod} #{command} \
                      --endpoint #{Sfn.configuration.aws_endpoint} \
                      #{params.map do |k, v|
                        "--#{k}=#{v}"
                      end.join(' ')} \
                      --no-cli-pager"
      stdout, stderr, _status = Open3.capture3(command)

      raise raise ExecutionError, "#{stderr.strip}\n#{debug_info}" unless stderr.strip.empty?

      unless key.nil?
        data = JSON.parse(stdout)
        return data[key].strip if data.key?(key)
      end

      stdout
    end
  end
end
