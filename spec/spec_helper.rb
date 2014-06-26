# This file includes RSpec configuration that is needed for all spec testing.

require 'rspec'
require 'rsel'
require 'selenium/client'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test', 'app'))

RSpec.configure do |config|
  config.include Rsel
  config.include Rsel::Support
end
