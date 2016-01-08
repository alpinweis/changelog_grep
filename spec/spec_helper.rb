require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def parse(content)
    c = ChangelogGrep::Changelog.new(changelog: content)
    c.parse
    c
  end
end
