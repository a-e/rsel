require 'rake'
require 'net/http'
require 'selenium/rake/tasks'
require 'rspec/core/rake_task'

ROOT_DIR = File.expand_path(File.dirname(__FILE__))
TEST_APP = File.join(ROOT_DIR, 'test', 'app.rb')
SELENIUM_JAR = 'selenium-server-standalone-2.20.0.jar'
SELENIUM_DOWNLOAD_URL = 'http://selenium.googlecode.com/files/' + SELENIUM_JAR
SELENIUM_JAR_PATH = File.join(ROOT_DIR, 'test', 'server', SELENIUM_JAR)
SELENIUM_LOG_PATH = File.join(ROOT_DIR, 'selenium-rc.log')

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

namespace 'selenium' do
  desc "Download the official selenium-server jar file"
  task :download do
    if File.exist?(SELENIUM_JAR_PATH)
      puts "#{SELENIUM_JAR_PATH} already exists. Skipping download."
    else
      puts "Downloading #{SELENIUM_JAR_PATH} (this may take a minute)..."
      system("wget #{SELENIUM_DOWNLOAD_URL} --output-document=#{SELENIUM_JAR_PATH}")
    end
  end
end

Selenium::Rake::RemoteControlStartTask.new do |rc|
  rc.jar_file = SELENIUM_JAR_PATH
  rc.port = 4444
  rc.background = true
  rc.timeout_in_seconds = 60
  rc.wait_until_up_and_running = true
  rc.log_to = SELENIUM_LOG_PATH
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

namespace 'rcov' do
  desc "Run support spec tests with coverage analysis"
  RSpec::Core::RakeTask.new(:support) do |t|
    t.pattern = 'spec/support_spec.rb'
    t.rspec_opts = ['--color', '--format doc']
    t.rcov = true
    t.rcov_opts = [
      '--exclude /.gem/,/gems/,spec',
      '--include-file lib/**/*.rb',
    ]
  end

  desc "Run all spec tests with coverage analysis"
  RSpec::Core::RakeTask.new(:all) do |t|
    t.pattern = 'spec/**/*.rb'
    t.rspec_opts = ['--color', '--format doc']
    t.rcov = true
    t.rcov_opts = [
      '--exclude /.gem/,/gems/,spec',
      '--include-file lib/**/*.rb',
      # Ensure the main .rb file gets included
      '--include-file lib/rsel/selenium_test.rb',
    ]
  end
end

namespace 'servers' do
  desc "Start the Selenium and testapp servers"
  task :start do
    Rake::Task['selenium:download'].invoke
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

