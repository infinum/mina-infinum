require 'mina/default'
require 'mina/infinum/ecs/rails'
require 'mina/infinum/ecs/db'
require 'mina/infinum/ecs/params'

# INFO: hides default Mina tasks when running "mina --tasks"
Rake::Task['run'].clear_comments
Rake::Task['ssh'].clear_comments
Rake::Task['ssh_keyscan_domain'].clear_comments
Rake::Task['ssh_keyscan_repo'].clear_comments

def squish(command)
  command.gsub(/[[:space:]]+/, ' ').strip
end

def run_cmd(cmd, exec: false)
  print_command(cmd) if fetch(:verbose)

  if exec
    Kernel.exec cmd
  else
    Kernel.` cmd
  end
end

def debug?
  fetch(:debug, false)
end
