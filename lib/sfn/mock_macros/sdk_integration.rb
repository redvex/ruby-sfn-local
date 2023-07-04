# frozen_string_literal: true

module Sfn
  module MockMacros
    module SdkIntegration
      def self.response(data)
        data = [data] if data.is_a?(Hash)
        out_data = data.map do |val|
          { Return: val.to_json }
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
