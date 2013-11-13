# Observed::Logstash

Allows you to use the number of results returned by an Elasticsearch query as an Observed healthcheck.

Expected use case is searching server logs stored in Logstash format.

You provide an Elasticsearch query and a timespan, and the plugin will search for logs that match your query. If there are too few hits, or too many, it will record an error event.

## Example use cases

* if your web server returned more than X "500 Internal Server Error" responses in the last few minutes, it's probably unhealthy.

* if it returned fewer than Y "200 OK" responses in the last few minutes, it's probably unhealthy.

## Installation

Add this line to your application's Gemfile:

    gem 'observed-logstash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install observed-logstash

## Test

Some tests expect a Logstorage instance to be running on Localhost.

    $ git clone https://github.com/cb372/observed-logstash.git
    $ cd observed-logstash
    $ bundle install
    $ elasticsearch
    $ bundle exec rspec

## Usage

### Configuration parameters

<table>
  <tr><th>Name</th><th>Required?</th><th>Default value</th><th>Description</th></tr>
  <tr><td>host</td><td>No</td><td>`localhost:9200`</td><td>ES server hostname and port</td></tr>
  <tr><td>index_name_format</td><td>No</td><td>`logstash-%Y.%m.%d` (Logstash daily)</td><td>Naming format of ES indices</td></tr>
  <tr><td>query</td><td>Yes</td><td></td><td>A hash representing an ES query, e.g. `{ :term => { :status => 404 } }`</td></tr>
  <tr><td>timespan_in_seconds</td><td>Yes</td><td></td><td>Search for logs from the last N seconds</td></tr>
  <tr><td>max_hits</td><td>No</td><td>1000000</td><td></td></tr>
  <tr><td>min_hits</td><td>No</td><td>0</td><td></td></tr>
</table>

### Example configuration

````ruby
observe 'myapp.404', via: 'logstash', with: {
    host: 'localhost:9200',
    index_name_format: 'observed-logstash-test-%Y.%m.%d',
    query: { :term => { :status => 404 } },
    timespan_in_seconds: 3600,
    max_hits: 10
}
````

### Example reporting

````ruby
report /myapp.404/, via: 'stdout', with: {
    format: -> tag, time, data {
      case data[:status]
      when :success
        "Looks OK! #{data[:message]}"
      else
        "Oh noes! #{data[:message]}"
      end
    }
}
````
