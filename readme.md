# Ruby SFN local

Ruby-SFN-Local is a convinient wrapper to use the local version of Step-Functions provided by AWS. It supports mocked data and make it easy to test state machines using ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'ruby-sfn-local'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-sfn-local

## Configuration

Ruby-SFN-Local needs to be configured with the following parameters:

```
Sfn.configure do |sf_config|
  sf_config.aws_command = 'aws'
  sf_config.aws_endpoint = 'http://localhost:8083'
  sf_config.definition_path = './definitions'
  sf_config.mock_file_path = './MockFile.json'
end
```
where:
`aws_command` is local aws client (v2)
`aws_endpoint` the sfn-local engine
`definition_path` is the folder where the state machine definitions are located
`mock_file_path` a writable file to store the mock data definition

## Usage

To load the library, add:
```
require 'sfn'
```

To instanciate a state machine:
```
state_machine = Sfn::StateMachine.new(definition_file_name)
```

To run a state machine:
```
execution = state_machine.run(mock_data, input)
```

The `execution` object has three properties:
```
{
    "output" => {}, # contains the output of the state machine execution if it returns with success
    "profile" => {
        "input" => [], # contains an array of state inputs (one for each exection)
        "output" => [], # contains an array of state output (one for each exection)
        "parameters" => [], # contains an array of task parameters (one for each exection)
    }
}
```
`output`: 
`profile`: contains input, output and parameters for every state

If the state machine return an error during the execution, a `Sfn::ExecutionError` exception is raised.

### Define mock data
The `mock_data` object is an hash where the key is the state name and the value is the state response. The state response can be an hash or an array of hashes. If the same state is called multiple times, the mock_data object has to include one entry for each state execution.

```
{
    "map state called twice": [
        { Return: { Payload: "First response", StatusCode: 200 } },
        { Return: { Payload: "Secondo response", StatusCode: 200 } }
    ],
    "lambda with a retry policy": [
        { Throw: { Error: "error", Cause: "State error" } },
        { Throw: { Error: "error", Cause: "State error" } },
        { Return: { Payload: "Response", StatusCode: 200 } }
    ],
    "state without a retry policy": { Return: { Payload: "Response", StatusCode: 200 } }
}
```
StepFunctionLocal doesn't check the correctness of mocked data, to facilitate users, this gems has some helpers to create the correct payload for the most common state:

```
Sfn::MockData.lambda_response(data)
Sfn::MockData.api_gateway_response(data)
Sfn::MockData.step_function_response(data)
Sfn::MockData.sns_response(data)
```
### Error
All the macros accept an hash like:
```
{
    "type": "object",
    "properties": {
        "cause": { "type": "string"},
        "error": { "type": "string" }
    },
    "required": ["cause", "error"]
}
```
to generate an error response for the state.

### Lambda
Lambda payload can be generated using an hash like:
```
{
    "type": "object",
    "properties": {
        "payload": { "type": "anyObject" }
    },
    "required": ["payload"]
}
```
### ApiGateway
ApiGateway response can be generated using an hash like:
```
{
    "type": "object",
    "properties": {
        "response": { "type": "anyObject" }
    },
    "required": ["response"]
}
```
### StepFunction
StepFunction response can be generated using an hash like:
```
{
    "type": "object",
    "properties": {
        "output": { "type": "anyObject" }
    },
    "required": ["output"]
}
```

### SNS
SNS response can be generated using an hash like:
```
{
    "type": "object",
    "properties": {
        "uuid": { "type": "string" }
        "sequence": { "type": "integer" }
    },
    "required": []
}
```

## Use in conjunction with RSpec
This library is meant primarly to unit test state machines. Be sure to include and configure the library in the `spec_helper.rb` file
```
require "rspec"
require "sfn"

RSpec.configure do |config|
  Sfn.configure do |sfn_config|
    sfn_config.aws_endpoint = ENV.fetch("AWS_ENDPOINT", nil)
    sfn_config.mock_file_path = "./tmp/MockConfigFile.json"
    sfn_config.definition_path = "./step_definitions"
  end

  config.include Sfn::MockMacros

  config.before(:suite) do
    Sfn::StateMachine.destroy_all
  end

  config.after(:suite) do
    Sfn::StateMachine.destroy_all
  end
end
```
To ensure the environment is clear after each execution, it's important to destroy all the state machine before and after the test suite.

It's good practice to test each path in the state machine using contexts. For each path the test should cover:
1. The state machine output for successful execution.
2. Exceptions raised for failure execution.
3. The pass state input/output to be sure the data are transformed properly.
4. The task state parameters to be sure the task is invoked with the right parameters.


## Versioning

Semantic versioning (http://semver.org/spec/v2.0.0.html) is used. 

For a version number MAJOR.MINOR.PATCH, unless MAJOR is 0:

1. MAJOR version is incremented when incompatible API changes are made,
2. MINOR version is incremented when functionality is added in a backwards-compatible manner, 
3. PATCH version is incremented when backwards-compatible bug fixes are made.

Major version "zero" (0.y.z) is for initial development. Anything may change at any time. 
The public API should not be considered stable. 

## Dependencies

TODO: List gem dependencies here

## Contributing

1. Fork it ( https://github.com/redvex/ruby-step-function-local/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request