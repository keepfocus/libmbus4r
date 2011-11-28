require "bundler/gem_tasks"

require 'rspec/core/rake_task'
require "rake/extensiontask"

def gemspec
  @clean_gemspec ||= eval(File.read(File.expand_path('../libmbus4r.gemspec', __FILE__)))
end

Rake::ExtensionTask.new("mbus", gemspec) do |ext|
end

RSpec::Core::RakeTask.new('spec')

Rake::Task[:spec].prerequisites << :compile

# If you want to make this the default task
task :default => :spec
