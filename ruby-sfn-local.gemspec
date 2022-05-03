Gem::Specification.new do |s|
  s.name        = 'ruby-sfn-local'
  s.version     = '0.1.0'
  s.summary     = "Step Functions local ruby wrapper!"
  s.description = "A convenient gem to test step function locally"
  s.authors     = ["Gianni Mazza"]
  s.email       = 'gianni.mazza81rg@gmail.com'
  s.files       = [
    "lib/string.rb",
    "lib/sfn.rb",
    "lib/sfn/configuration.rb",
    "lib/sfn/aws_cli.rb",
    "lib/sfn/collection.rb",
    "lib/sfn/execution_log.rb",
    "lib/sfn/execution.rb",
    "lib/sfn/mock_data.rb",
    "lib/sfn/mock_macros.rb",
    "lib/sfn/mock_macros/api_gateway.rb",
    "lib/sfn/mock_macros/lambda.rb",
    "lib/sfn/mock_macros/sns.rb",
    "lib/sfn/mock_macros/step_function.rb",
    "lib/sfn/state_machine.rb"
  ]
  s.add_development_dependency 'rubocop', '~> 1.28'
  s.add_development_dependency 'rspec', '~> 3.11'
  s.homepage    =
    'https://github.com/redvex/ruby-sfn-local'
  s.license       = 'MIT'
end