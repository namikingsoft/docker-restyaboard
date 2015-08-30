require 'rake'
require 'parallel'
require 'rspec/core/rake_task'

task :spec => 'spec:all'
task :provision => 'provision:all'
task :default => [:provision, :spec]
task :test do
  `vagrant ssh-config`.scan /^Host (\w+)/ do |result|
    host = result[0]
    node = host
    node = 'default' unless File.exist? "provision/nodes/#{node}.yaml"
    p node
  end
end

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == "default"
    targets << target
  end

  task :all     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == "_default" ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = original_target
      t.pattern = "spec/#{original_target}/*_spec.rb"
    end
  end
end

namespace :provision do
  task :default => :all
  task :all do
    commands = []
    `vagrant ssh-config`.scan /^Host (\w+)/ do |result|
      host = result[0]
      node = "provision/nodes/#{node}.yaml"
      node = "provision/nodes/default.yaml" unless File.exist? node
      main = "provision/entrypoint.rb"
      commands.push "itamae ssh --vagrant --host #{host} -y #{node} #{main}"
    end
    Parallel.each commands, in_threads: commands.length do |command|
      sh command
    end
  end
end
