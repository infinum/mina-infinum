require 'mina/infinum/ecs/ecs'

desc 'Execute a rails command'
desc <<~TXT
  Execute a Rails command

  Uses ecs:exec task to execute a Rails command on the container.

  Command is provided as a rake task argument:
  $ mina "rails[command]"
  and is executed on the container as:
  $ bundle exec rails [command]
TXT
task :rails, [:command] do |_, args|
  ensure!(:rails_env)

  command = args.fetch(:command) { error! 'Command is a required argument' }

  invoke 'ecs:exec', "bundle exec rails #{command}"
end

namespace :rails do
  desc <<~TXT
    Open rails console

    Runs "bundle exec rails console" on the ECS container.
  TXT
  task :console do
    invoke 'rails', 'console'
  end

  desc <<~TXT
    Tail application log

    Log is tailed from `log` folder for environment :rails_env.
  TXT
  task :log do
    ensure!(:rails_env)

    invoke 'ecs:exec', "tail -f log/#{fetch(:rails_env)}.log"
  end
end

desc 'Alias for rails:console'
task :console => 'rails:console'
