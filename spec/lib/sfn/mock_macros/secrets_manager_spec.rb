# frozen_string_literal: true

require 'spec_helper'

describe 'Sfn::MockMacros::SecretsManager' do
  describe '.response' do
    context 'data is an hash' do
      context 'status is 200' do
        let(:data) do
          {
            status: 200,
            arn: 'arn:aws:secretsmanager:us-west-2:123456789012:secret:MyTestDatabaseSecret-a1b2c3',
            created_date: 1_523_477_145,
            name: 'MyTestDatabaseSecret',
            response: "{\n  \"username\":\"david\",\n  \"password\":\"EXAMPLE-PASSWORD\"\n}\n",
            version_id: 'EXAMPLE1-90ab-cdef-fedc-ba987SECRET1'
          }
        end
        let(:expected_response) do
          {
            '0' => {
              Return: {
                ARN: 'arn:aws:secretsmanager:us-west-2:123456789012:secret:MyTestDatabaseSecret-a1b2c3',
                CreatedDate: 1_523_477_145,
                Name: 'MyTestDatabaseSecret',
                SecretString: "{\n  \"username\":\"david\",\n  \"password\":\"EXAMPLE-PASSWORD\"\n}\n",
                VersionId: 'EXAMPLE1-90ab-cdef-fedc-ba987SECRET1'
              }
            }
          }
        end

        it { expect(Sfn::MockMacros::SecretsManager.response(data)).to eq(expected_response) }
      end

      context 'status is not 200' do
        let(:data) do
          {
            error: '400',
            cause: 'DecryptionFailure'
          }
        end
        let(:expected_response) do
          {
            '0' => {
              Throw: {
                Error: '400',
                Cause: 'DecryptionFailure'
              }
            }
          }
        end

        it { expect(Sfn::MockMacros::SecretsManager.response(data)).to eq(expected_response) }
      end
    end

    context 'data is an array of hashes' do
      let(:data) do
        [
          {
            error: '400',
            cause: 'DecryptionFailure'
          },
          {
            status: 200,
            arn: 'arn:aws:secretsmanager:us-west-2:123456789012:secret:MyTestDatabaseSecret-a1b2c3',
            created_date: 1_523_477_145,
            name: 'MyTestDatabaseSecret',
            response: "{\n  \"username\":\"david\",\n  \"password\":\"EXAMPLE-PASSWORD\"\n}\n",
            version_id: 'EXAMPLE1-90ab-cdef-fedc-ba987SECRET1'
          }
        ]
      end
      let(:expected_response) do
        {
          '0' => {
            Throw: {
              Error: '400',
              Cause: 'DecryptionFailure'
            }
          },
          '1' => {
            Return: {
              ARN: 'arn:aws:secretsmanager:us-west-2:123456789012:secret:MyTestDatabaseSecret-a1b2c3',
              CreatedDate: 1_523_477_145,
              Name: 'MyTestDatabaseSecret',
              SecretString: "{\n  \"username\":\"david\",\n  \"password\":\"EXAMPLE-PASSWORD\"\n}\n",
              VersionId: 'EXAMPLE1-90ab-cdef-fedc-ba987SECRET1'
            }
          }
        }
      end

      it { expect(Sfn::MockMacros::SecretsManager.response(data)).to eq(expected_response) }
    end
  end
end
