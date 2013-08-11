# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shibboleths_lil_helper/version'

Gem::Specification.new do |spec|
  spec.name          = "shibboleths_lil_helper"
  spec.version       = ShibbolethsLilHelper::VERSION
  spec.authors       = ["Joe Goggins"]
  spec.email         = ["goggins@umn.edu"]
  spec.description   = %q{See summary}
  spec.summary       = %q{A ruby gem to streamline the setup, deployment, and ongoing management of Apache & IIS web-servers running the Shibboleth Native Service Provider implementations.}
  spec.homepage      = "http://github.com/umn-asr/shibboleths_lil_helper"
  spec.license       = "Apache 2.0"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("activesupport","~> 3.2.14")
  spec.add_runtime_dependency("nokogiri", "~> 1.6.0")
  spec.add_runtime_dependency("thor", "0.18.1")
  # spec.add_runtime_dependency("i18n") # Needed?

end
