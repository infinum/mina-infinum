task :restart_application do
  queue %(echo "-----> Restarting application")
  queue! %(passenger-config restart-app --ignore-app-not-running #{deploy_to})
end
