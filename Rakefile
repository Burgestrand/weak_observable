begin
  require "bundler/gem_tasks"
rescue LoadError
end

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new
rescue LoadError
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |task|
  task.ruby_opts = '-W'
end

task :default => :spec
