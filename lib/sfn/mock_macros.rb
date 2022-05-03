# frozen_string_literal: true

require "sfn/mock_macros/lambda"
require "sfn/mock_macros/step_function"
require "sfn/mock_macros/api_gateway"
require "sfn/mock_macros/sns"

module Sfn
  module MockMacros
    include Lambda
    include StepFunction
    include ApiGateway
    include Sns

    def self.gateway_response(data)
      ApiGateway.response(data)
    end

    def self.lambda_response(data)
      Lambda.response(data)
    end

    def self.sns_response(data)
      Sns.response(data)
    end

    def self.step_function_response(data)
      StepFunction.response(data)
    end

    def self.gateway_payload(data)
      warn "[DEPRECATION] `gateway_payload` is deprecated.  Please use `gateway_response` instead."
      ApiGateway.response(data)
    end

    def self.lambda_payload(data)
      warn "[DEPRECATION] `lambda_payload` is deprecated.  Please use `lambda_response` instead."
      Lambda.response(data)
    end

    def self.sns_payload(data)
      warn "[DEPRECATION] `sns_payload` is deprecated.  Please use `sns_response` instead."
      Sns.response(data)
    end

    def self.step_function_payload(data)
      warn "[DEPRECATION] `step_function_payload` is deprecated.  Please use `step_function_response` instead."
      StepFunction.response(data)
    end
  end
end
