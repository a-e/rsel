Gem::Specification.new do |s|
  s.name = "RSel"
  s.version = "0.0.1"
  s.summary = "Runs Selenium tests from FitNesse"
  s.description = <<-EOS
    RSel provides a Slim fixture for running Selenium tests, with
    step methods written in Ruby.
  EOS
  s.authors = ["Marcus French", "Dale Straw", "Eric Pierce"]
  s.email = "epierce@automation-excellence.com"
  s.homepage = "http://github.com/a-e/rsel"
  s.platform = Gem::Platform::RUBY

  s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'
end