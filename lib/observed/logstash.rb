require 'observed/logstash/version'
require 'observed/observer'
require 'observed/observer_helpers/timer'
require 'elasticsearch'

module Observed
  module Plugins
    class Logstash < Observed::Observer

      include Observed::ObserverHelpers::Timer

      attribute :host, default: 'localhost:9200'
      attribute :index_name_format, default: 'logstash-%Y.%d.$m'
      attribute :query
      attribute :timespan_in_seconds
      attribute :max_results
      attribute :min_results

      def build_timestamp_filter
        {
          :range => {
            :@timestamp => {
              :from => (Time.now.to_f * 1000).to_i - timespan_in_seconds,
              :to => (Time.now.to_f * 1000).to_i
            }
          }
        }
      end

      def build_body
        {
          :query => query,
          :filter => build_timestamp_filter
        }
      end

      def observe
        logger.debug "Host: #{host}, index name format: #{index_name_format}, query: [#{query}], timespan: #{timespan_in_seconds}s, max results: #{max_results}, min results: #{min_results}"

        index = Time.now.strftime(index_name_format)
        body = build_body

        logger.debug "Index: #{index}, Body: #{body}"

        client = Elasticsearch::Client.new host: host

        response = client.search :index => index,
                                 :body => body

        logger.debug "Response: #{response}"
        
        system.report(self.tag, :success)
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      plugin_name 'logstash'

    end
  end
end
