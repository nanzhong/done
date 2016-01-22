lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'done/version'

Gem::Specification.new do |s|
  s.name        = 'done'
  s.version     = Done::VERSION
  s.date        = '2016-01-20'
  s.summary     = 'A cli tool for managing, logging, and sharing what you have done.'
  s.authors     = ['Nan Zhong']
  s.email       = 'nan@nine27.com'
  s.files       = `git ls-files -z`.split("\x0")
  s.homepage    = 'https://done.sh'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec', '~> 3.4.0'
end
