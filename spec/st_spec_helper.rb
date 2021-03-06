# This file includes RSpec configuration that is only needed when testing the
# SeleniumTest class. Include this file in your spec test if you need to use
# a SeleniumTest browser session (@st).

require 'spec/spec_helper'

RSpec.configure do |config|
  config.before(:suite) do
    # For some reason, RSpec runs this twice; work around possible duplicate
    # browser windows by only intializing @@st if it hasn't been already
    @@st ||= Rsel::SeleniumTest.new('http://localhost:8070')
    @@st.open_browser
  end

  config.after(:suite) do
    @@st.close_browser('without showing errors')
  end

  config.before(:all) do
    @st = @@st
  end
end

# Monkeypatch the Selenium::Client::Protocol module,
# to prevent http_post from spewing out a bunch of `puts`es on failure.
# (It's really distracting when running spec tests)
module Selenium
  module Client
    module Protocol
      def http_post(data)
        start = Time.now
        called_from = caller.detect{|line| line !~ /(selenium-client|vendor|usr\/lib\/ruby|\(eval\))/i}
        http = Net::HTTP.new(@host, @port)
        http.open_timeout = default_timeout_in_seconds
        http.read_timeout = default_timeout_in_seconds
        response = http.post('/selenium-server/driver/', data, HTTP_HEADERS)
        # <-- Here is where all the puts statements were -->
        [ response.body[0..1], response.body ]
      end
    end
  end
end

