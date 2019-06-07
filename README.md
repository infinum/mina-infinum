# Mina::Infinum

For `mina 0.3.0` please take a look at [v0.3.0 branch](https://github.com/infinum/mina-infinum/tree/v0.3.0)
## Plugins

* [mina](https://github.com/mina-deploy/mina), '~> 1.0.0'
* [mina-data_sync](https://github.com/d4be4st/mina-data_sync), '~> 1.0.0'
* [mina-dox](https://github.com/infinum/mina-dox), '~> 0.1'
* [mina-secrets](https://github.com/infinum/mina-secrets), '~> 1.0.0'
* [mina-whenever](https://github.com/mina-deploy/mina-whenever), '~> 1.0.0'

Removed mina-delayed_job as we are moving towards delayed_job in processes.
github

## Setup

``` ruby
set :application_name, <APP_NAME>        # Used in background workers tasks
set :background_worker, <WORKER_NAME>    # Used in background workers tasks (eg. 'dj')
set :service_manager, <SERVICE_MANAGER>  # systemd (default), upstart
```

Background workers name:

```ruby
[fetch(:background_worker), fetch(:application_name), fetch(:rails_env)].join('-') # dj-labs-production
```

## Tasks

``` ruby
:restart_application # restart passenger
:'background_workers:restart'
:'background_workers:start'
:'background_workers:stop'
:'background_workers:status'
```

## Contributing

Feel free to add your own tasks

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
