require 'rspec'
require 'rsel'
require 'selenium/client'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test', 'app'))

# FIXME: Some complications to solve when self-testing rsel:
#
# - A selenium server needs to be running, which could mean a 19MB .jar file
#   dumped in the repository just for self-testing (a gratuitous waste of space)
# - Sinatra app needs to run on localhost:PORT, or someplace where Selenium can
#   see it; or, Selenium needs to be able to test on plain /relative/path URLs
#
RSpec.configure do |config|
  config.include Rsel

  # Create a Selenium Driver instance to use for each test
  config.prepend_before(:each) do
    @browser = Selenium::Client::Driver.new \
      :host => 'localhost',
      :port => 4444,
      :browser => '*firefox',
      :timeout_in_seconds => 10,
      :url => 'http://localhost:4567'
  end
end

