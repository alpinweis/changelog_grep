require 'changelog_grep'

module ChangelogGrep
  describe Changelog do

    context 'version line with default regex' do
      let(:version_hash) { { version: '1.2.3', date: '2015-12-31', content: '' } }
      let(:version_lines) do
        [
          '# 1.2.3 - 2015-12-31',
          '## v1.2.3 - 2015-12-31',
          '## [1.2.3] - 2015-12-31',
          '### [1.2.3] / 2015-12-31',
          '### [1.2.3]  /  2015-12-31',
          '### [1.2.3](https://github.com/project/compare/v1.2.2...v1.2.3) - 2015-12-31'
        ]
      end

      it 'parses version number and date' do
        version_lines.each do |line|
          vers = parse(line).versions
          expect(vers.size).to eq(1)
          expect(vers.first.to_hash).to eq(version_hash)
        end
      end
    end

    context 'content' do
      let(:chlog) { parse(File.read('spec/fixtures/base.md')) }

      let(:versions_text) do
        [
          {
            version: '1.8.3',
            date:    '2015-06-01',
            content: '* Fix potential memory leak'
          },
          {
            version: '1.8.2',
            date:    '2015-01-08',
            content: "* Some performance improvements\n* Fix to avoid mutation of JSON.dump_default_options"
          }
        ]
      end

      let(:versions_html) do
        [
          {
            version: '1.8.3',
            date:    '2015-06-01',
            content: "<ul>\n<li>Fix potential memory leak</li>\n</ul>\n"
          },
          {
            version: '1.8.2',
            date:    '2015-01-08',
            content: "<ul>\n<li>Some performance improvements</li>\n<li>Fix to avoid mutation of JSON.dump<em>default</em>options</li>\n</ul>\n"
          }
        ]
      end

      it 'presents parsed content as plain text' do
        expect(chlog.to_hash).to eq(versions: versions_text)
      end

      it 'presents parsed content as html' do
        expect(chlog.to_hash_html).to eq(versions: versions_html)
      end
    end

    context 'find_all' do
      let(:chlog)   { parse(File.read('spec/fixtures/changelog.md')) }
      let(:expected_vers)   { ['2.12.0', '2.11.1', '2.11.0'] }
      let(:expected_vers_2) { ['2.1.2', '2.1.1'] }

      it 'finds all versions from_date' do
        vers = chlog.find_all(from_date: '2015-12-01')
        expect(chlog.all_versions(vers)).to eq(expected_vers)
      end

      it 'finds all versions from_verison' do
        vers = chlog.find_all(from_version: '2.11.0')
        expect(chlog.all_versions(vers)).to eq(expected_vers)
      end

      it 'finds all versions to_date' do
        vers = chlog.find_all(to_date: '2015-06-30')
        expect(chlog.all_versions(vers)).to eq(expected_vers_2)
      end

      it 'finds all versions to_version' do
        vers = chlog.find_all(to_version: '0.0.5')
        expect(chlog.all_versions(vers)).to eq(['0.0.4', '0.0.3', '0.0.2', '0.0.1'])
      end

      it 'finds all versions from_date to_date' do
        vers = chlog.find_all(from_date: '2015-12-01', to_date: '2015-12-30')
        expect(chlog.all_versions(vers)).to eq(expected_vers)
      end

      it 'finds all versions from_verison to_version' do
        ['2.12.0', '2.12.1', '2.13.0', '3.0.0'].each do |to_version|
          vers = chlog.find_all(from_version: '2.11.0', to_version: to_version)
          expect(chlog.all_versions(vers)).to eq(expected_vers)
        end
      end

      it 'finds all versions from_date to_version' do
        ['2.12.0', '2.12.1', '2.13.0', '3.0.0'].each do |to_version|
          vers = chlog.find_all(from_date: '2015-12-01', to_version: to_version)
          expect(chlog.all_versions(vers)).to eq(expected_vers)
        end
      end

      it 'finds all versions from_version to_date' do
        ['1.0.0', '2.0.0', '2.0.2', '2.1.1'].each do |from_version|
          vers = chlog.find_all(from_version: from_version, to_date: '2015-07-01')
          expect(chlog.all_versions(vers)).to eq(expected_vers_2)
        end
      end

      it 'finds nothing when using invalid search options' do
        [
          { from_date: '2015-12-31' },
          { to_date: '2015-01-01' },
          { from_version: '3.0.0' },
          { to_version: '0.0.0' },
          { from_date: '2015-12-31', to_date: '2015-10-01' },
          { from_version: '2.12.0', to_version: '2.0.0' },
          { from_date: '2015-07-17', to_version: '1.0.0' },
          { from_version: '2.12.0', to_date: '2015-10-01' }
        ].each do |opts|
          vers = chlog.find_all(opts)
          expect(chlog.all_versions(vers)).to be_empty
        end
      end
    end

  end
end
