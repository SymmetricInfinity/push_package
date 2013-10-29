require "rake/testtask"
require "bundler/gem_tasks"

task default: :test

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'spec'
  t.test_files = Dir["spec/**/*_spec.rb"]
  t.verbose = true
end

