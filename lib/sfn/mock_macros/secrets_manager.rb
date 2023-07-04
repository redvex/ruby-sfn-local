# frozen_string_literal: true

module Sfn
  module MockMacros
    module SecretsManager
      def self.response(data)
        data = [data] if data.is_a?(Hash)
        out_data = data.map do |val|
          if val.key?(:error)
            { Throw: { Error: val[:error], Cause: val[:cause] } }
          else
            val[:response] ||= val[:payload]
            val[:response] ||= val[:output]
            { Return: response_body(val) }
          end
        end
        out = {}
        out_data.each_with_index do |val, idx|
          out[idx.to_s] = val
        end
        out
      end

      def self.response_body(val)
        { ARN: val[:arn], CreatedDate: val[:created_date], Name: val[:name], SecretBinary: val[:secret_binary],
          SecretString: val[:response], VersionId: val[:version_id],
          VersionStages: (val[:version_stages] ? [val[:version_stages]] : nil) }.compact
      end
    end
  end
end
