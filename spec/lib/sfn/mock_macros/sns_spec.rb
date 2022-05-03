# frozen_string_literal: true

require 'spec_helper'

describe 'Sfn::MockMacros::Sns' do
  describe '.response' do
    let(:uuid) { '8ca69717-1b5e-419a-a74c-1357b9208ce6' }
    before do
      allow(SecureRandom).to receive(:uuid).and_return(uuid)
    end
    context 'data is an hash' do
      context 'status is 200' do
        let(:data) do
          {
            status: 200
          }
        end
        let(:expected_response) do
          {
            '0' => {
              Return: {
                MessageId: uuid,
                SequenceNumber: 10_000_000_000_000_003_000
              }
            }
          }
        end

        it { expect(Sfn::MockMacros::Sns.response(data)).to eq(expected_response) }
      end

      context 'status is not 200' do
        let(:data) do
          {
            error: '401',
            cause: 'User not authorised'
          }
        end
        let(:expected_response) do
          {
            '0' => {
              Throw: {
                Error: '401',
                Cause: 'User not authorised'
              }
            }
          }
        end

        it { expect(Sfn::MockMacros::Sns.response(data)).to eq(expected_response) }
      end
    end

    context 'data is an array of hashes' do
      let(:data) do
        [
          {
            error: '401',
            cause: 'User not authorised'
          },
          {
            status: 200
          }
        ]
      end
      let(:expected_response) do
        {
          '0' => {
            Throw: {
              Error: '401',
              Cause: 'User not authorised'
            }
          },
          '1' => {
            Return: {
              MessageId: uuid,
              SequenceNumber: 10_000_000_000_000_003_000
            }
          }
        }
      end

      it { expect(Sfn::MockMacros::Sns.response(data)).to eq(expected_response) }
    end
  end
end
