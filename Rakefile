require 'rake'
require 'net/http'
require 'selenium/rake/tasks'
require 'rspec/core/rake_task'

ROOT_DIR = File.expand_path(File.dirname(__FILE__))
TEST_APP = File.join(ROOT_DIR, 'test', 'app.rb')
#SELENIUM_RC_JAR = File.join(ROOT_DIR, 'test', 'server', 'selenium-server-1.0.3-SNAPSHOT-standalone.jar')
SELENIUM_RC_JAR = File.join(ROOT_DIR, 'test', 'server', 'selenium-server-standalone-2.3.0.jar')
SELENIUM_RC_LOG = File.join(ROOT_DIR, 'selenium-rc.log')

namespace 'testapp' do
  desc "Start the test webapp in the background"
  task :start do
    puts "Starting the test webapp: #{TEST_APP}"
    system("ruby #{TEST_APP} &")
  end

  desc "Stop the test webapp"
  task :stop do
    puts "Stopping the test webapp"
    begin
      Net::HTTP.get('localhost', '/shutdown', 8070)
    rescue EOFError
      # This is expected
      puts "Test webapp stopped."
    end
  end
end

Selenium::Rake::RemoteControlStartTask.new do |rc|
  rc.jar_file = SELENIUM_RC_JAR
  rc.port = 4444
  rc.background = true
  rc.timeout_in_seconds = 60
  rc.wait_until_up_and_running = true
  rc.log_to = SELENIUM_RC_LOG
end

Selenium::Rake::RemoteControlStopTask.new do |rc|
  rc.host = 'localhost'
  rc.port = 4444
  rc.timeout_in_seconds = 60
  rc.wait_until_stopped = true
end

desc "Run spec tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = ['--color', '--format doc']
end

namespace 'servers' do
  desc "Start the Selenium and testapp servers"
  task :start do
    Rake::Task['testapp:start'].invoke
    Rake::Task['selenium:rc:start'].invoke
  end

  desc "Stop the Selenium and testapp servers"
  task :stop do
    Rake::Task['selenium:rc:stop'].invoke
    Rake::Task['testapp:stop'].invoke
  end
end

desc "Start Selenium and testapp servers, run tests, then stop servers"
task :test do
  begin
    Rake::Task['servers:start'].invoke
    Rake::Task['spec'].invoke
  ensure
    Rake::Task['servers:stop'].invoke
  end
end

