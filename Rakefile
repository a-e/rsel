require 'rake'
require 'net/http'
require 'selenium/rake/tasks'

ROOT_DIR = File.expand_path(File.dirname(__FILE__))
TEST_APP = File.join(ROOT_DIR, 'test', 'app.rb')
SELENIUM_RC_JAR = File.join(ROOT_DIR, 'test', 'server', 'selenium-server-1.0.3-SNAPSHOT-standalone.jar')

namespace 'testapp' do
  desc "Start the test webapp in the background"
  task :start do
    puts "Starting the test webapp: #{TEST_APP}"
    system("ruby #{TEST_APP} &")
  end

  desc "Stop the test webapp"
  task :stop do
    puts "Stopping the test webapp"
    Net::HTTP.get('localhost', '/shutdown', 8070)
  end
end

Selenium::Rake::RemoteControlStartTask.new do |rc|
  rc.jar_file = SELENIUM_RC_JAR
  rc.port = 4444
  rc.background = true
  rc.timeout_in_seconds = 60
  rc.wait_until_up_and_running = true
end

Selenium::Rake::RemoteControlStopTask.new do |rc|
  rc.host = 'localhost'
  rc.port = 4444
  rc.timeout_in_seconds = 60
  rc.wait_until_stopped = true
end

