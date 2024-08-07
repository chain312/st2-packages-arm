require 'spec_helper'

module LogHelpers
  # Get package name of particular st2 service
  def package_name(svc_name)
    found = spec[:package_has_services].find do |(_, list)|
      list.include? svc_name
    end
    found ? found.first : svc_name
  end

  # Get config path of st2 service
  def config_path(svc_name)
    # strip st2 prefix
    noprefix_name = svc_name.sub(/^st2/, '')
    config_name = ['logging', noprefix_name, 'conf'].compact.join('.')
    File.join([spec[:conf_dir], config_name])
  end

  # Get log destination regex list
  def dest_re_list(svc_name)
    pattern = spec[:logdest_pattern][svc_name] || svc_name
    [
      /#{File.join(spec[:log_dir], pattern)}.log/,
      /#{File.join(spec[:log_dir], pattern)}.audit.log/
    ]
  end
end

# Checking log configuration file if it has the correct output destination
#
describe 'logs configuration' do
  extend LogHelpers

  spec[:st2_services].each do |svc_name|
    # Don't test logging configuration for a service if its package is not installed
    next unless spec[:package_list].include?(package_name(svc_name))

    describe file(config_path(svc_name)) do
      let(:content) { described_class.content }
      re_list = dest_re_list(svc_name)

      it { is_expected.to be_file }
      it "should match #{re_list.map(&:inspect).join(', ')}" do
        re_list.each { |re| expect(content.match(re)).not_to be_nil }
      end
    end
  end
end
