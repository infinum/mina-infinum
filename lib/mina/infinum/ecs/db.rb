require 'mina/infinum/ecs/aws'

namespace :db do
  desc 'Forward remote DB port to local port through an SSM session'
  task proxy: ['aws:profile:check'] do |_, args|
    ensure!(:aws_bastion_id)
    ensure!(:db_host)

    profile = fetch(:aws_profile)
    bastion_id = fetch(:aws_bastion_id)
    host = fetch(:db_host)
    remote_port = fetch(:db_port, 5432)
    local_port = args.to_a.fetch(0) { fetch(:db_tunnel_port, 9999) }

    Kernel.exec squish(<<~CMD)
      aws ssm start-session
        --target #{bastion_id}
        --document-name AWS-StartPortForwardingSessionToRemoteHost
        --parameters host="#{host}",portNumber="#{remote_port}",localPortNumber="#{local_port}"
        --profile #{profile}
        #{'--debug' if debug?}
    CMD
  end
end
