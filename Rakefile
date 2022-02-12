# frozen_string_literal: true

require 'rake/midi-smtp-server-testtask'

desc 'Run all the Rubocop rules on source files'
task :rubocop do
  sh('rubocop lib/ test/ examples/ cookbook/ Rakefile')
end

# ALL FOR TESTING
namespace :test do
  # prepare test tasks

  # drop all from before our test:name from ARGV
  until ARGV.empty?
    found = ARGV[0].match?(/^test:/)
    ARGV.delete_at(0)
    break if found
  end

  # setup TESTOPTS from given parameters
  testopts = +''
  until ARGV.empty?
    testopts << ' -v' if ARGV[0].match?(/^v=(1|y|yes|t|true)$/i)
    testopts << ' --name="/' << ARGV[0][2..] << '/"' if ARGV[0].match?(/^T=.+$/i)
    ARGV.delete_at(0)
  end
  ENV['TESTOPTS'] = testopts

  # template to describe the test tasks
  desc_template = 'Run %s tests, [V=1|y] verbose output, [T=FilterTests] regex method names to test'

  Rake::MidiSmtpServerTestTask.new(:all) do |t|
    t.desc = format(desc_template, t.name)
    t.add_test_files(['specs', 'unit', 'integration', 'stress'])
  end

  Rake::MidiSmtpServerTestTask.new(:specs) do |t|
    t.desc = format(desc_template, t.name)
    t.add_test_files('specs')
  end

  Rake::MidiSmtpServerTestTask.new(:unit) do |t|
    t.desc = format(desc_template, t.name)
    t.add_test_files('unit')
  end

  Rake::MidiSmtpServerTestTask.new(:integration) do |t|
    t.desc = format(desc_template, t.name)
    t.add_test_files('integration')
  end

  Rake::MidiSmtpServerTestTask.new(:stress) do |t|
    t.desc = format(desc_template, t.name)
    t.add_test_files('stress')
  end
end
