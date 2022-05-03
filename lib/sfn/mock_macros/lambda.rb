# frozen_string_literal: true

module Sfn
  module MockMacros
    module Lambda
      def self.response(data)
        data = [data] if data.is_a?(Hash)
        data.map! do |val|
          if val.key?(:error)
            { Throw: { Error: val[:error], Cause: val[:cause] } }
          else
            val[:payload] ||= val[:response]
            val[:payload] ||= val[:output]
            { Return: { Payload: val[:payload], StatusCode: 200 } }
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
