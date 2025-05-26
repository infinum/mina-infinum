require 'mina/infinum/ecs/ecs'

desc 'Execute a rails command'
task :rails do |_, args|
  ensure!(:rails_env)

  command = args.to_a.fetch(0) { error! "Provide a command as argument" }

  invoke 'ecs:exec', "bundle exec rails #{command}"
end

namespace :rails do
  desc 'Open rails console'
  task :console do
    invoke 'rails', 'console'
  end

  desc 'Tail application log'
  task :log do
    ensure!(:rails_env)

    invoke 'ecs:exec', "tail -f log/#{fetch(:rails_env)}.log"
  end
end
