require 'observed/logstash/version'
require 'observed/observer'
require 'observed/observer_helpers/timer'
require 'elasticsearch'

module Observed
  module Plugins
    class Logstash < Observed::Observer

      attribute :host, default: 'localhost:9200'
      attribute :index_name_format, default: 'logstash-%Y.%m.%d'
      attribute :query
      attribute :timespan_in_seconds
      attribute :max_hits, default: 1000000
      attribute :min_hits, default: 0

      def build_client
        Elasticsearch::Client.new host: host
      end

      def build_timestamp_filter
        {
          :range => {
            :@timestamp => {
              :from => (system.now.to_f * 1000).to_i - (1000 * timespan_in_seconds),
              :to => (system.now.to_f * 1000).to_i
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

      def build_data(hits)
        data = { hits: hits, min_hits: min_hits, max_hits: max_hits }
        if hits < min_hits
          data[:status] = :error
          data[:message] = "Not enough hits. Only #{hits} in the last #{timespan_in_seconds} seconds, required at least #{min_hits}" 
        elsif hits > max_hits
          data[:status] = :error
          data[:message] = "Too many hits. Got #{hits} in the last #{timespan_in_seconds} seconds, required at most #{max_hits}" 
        else
          data[:status] = :success
          data[:message] = "#{hits} hits in the last #{timespan_in_seconds} seconds" 
        end

        data
      end

      def observe
        logger.debug "Host: #{host}, index name format: #{index_name_format}, query: [#{query}], timespan: #{timespan_in_seconds}s, max hits: #{max_hits}, min hits: #{min_hits}"

        index = system.now.strftime(index_name_format)
        body = build_body

        logger.debug "Index: #{index}, Body: #{body}"

        client = build_client
        response = client.search :index => index,
                                 :body => body
        hits = response['hits']['total'].to_i
        logger.debug("Hits: #{hits}")

        data = build_data(hits)
        system.report("#{self.tag}.#{data[:status]}", data)
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      plugin_name 'logstash'

    end
  end
end
