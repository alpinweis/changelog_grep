#changelog_grep

A Ruby tool to parse and grep changelog files in order to extract entries matching various criteria.

## Installation

Add this line to your application's Gemfile:

    gem 'changelog_grep'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install changelog_grep

## Usage

### Version line matching

The changelog parser always tries to match 2 elements: version number and release date.
The regexp used for parsing is expected to have 2 match groups corresponding to these elements:
`version_match_group` (default index: 0) and `date_match_group` (default index: 1).
You can specify a different order of elements by setting the index of the respective match group.

For example:

* `### 1.8.3 - 2015-06-01` - version_match_group: 0, date_match_group: 1 (default)
* `### 2015-06-01 (1.8.3)` - version_match_group: 1, date_match_group: 0

#### Examples

```ruby
require 'changelog_grep'

str = File.read('lib/spec/fixtures/long.md')
chlog = ChangelogGrep::Changelog.new(changelog: str)
chlog.parse
rel_vers1 = chlog.find_all(from_date: '2015-10-01')
rel_vers2 = chlog.find_all(from_version: '1.0.0')
rel_vers3 = chlog.find_all(from_version: '1.0.0', to_date: '2015-10-01')


require 'open-uri'
str = open('https://raw.githubusercontent.com/erikhuda/thor/master/CHANGELOG.md').read
regex = Regexp.new('^#{0,3} (\d+\.\d+(?:\.\d+)?), released? (\d{4}-\d{2}-\d{2})\n?')
chlog = ChangelogGrep::Changelog.new(changelog: str, version_header_exp: regex)
chlog.parse
chlog.to_hash_html
```

#### Changelog conventions

* it must be in plain text format (github-flavored or plain markdown preferred)
* it must follow the format (recommended):

```
LEVEL 1-3 HEADER WITH VERSION AND RELEASE DATE
VERSION CHANGES

LEVEL 1-3 HEADER WITH VERSION AND RELEASE DATE
VERSION CHANGES
[...]
```

Example in Markdown:

```markdown
### [1.2.3] - 2015-12-12
* Fix bug #2

### [1.2.2] - 2015-10-11
* Update API
* Fix bug #1
```

+ `LEVEL 1-3 HEADER WITH VERSION` must contain at least the version number
+ If the release date is present, it must follow the form `<version_number> - <release_date>`
+ `<release_date>` is optional but if present it must follow one of these formats:
 + the ISO 8601 format: `'YYYY-MM-DD'`
 + the full english style format: `'December 14th, 2015'` (the ordinal suffix is optional)
 + the text `'Unreleased'`
+ `VERSION CHANGES` may contain more levels, but must follow the markup syntax
+ `<version_number>` should follow the [semver](http://semver.org/) conventions
+ `<version_number>` must contain at least one dot (ex: '1.2')

### Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
