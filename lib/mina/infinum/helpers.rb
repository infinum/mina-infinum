def background_worker(state)
  ensure!(:background_worker)
  ensure!(:application_name)
  comment %(Restarting delayed job)
  command %(sudo #{state} #{background_worker_name})
end

def background_worker_name
  [fetch(:background_worker), fetch(:application_name), fetch(:rails_env)].join('-')
end
