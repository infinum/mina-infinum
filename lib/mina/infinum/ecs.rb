require 'mina/default'
require 'mina/infinum/ecs/rails'
require 'mina/infinum/ecs/db'

def squish(command)
  command.gsub(/[[:space:]]+/, ' ').strip
end
