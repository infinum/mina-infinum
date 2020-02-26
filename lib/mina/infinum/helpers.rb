def background_worker(state)
  ensure!(:background_worker)
  ensure!(:application_name)
  ensure!(:service_manager)
  comment %(#{state}ing #{background_worker_name})
  service_manager = fetch(:service_manager).to_sym

  case service_manager
  when :systemd
    case state
    when :status
      command %(/bin/systemctl --no-pager #{state} #{background_worker_name})
    else
      command %(sudo /bin/systemctl #{state} #{background_worker_name})
    end

  when :upstart
    case state
    when :restart
      command %(sudo stop #{background_worker_name} > /dev/null 2>&1; sudo start #{background_worker_name})
    else
      command %(sudo #{state} #{background_worker_name})
    end
  else
    raise StandardError.new "Invalid service_manager: #{service_manager}.\nSupported service managers: systemd, upstart."
  end
end

def background_worker_name
  [fetch(:background_worker), fetch(:application_name), fetch(:rails_env)].join('-')
end
