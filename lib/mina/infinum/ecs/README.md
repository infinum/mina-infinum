# ECS tasks

This module contains common tasks for accessing ECS containers and Rails applications on them.

Tasks are split in several namespaces:
- `aws`: AWS-related commands (profile creation, SSO login)
- `db`: interaction with DBs (forwarding remote DB port to local machine)
- `ecs`: interaction with ECS containers (e.g. running commands)
- `rails`: interaction with Rails apps on ECS containers (e.g. opening the console)

To find available tasks, run `bundle exec mina --tasks`.<br />
To read detailed task descriptions, run `bundle exec mina --describe/-D`.

## Setup

To get started, copy the following into `config/deploy.rb` and adjust variables:

```ruby
require 'mina/infinum/ecs'

set :aws_profile, 'profile_name'
set :aws_source_profile, 'source_profile_name'
set :aws_region, 'region'
set :aws_role_arn, 'role_arn'
# set :aws_login_profile, 'login_profile_name' (uses :aws_source_profile by default)

set :service, 'service_name'
# set :db_local_port, 4242 (default: 9999)

# set :shell, 'zsh' (default: 'bash')

task :staging do
  set :rails_env, 'staging'
  set :aws_bastion_id, 'i-ec2_instance_id'
  set :db_host, 'production_db_host'
  # set :db_port, 3306 (default: 5432)
  set :cluster, 'production_cluster_name'
end

task :production do
  set :rails_env, 'production'
  set :aws_bastion_id, 'i-ec2_instance_id'
  set :db_host, 'production_db_host'
  # set :db_port, 3306 (default: 5432)
  set :cluster, 'production_cluster_name'
end
```

## Debug mode

To see debug output, append `debug=true` to command, e.g.: `bundle exec mina staging db:proxy debug=true`:
```
$ bundle exec mina staging db:proxy debug=true

2025-05-27 09:32:14,455 - MainThread - awscli.clidriver - DEBUG - CLI version: aws-cli/2.2.6 Python/3.8.8 Darwin/24.5.0 exe/x86_64
2025-05-27 09:32:14,455 - MainThread - awscli.clidriver - DEBUG - Arguments entered to CLI: ['configure', 'list-profiles', '--debug']
# and so on...
```

## Verbose mode

To see commands before they run, append `verbose=true`, e.g.: `bundle exec mina staging db:proxy verbose=true`:
```
$ bundle exec mina staging db:proxy verbose=true

  $ aws configure list-profiles
  $ aws ssm start-session --target aws_bastion_id --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters host="db_host",portNumber="5432",localPortNumber="9999" --profile aws_profile

Starting session with SessionId: botocore-session-12345
Port 9999 opened for sessionId botocore-session-12345.
Waiting for connections...
```
