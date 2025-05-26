# ECS tasks

Copy the following into `config/deploy.rb` and adjust variables:

```ruby
require 'mina/infinum/ecs'

set :aws_profile, 'profile_name'
set :aws_source_profile, 'source_profile_name'
set :aws_region, 'region'
set :aws_role_arn, 'role_arn'

set :service, 'service_name'

task :staging do
  set :rails_env, 'staging'
  set :aws_bastion_id, 'i-ec2_instance_id'
  set :db_host, 'production_db_host'
  set :cluster, 'production_cluster_name'
end

task :production do
  set :rails_env, 'production'
  set :aws_bastion_id, 'i-ec2_instance_id'
  set :db_host, 'production_db_host'
  set :cluster, 'production_cluster_name'
end
```

To see available tasks, run `bundle exec mina --tasks`.

To see debug output, append `debug=true` to command, e.g.: `bundle exec mina staging db:proxy debug=true`.
