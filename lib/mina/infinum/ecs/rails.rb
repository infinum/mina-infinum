require 'mina/infinum/ecs/ecs'

desc 'Execute a rails command'
desc <<~TXT
  Execute a rails command

  Uses ecs:exec task to execute rails command on the container.

  Command is provided as a rake task argument:
  $ mina "rails[command]"
TXT
task :rails, [:command] do |_, args|
  ensure!(:rails_env)

  command = args.fetch(:command) { error! 'Command is a required argument' }

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
