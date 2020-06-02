set :service_manager, :upstart
set :sidekiq_web_namespace, nil

desc 'Restart application'
task :restart_application do
  comment %(Restarting application)
  command %(passenger-config restart-app --ignore-app-not-running #{fetch(:deploy_to)})
end

namespace :background_workers do
  [:start, :stop, :status, :restart].each do |state|
    desc "#{state.capitalize}ing background workers"
    task state do
      background_worker(state)
    end
  end
end

task :link_sidekiq_assets do
  custom_assets_path = File.join('./', 'public', fetch(:sidekiq_web_namespace).to_s)

  command "bundle_path=\"$(RAILS_ENV=#{fetch(:rails_env)} #{fetch(:bundle_bin)} show sidekiq)\""
  command "mkdir -p #{custom_assets_path}"
  command "ln -nfs $bundle_path/web/assets #{custom_assets_path}/sidekiq"
end
