# frozen_string_literal: true

module Sfn
  class ExecutionError < RuntimeError
    attr_accessor :code, :events

    def initialize(msg, code, events)
      self.code = code
      self.events = JSON.parse(events)
      super(msg)
    end
  end

  class ExecutionLog
    attr_accessor :event

    EVENTS = %w[stateEnteredEventDetails stateExitedEventDetails executionSucceededEventDetails
                executionFailedEventDetails taskScheduledEventDetails].freeze

    def self.parse(execution_arn)
      profile = {}
      root_state_name = {}
      output = nil
      error = nil
      state_name = nil
      events_json = AwsCli.run('stepfunctions', 'get-execution-history',
                               { 'execution-arn': execution_arn.to_s, query: "'events[?#{EVENTS.join(' || ')}]'" })
      JSON.parse(events_json).each do |event|
        parsed_event = new(event)
        output ||= parsed_event.output
        error  ||= parsed_event.error(events_json)
        state_name = parsed_event.state_name

        unless state_name.nil?
          profile[state_name] ||= { 'input' => [], 'output' => [], 'parameters' => [] }
          profile[state_name]['input'] << parsed_event.profile['input'] unless parsed_event.profile['input'].nil?
          profile[state_name]['output'] << parsed_event.profile['output'] unless parsed_event.profile['output'].nil?
          root_state_name[parsed_event.event['id']] = state_name
        end

        if !root_state_name[parsed_event.event['previousEventId']].nil? && !parsed_event.profile['parameters'].nil?
          profile[root_state_name[parsed_event.event['previousEventId']]]['parameters'] << parsed_event.profile['parameters']
        end
      end
      [output, profile]
    end

    def initialize(event)
      self.event = event
    end

    def state_name
      event.dig('stateEnteredEventDetails', 'name') || event.dig('stateExitedEventDetails', 'name')
    end

    def output
      try_parse(event.dig('executionSucceededEventDetails', 'output'))
    end

    def error(events_json = '{}')
      return if event['executionFailedEventDetails'].nil?

      raise ExecutionError.new(event['executionFailedEventDetails']['cause'],
                               event['executionFailedEventDetails']['error'],
                               events_json)
    end

    def profile
      {
        'input' => try_parse(event.dig('stateEnteredEventDetails', 'input')),
        'output' => try_parse(event.dig('stateExitedEventDetails', 'output')),
        'parameters' => try_parse(event.dig('taskScheduledEventDetails', 'parameters'))
      }.compact
    end

    private

    def try_parse(json_string)
      JSON.parse(json_string)
    rescue StandardError
      nil
    end
  end
end
