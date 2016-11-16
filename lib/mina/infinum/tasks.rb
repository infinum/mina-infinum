desc 'Restart application'
task :restart_application do
  comment %(Restarting application)
  command %(passenger-config restart-app --ignore-app-not-running #{fetch(:deploy_to)})
end

namespace :background_workers do
  [:restart, :start, :stop, :status].each do |state|
    desc "#{state.capitalize}ing background workers"
    task state do
      background_worker(state)
    end
  end
end
