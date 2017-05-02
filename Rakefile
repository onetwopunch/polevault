require "bundler/gem_tasks"
require "rake/testtask"
require "polevault"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

task :migration, [:name] do |t, args|
  prefix = Time.now.to_i
  File.open("migrations/#{prefix}_#{name}")
end
