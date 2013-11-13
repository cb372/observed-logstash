require 'spec_helper'

require 'observed/logstash'
require 'elasticsearch'

describe Observed::Plugins::Logstash do

  subject {
    Observed::Plugins::Logstash.new
  }

  before {
    subject.configure config
  }

  let(:config) {
    {
        host: 'localhost:9200',
        index_name_format: 'apache_myapp-%Y.%m.%d',
        query: { :term => { :status => 404 } },
        timespan_in_seconds: 3600,
        min_hits: 5,
        max_hits: 10,
        tag: 'foo',
        system: sys
    }
  }

  let(:sys) {
    sys = mock('system')
    sys.stubs(:now).returns(now)
    sys
  }

  let(:now) {
    Time.at(1384333117)
  }

  let(:now_millis) {
    now.to_i * 1000
  }

  let(:one_hour_ago_millis) {
    now_millis - (3600 * 1000)
  }

  let(:client) {
    mock('client')
  }

  context 'when not enough hits' do
    before {
      client.stubs(:search).returns({ "hits" => { "total" => 4 } })
      subject.stubs(:build_client).returns(client)

      sys.expects(:report).with('foo.error', {
        hits: 4,
        min_hits: 5,
        max_hits: 10,
        status: :error, 
        message: 'Not enough hits. Only 4 in the last 3600 seconds, required at least 5'
      })
    }

    it 'reports an error' do
      expect { subject.observe }.to_not raise_error
    end
  end

  context 'when too many hits' do
    before {
      client.stubs(:search).returns({ "hits" => { "total" => 11 } })
      subject.stubs(:build_client).returns(client)

      sys.expects(:report).with('foo.error', {
        hits: 11,
        min_hits: 5,
        max_hits: 10,
        status: :error, 
        message: 'Too many hits. Got 11 in the last 3600 seconds, required at most 10'
      })
    }

    it 'reports an error' do
      expect { subject.observe }.to_not raise_error
    end
  end

  context 'when not too many or too few hits' do
    before {
      client.stubs(:search).returns({ "hits" => { "total" => 10 } })
      subject.stubs(:build_client).returns(client)

      sys.expects(:report).with('foo.success', {
        hits: 10,
        min_hits: 5,
        max_hits: 10,
        status: :success, 
        message: '10 hits in the last 3600 seconds'
      })
    }

    it 'reports success' do
      expect { subject.observe }.to_not raise_error
    end
  end

  context 'when searching' do
    before {
      client.stubs(:search).returns({ "hits" => { "total" => 10 } })
      subject.stubs(:build_client).returns(client)
    }

    it 'searches the correct index and constructs query correctly' do
      expect { client.search :index => 'apache_myapp-2013.11.13',
                             :body => {
                               :query => { :term => { :status => 404 } },
                               :filter => { @timestamp => {
                                 :from => one_hour_ago_millis,
                                 :to => now_millis
                                }
                               }
                             }
      }
    end
  end


end
