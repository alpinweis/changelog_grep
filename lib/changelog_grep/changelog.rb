require_relative 'release_ver'

module ChangelogGrep
  class Changelog

    # changelog version header regex for matching strings like:
    #   '## 1.2.3 - 2015-12-31'
    #   '### [1.2.4] - 2015-12-31'
    #   '### [1.2.5](https://github.com/project/compare/v1.2.4...v1.2.5) - 2015-12-31'
    # regex match groups: 0 => version number, 1 => release date
    VERSION_HEADER = Regexp.new('^#{0,3} ?\[?([\w\d\.-]+\.[\w\d\.-]+[a-zA-Z0-9])\]?(?:\(\S*\))?(?: +\W +(\w+ \d{1,2}(?:st|nd|rd|th)?,\s\d{4}|\d{4}-\d{2}-\d{2}|\w+))?\n?[=-]*')

    attr_accessor :changelog, :version_header_exp, :versions, :last_found_versions

    # @param options [Hash] changelog parser options
    # @option options [String] :changelog Full raw content of the changelog as a String
    # @option options [Fixnum] :date_match_group Number of the regexp match group to use for date matching
    # @option options [Fixnum] :version_match_group Number of the regexp match group to use for version matching
    # @option options [String] :version_header_exp Regexp to match the versions lines in changelog
    def initialize(options = {})
      @changelog           = options.fetch(:changelog)
      regexp               = options[:version_header_exp] || VERSION_HEADER
      @version_header_exp  = regexp.is_a?(Regexp) ? regexp : Regexp.new(/#{regexp}/)
      @version_match_group = options[:version_match_group] || 0
      @date_match_group    = options[:date_match_group] || 1
      @versions            = []
      @last_found_versions = []
    end

    # parse a changelog file content
    # @return [Array<ReleaseVersion>]
    # rubocop:disable SpecialGlobalVars
    def parse
      @changelog.scan(@version_header_exp) do |match|
        version_content = $~.post_match # $LAST_MATCH_INFO
        scanner = StringScanner.new(version_content)
        scanner.scan_until(@version_header_exp)
        version, date = match.values_at(@version_match_group, @date_match_group)
        version.sub!(/^\D*/, '') # remove alpha prefix, e.g 'v1.2.3' => '1.2.3'
        content = (scanner.pre_match || version_content).gsub(/(\A\n+|\n+\z)/, '')
        @versions << ReleaseVersion.new(version: version, date: date, content: content)
      end
      @versions
    end

    # get all dates
    def all_dates(arr_versions = versions)
      arr_versions.map(&:date).compact.sort
    end

    # get all version numbers as strings
    def all_versions(arr_versions = versions)
      arr_versions.map(&:version).compact
    end

    def to_hash(arr_versions = versions)
      { versions: arr_versions.map(&:to_hash) }
    end

    def to_hash_html(arr_versions = versions)
      { versions: arr_versions.map(&:to_hash_html) }
    end

    # find all versions by date or version number
    #
    # @param options [Hash] filter options
    # @option options [String] :from_date ('YYYY-MM-DD')
    # @option options [String] :to_date
    # @option options [String] :from_version ('1.2.3')
    # @option options [String] :to_version
    def find_all(options = {})
      parse if versions.empty?
      return versions if options.empty?
      # symbolize options keys
      options = Hash[options.map { |k, v| [k.to_sym, v] }]

      from_date, to_date, from_version, to_version = options.values_at(:from_date, :to_date, :from_version, :to_version)
      sorted = versions.sort
      dates = all_dates
      vers1 = vers2 = versions

      if (from_version || to_version) && !versions.empty?
        min = from_version ? ReleaseVersion.new(version: from_version) : sorted.first
        max = to_version   ? ReleaseVersion.new(version: to_version)   : sorted.last
        vers1 = versions.select { |v| v.between?(min, max) }
      end

      if from_date || to_date
        if dates.empty?
          vers2 = []
        else
          min = from_date ? from_date : dates.first
          max = to_date ? to_date : dates.last
          vdates = dates.select { |date| date.between?(min, max) }
          if vdates.empty?
            vers2 = []
          else
            # grab all versions with no dates that may be found in between
            min = versions.find { |v| v.date == vdates.first }
            max = versions.find { |v| v.date == vdates.last }
            vers2 = versions.select { |v| v.between?(min, max) }
          end
        end
      end

      @last_found_versions = vers1 & vers2
    end
  end
end
