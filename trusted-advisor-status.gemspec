require 'rake'

Gem::Specification.new do |s|
  s.name          = 'trusted-advisor-status'
  s.version       = '0.0.0'
  s.bindir        = 'bin'
  s.executables   = %w(trusted-advisor-status)
  s.authors       = %w(someguy)
  s.summary       = ''
  s.description   = 'Some scripting around the AWS Trusted Advisor interface for convenience in calling from pipeline'
  s.files         = FileList[ 'lib/**/*.rb' ]

  s.require_paths << 'lib'

  s.homepage      = 'https://github.com/stelligent/trusted-advisor-status'
  s.required_ruby_version = '>= 2.1.0'

  s.add_runtime_dependency('aws-sdk', '2.2.17')
  s.add_runtime_dependency('trollop', '2.1.2')
end