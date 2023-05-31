# frozen_string_literal: true
require './lib/ruby-sfn-local/version'

Gem::Specification.new do |s|
  s.name                  = 'ruby-sfn-local'
  s.version               = RubySfnLocal::VERSION
  s.required_ruby_version = '>= 2.7.0'
  s.summary               = 'Step Functions local ruby wrapper!'
  s.description           = 'A convenient gem to test step function locally'
  s.authors               = ['Gianni Mazza']
  s.email                 = 'gianni.mazza81rg@gmail.com'
  s.files                 = [
    'lib/hash.rb',
    'lib/string.rb',
    'lib/sfn.rb',
    'lib/sfn/configuration.rb',
    'lib/sfn/aws_cli.rb',
    'lib/sfn/collection.rb',
    'lib/sfn/execution_log.rb',
    'lib/sfn/execution.rb',
    'lib/sfn/mock_data.rb',
    'lib/sfn/mock_macros.rb',
    'lib/sfn/mock_macros/api_gateway.rb',
    'lib/sfn/mock_macros/lambda.rb',
    'lib/sfn/mock_macros/native_integration.rb',
    'lib/sfn/mock_macros/optimised_step_function.rb',
    'lib/sfn/mock_macros/sdk_integration.rb',
    'lib/sfn/mock_macros/secrets_manager.rb',
    'lib/sfn/mock_macros/sns.rb',
    'lib/sfn/mock_macros/sqs.rb',
    'lib/sfn/mock_macros/step_function.rb',
    'lib/sfn/state_machine.rb'
  ]
  s.add_development_dependency 'rake-release', '~> 1.3'
  s.add_development_dependency 'rspec', '~> 3.11'
  s.add_development_dependency 'rubocop', '~> 1.28'
  s.homepage =
    'https://github.com/redvex/ruby-sfn-local'
  s.license = 'MIT'
  s.metadata['rubygems_mfa_required'] = 'true'
end
