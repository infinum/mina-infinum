require 'mina/infinum/ecs/aws'

namespace :db do
  desc <<~TXT
    Forward remote DB port to local port through an SSM session

    Connects to the AWS resource :aws_jump_server_id through an SSM session
    and forwards port :db_port (default: 5432) on host :db_host to local
    port :db_local_port (default: 9999). Uses profile :aws_profile.

    You can override local port in config/deploy.rb, or inline:
    $ mina db:proxy db_local_port=4242
  TXT
  task proxy: ['aws:profile:check'] do
    ensure!(:aws_jump_server_id)
    ensure!(:db_host)

    profile = fetch(:aws_profile)
    jump_server_id = fetch(:aws_jump_server_id)
    host = fetch(:db_host)
    remote_port = fetch(:db_port, 5432)
    local_port = fetch(:db_local_port, 9999)

    run_cmd squish(<<~CMD), exec: true
      aws ssm start-session
        --target #{jump_server_id}
        --document-name AWS-StartPortForwardingSessionToRemoteHost
        --parameters host="#{host}",portNumber="#{remote_port}",localPortNumber="#{local_port}"
        --profile #{profile}
        #{'--debug' if debug?}
    CMD
  end
end
