# frozen_string_literal: true

module Sfn
  module MockMacros
    module NativeIntegration
      def self.response(data)
        data = [data] if data.is_a?(Hash)
        out_data = data.map do |val|
          if val.key?(:error)
            { Throw: { Error: val[:error], Cause: val[:cause] } }
          else
            { Return: val }
          end
        end
        out = {}
        out_data.each_with_index do |val, idx|
          out[idx.to_s] = val
        end
        out
      end
    end
  end
end
