# -*- encoding: utf-8 -*-
require File.expand_path('../lib/changelog_grep/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'changelog_grep'
  spec.version       = ChangelogGrep::VERSION
  spec.summary       = 'A Ruby tool to parse and grep changelog files'
  spec.description   = 'Parse changelog files and extract entries matching various criteria'
  spec.homepage      = 'https://github.com/alpinweis/changelog_grep'

  spec.authors       = ['Adrian Kazaku']
  spec.email         = ['alpinweis@gmail.com']

  spec.required_ruby_version = '>= 1.9.3'

  spec.license       = 'Apache 2'

  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rubocop', '= 0.26.1'

  spec.add_runtime_dependency 'github-markup', '~> 1.3'
  spec.add_runtime_dependency 'redcarpet'
end
