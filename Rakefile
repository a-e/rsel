require 'rake'

ROOT_DIR = File.expand_path(File.dirname(__FILE__))

desc "Start test webapp"
task :testapp_start do
  system(File.join(ROOT_DIR, 'test', 'app.rb'))
end

desc "Stop test webapp"
task :testapp_stop do
  Net::HTTP.get('localhost', '/shutdown', 8070)
end

