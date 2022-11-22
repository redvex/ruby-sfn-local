# frozen_string_literal: true

module Sfn
  module MockMacros
    module OptimisedStepFunction
      def self.response(data)
        data = [data] if data.is_a?(Hash)
        data.map! do |val|
          if val.key?(:error)
            { Throw: { Error: val[:error], Cause: val[:cause] } }
          else
            val[:output] ||= val[:payload]
            val[:output] ||= val[:response]
            { Return: { Output: val[:output], Status: 'SUCCEDED' } }
          end
        end
        out = {}
        data.each_with_index do |val, idx|
          out[idx.to_s] = val
        end
        out
      end
    end
  end
end
