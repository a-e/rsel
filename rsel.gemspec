Gem::Specification.new do |s|
  s.name = "rsel"
  s.version = "0.1.2"
  s.summary = "Runs Selenium tests from FitNesse"
  s.description = <<-EOS
    Rsel provides a Slim fixture for running Selenium tests, with
    step methods written in Ruby.
  EOS
  s.authors = ["Marcus French", "Dale Straw", "Eric Pierce"]
  s.email = "epierce@automation-excellence.com"
  s.homepage = "http://github.com/a-e/rsel"
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'rubyslim-unofficial'
  s.add_dependency 'xpath', '>= 0.1.4'
  s.add_dependency 'selenium-client'

  s.add_development_dependency 'rake', '0.8.7'
  s.add_development_dependency 'sinatra' # For test webapp
  s.add_development_dependency 'mongrel'
  s.add_development_dependency 'yard' # For documentation
  s.add_development_dependency 'rdiscount' # For YARD / Markdown
  s.add_development_dependency 'rspec', '>= 2.2.0'
  s.add_development_dependency 'rcov'

  s.files = `git ls-files`.split("\n")
  # Don't include .jar files in distribution
  s.files.reject! { |f| f =~ /.jar$/ }

  s.require_path = 'lib'
end
