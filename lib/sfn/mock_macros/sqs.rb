# frozen_string_literal: true

module Sfn
  module MockMacros
    module Sqs
      def self.response(data)
        data = [data] if data.is_a?(Hash)
        data.map! do |val|
          if val.key?(:error)
            { Throw: { Error: val[:error], Cause: val[:cause] } }
          else
            val[:uuid] ||= SecureRandom.uuid
            val[:sequence] ||= 10_000_000_000_000_003_000
            { Return: { MessageId: val[:uuid], SequenceNumber: val[:sequence] } }
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
