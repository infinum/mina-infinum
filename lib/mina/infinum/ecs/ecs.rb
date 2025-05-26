require 'json'
require 'mina/infinum/ecs/aws'

namespace :ecs do
  desc 'Execute a command on ECS container'
  task :exec, [:command] => ['aws:profile:check'] do |_, args|
    ensure!(:cluster)
    ensure!(:service)

    command = args.fetch(:command) { error! 'Command is a required argument' }

    task_arn = find_task_arn

    Kernel.exec squish(<<~CMD)
      aws ecs execute-command
        --task #{task_arn}
        --command \"#{command}\"
        --cluster #{fetch(:cluster)}
        --profile #{fetch(:aws_profile)}
        --interactive
        #{"--container #{fetch(:container)}" if fetch(:container)}
        #{'--debug' if debug?}
    CMD
  end

  desc 'Connect to the ECS container'
  task :connect do
    invoke 'ecs:exec', fetch(:shell, 'bash')
  end
end

def find_task_arn
  output = Kernel.` squish(<<~CMD)
    aws ecs list-tasks
      --output json
      --cluster #{fetch(:cluster)}
      --service #{fetch(:service)}
      --profile #{fetch(:aws_profile)}
      #{'--debug' if debug?}
  CMD

  unless $CHILD_STATUS.success?
    error! 'Cannot list ECS tasks, see above error (set --debug flag for more info)'
  end

  JSON.parse(output).dig('taskArns', 0) || error!('There are no task definitions')
end
