require 'github/markup'

module ChangelogGrep
  class ReleaseVersion
    include Comparable
    attr_accessor :content, :date, :number, :version

    # @param options [Hash] init options
    # @option options [String] :version Version string ('0.1.0')
    # @option options [String] :date Date of release ('YYYY-MM-DD')
    # @option options [String] :content Content of release notes
    def initialize(options = {})
      @version = options[:version] || '0.0.0'
      @content = options[:content]
      @date    = options[:date]
      @number  = numeric_version(@version)
    end

    # convert a version string to a numeric version (for correct sorting)
    # @see http://ruby-doc.org/stdlib-2.0.0/libdoc/rubygems/rdoc/Gem/Version.html
    def numeric_version(version_str)
      Gem::Version.new(version_str)
    end

    def <=>(other)
      number <=> other.number
    end

    def to_html
      GitHub::Markup.render('.md', content || '')
    end

    def to_hash
      { version: version, date: date, content: content }
    end

    def to_hash_html
      to_hash.merge(content: to_html)
    end
  end
end
