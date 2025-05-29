require 'json'
require 'mina/infinum/ecs/aws'

namespace :ecs do
  desc <<~TXT
    Execute a command on ECS container

    Executes command :command in interactive mode on container in active
    task on cluster :cluster for service :service. Uses profile :aws_profile.

    Command is provided as a rake task argument:
    $ mina "ecs:exec[command]"
  TXT
  task :exec, [:command] => ['aws:profile:check'] do |_, args|
    ensure!(:cluster)
    ensure!(:service)

    command = args.fetch(:command) { error! 'Command is a required argument' }

    task_arn = find_task_arn

    run_cmd squish(<<~CMD), exec: true
      aws ecs execute-command
        --task #{task_arn}
        --command \"#{command}\"
        --cluster #{fetch(:cluster)}
        --profile #{fetch(:aws_profile)}
        --interactive
        #{'--debug' if debug?}
    CMD
  end

  desc <<~TXT
    Connect to the ECS container

    Uses ecs:exec task to start a shell on the container.

    The shell is defined with :shell (default: 'bash').
  TXT
  task :connect do
    invoke 'ecs:exec', fetch(:shell, 'bash')
  end
end

def find_task_arn
  output = run_cmd squish(<<~CMD)
    aws ecs list-tasks
      --output json
      --cluster #{fetch(:cluster)}
      --service #{fetch(:service)}
      --profile #{fetch(:aws_profile)}
      #{'--debug' if debug?}
  CMD

  unless $CHILD_STATUS.success?
    error! "Cannot list ECS tasks... do you need to log in (use task aws:login)? For more info, add debug=true to command"
  end

  JSON.parse(output).dig('taskArns', 0) || error!('There are no task definitions')
end
