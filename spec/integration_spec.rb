require 'spec_helper'

require 'observed/application/oneshot'
require 'elasticsearch'

describe Observed::Application::Oneshot do
  subject {
    Observed::Application::Oneshot.create(
        config_file: 'spec/fixtures/observed.conf'
    )
  }

  let(:index_name) {
    Time.now.strftime('observed-logstash-test-%Y.%m.%d')
  }

  let(:client) {
    Elasticsearch::Client.new
  }

  before do
    client.indices.create :index => index_name
  end

  it 'initializes' do
    expect(subject.run.size).not_to eq(0)
  end

  after do
    client.indices.delete :index => index_name
  end

end
