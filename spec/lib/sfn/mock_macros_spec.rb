# frozen_string_literal: true

require 'spec_helper'

describe 'Sfn::MockMacros' do
  let(:data) { 'some data' }
  let(:deprecation_msg) do
    "[DEPRECATION] `#{method}_payload` is deprecated.  Please use `#{method}_response` instead."
  end
  describe 'macros' do
    describe '.gateway_response' do
      it { expect(Sfn::MockMacros).to respond_to(:gateway_response).with(1).argument }
      it 'call Sfn::MockMacros::ApiGateway.response' do
        expect(Sfn::MockMacros::ApiGateway).to receive(:response).with(data)
        Sfn::MockMacros.gateway_response(data)
      end
    end
    describe '.lambda_response' do
      it { expect(Sfn::MockMacros).to respond_to(:lambda_response).with(1).argument }
      it 'call Sfn::MockMacros::Lambda.response' do
        expect(Sfn::MockMacros::Lambda).to receive(:response).with(data)
        Sfn::MockMacros.lambda_response(data)
      end
    end
    describe '.sns_response' do
      it { expect(Sfn::MockMacros).to respond_to(:sns_response).with(1).argument }
      it 'call Sfn::MockMacros::Sns.response' do
        expect(Sfn::MockMacros::Sns).to receive(:response).with(data)
        Sfn::MockMacros.sns_response(data)
      end
    end
    describe '.sqs_response' do
      it { expect(Sfn::MockMacros).to respond_to(:sqs_response).with(1).argument }
      it 'call Sfn::MockMacros::Sqs.response' do
        expect(Sfn::MockMacros::Sqs).to receive(:response).with(data)
        Sfn::MockMacros.sqs_response(data)
      end
    end
    describe '.step_function_response' do
      it { expect(Sfn::MockMacros).to respond_to(:step_function_response).with(1).argument }
      it 'call Sfn::MockMacros::StepFunction.response' do
        expect(Sfn::MockMacros::StepFunction).to receive(:response).with(data)
        Sfn::MockMacros.step_function_response(data)
      end
    end
  end

  describe 'legacy_macro' do
    describe '.gateway_payload' do
      let(:method) { 'gateway' }
      it { expect(Sfn::MockMacros).to respond_to(:gateway_payload).with(1).argument }
      it 'call Sfn::MockMacros::ApiGateway.response' do
        expect(Sfn::MockMacros::ApiGateway).to receive(:response).with(data)
        expect(Sfn::MockMacros).to receive(:warn).with(deprecation_msg)
        Sfn::MockMacros.gateway_payload(data)
      end
    end
    describe '.lambda_payload' do
      let(:method) { 'lambda' }
      it { expect(Sfn::MockMacros).to respond_to(:lambda_payload).with(1).argument }
      it 'call Sfn::MockMacros::Lambda.response' do
        expect(Sfn::MockMacros::Lambda).to receive(:response).with(data)
        expect(Sfn::MockMacros).to receive(:warn).with(deprecation_msg)
        Sfn::MockMacros.lambda_payload(data)
      end
    end
    describe '.sns_payload' do
      let(:method) { 'sns' }
      it { expect(Sfn::MockMacros).to respond_to(:sns_payload).with(1).argument }
      it 'call Sfn::MockMacros::Sns.response' do
        expect(Sfn::MockMacros::Sns).to receive(:response).with(data)
        expect(Sfn::MockMacros).to receive(:warn).with(deprecation_msg)
        Sfn::MockMacros.sns_payload(data)
      end
    end
    describe '.step_function_payload' do
      let(:method) { 'step_function' }
      it { expect(Sfn::MockMacros).to respond_to(:step_function_payload).with(1).argument }
      it 'call Sfn::MockMacros::StepFunction.response' do
        expect(Sfn::MockMacros::StepFunction).to receive(:response).with(data)
        expect(Sfn::MockMacros).to receive(:warn).with(deprecation_msg)
        Sfn::MockMacros.step_function_payload(data)
      end
    end
  end
end
