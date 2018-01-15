# Mina::Infinum

For `mina 0.3.0` please take a look at [v0.3.0 branch](https://github.com/infinum/mina-infinum/tree/v0.3.0)
## Plugins

``` ruby
'mina', '~> 1.0.0'
'mina-data_sync', '~> 1.0.0'
'mina-secrets', '~> 1.0.0'
'mina-whenever', '~> 1.0.0'
```

Removed mina-delayed_job as we are moving towards delayed_job in processes.
github

## Setup

``` ruby
set :application_name, <APP_NAME>        # Used in background workers tasks
set :background_worker, <WORKER_NAME>    # Used in background workers tasks (eg. 'dj')
set :publish_api_path, <PUBLIC API PATH> # Used in publish api docs tasks(eg. 'api/v1/docs')
```

Background workers name:

```ruby
[fetch(:background_worker), fetch(:application_name), fetch(:rails_env)].join('-') # dj-labs-production
```

## Tasks

``` ruby
:restart_application # restart passenger
:publish_api_doc     # Publish dox to the server
:'background_workers:restart'
:'background_workers:start'
:'background_workers:stop'
:'background_workers:status'
```

## Contributing

Feel free to add your own tasks

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
