require 'spec_helper'

describe 'Sfn::MockMacros' do
  let(:data) { "some data" }
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
      it { expect(Sfn::MockMacros).to respond_to(:gateway_payload).with(1).argument }
      it 'call Sfn::MockMacros::ApiGateway.response' do
        expect(Sfn::MockMacros::ApiGateway).to receive(:response).with(data)
        expect(Sfn::MockMacros).to receive(:warn).with("[DEPRECATION] `gateway_payload` is deprecated.  Please use `gateway_response` instead.")
        Sfn::MockMacros.gateway_payload(data)
      end
    end
    describe '.lambda_payload' do
      it { expect(Sfn::MockMacros).to respond_to(:lambda_payload).with(1).argument }
      it 'call Sfn::MockMacros::Lambda.response' do
        expect(Sfn::MockMacros::Lambda).to receive(:response).with(data)
        expect(Sfn::MockMacros).to receive(:warn).with("[DEPRECATION] `lambda_payload` is deprecated.  Please use `lambda_response` instead.")
        Sfn::MockMacros.lambda_payload(data)
      end
    end
    describe '.sns_payload' do
      it { expect(Sfn::MockMacros).to respond_to(:sns_payload).with(1).argument }
      it 'call Sfn::MockMacros::Sns.response' do
        expect(Sfn::MockMacros::Sns).to receive(:response).with(data)
        expect(Sfn::MockMacros).to receive(:warn).with("[DEPRECATION] `sns_payload` is deprecated.  Please use `sns_response` instead.")
        Sfn::MockMacros.sns_payload(data)
      end
    end
    describe '.step_function_payload' do
      it { expect(Sfn::MockMacros).to respond_to(:step_function_payload).with(1).argument }
      it 'call Sfn::MockMacros::StepFunction.response' do
        expect(Sfn::MockMacros::StepFunction).to receive(:response).with(data)
        expect(Sfn::MockMacros).to receive(:warn).with("[DEPRECATION] `step_function_payload` is deprecated.  Please use `step_function_response` instead.")
        Sfn::MockMacros.step_function_payload(data)
      end
    end
  end
end