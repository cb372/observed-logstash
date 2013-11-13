Feature: Check the number of 404 errors using an Elasticsearch query

  In order to observe the number of Apache logs with status code 404 using Observed,
  I want to the observed-logstash plugin to perform an Elasticsearch query,
  check the number of search results, and report the result via reporters

  Scenario: Create a .rb file containing Observed code and run it with the ruby command
    Given a file named "test.rb" with:
    """
    require 'observed'
    require 'observed/logstash'

    include Observed

    observe 'foo_1', via: 'logstash', with: {
      host: 'localhost:9200',
      query: { :term => { :status => 404 } },
      timespan_in_seconds: 60,
      max_results: 10,
      timeout_in_milliseconds: 1000
    }

    report /foo_\d+/, via: 'stdout'

    run 'foo_1'
    """
    When I run `ruby test.rb`
    Then the output should contain:
    """
    foo_1.success
    """
