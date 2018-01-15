desc 'Restart application'
task :restart_application do
  comment %(Restarting application)
  command %(passenger-config restart-app --ignore-app-not-running #{fetch(:deploy_to)})
end

namespace :background_workers do
  [:start, :stop, :status].each do |state|
    desc "#{state.capitalize}ing background workers"
    task state do
      background_worker(state)
    end
  end

  desc 'Restarting backgrond workers'
  task :restart do
    comment "Restarting #{background_worker_name}"
    command %(sudo stop #{background_worker_name} > /dev/null 2>&1; sudo start #{background_worker_name})
  end
end

task :publish_api_doc do
  ensure!(:publish_api_path)
  run(:remote) do
    command "mkdir -p #{fetch(:current_path)}/public/#{fetch(:publish_api_path)}"
  end

  run(:local) do
    command "scp -P #{fetch(:port)} public/#{fetch(:publish_api_path)}/index.html #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:current_path)}/public/#{fetch(:publish_api_path)}"
  end
end
