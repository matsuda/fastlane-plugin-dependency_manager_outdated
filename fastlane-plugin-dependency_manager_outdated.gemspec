# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/dependency_manager_outdated/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-dependency_manager_outdated'
  spec.version       = Fastlane::DependencyManagerOutdated::VERSION
  spec.author        = 'matsuda'
  spec.email         = 'kosukematsuda@gmail.com'

  spec.summary       = 'Fastlane plugin to check project\'s outdated dependencies'
  spec.homepage      = "https://github.com/matsuda/fastlane-plugin-dependency_manager_outdated"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'slack-notifier'

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.117.1')
end
