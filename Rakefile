begin
  require "bundler/gem_tasks"
rescue LoadError
end

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :default => :spec
