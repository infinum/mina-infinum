require 'mina/default'
require 'mina/infinum/ecs/rails'
require 'mina/infinum/ecs/db'

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
