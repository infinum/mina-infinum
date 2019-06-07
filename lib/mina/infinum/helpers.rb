def background_worker(state)
  ensure!(:background_worker)
  ensure!(:application_name)
  comment %(#{state}ing #{background_worker_name})
  case fetch(:service_manager)
  when :systemd
    command %(sudo /bin/systemctl --no-pager #{state} #{background_worker_name})
  when :upstart
    command %(sudo #{state} #{background_worker_name})
  end
end

def background_worker_name
  [fetch(:background_worker), fetch(:application_name), fetch(:rails_env)].join('-')
end
