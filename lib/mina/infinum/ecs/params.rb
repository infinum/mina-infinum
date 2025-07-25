require 'mina/infinum/ecs/aws'

namespace :params do
  desc <<~TXT
    Print AWS Param Store params to stdout

    By default, params are fetched from path "/:cluster/".
    All levels of params are fetched under this path, e.g.
    both "/:cluster/A" and "/:cluster/A/B/C" will be fetched.

    You can override the path by setting :params_path.
  TXT
  task read: ['aws:profile:check'] do
    puts get_params.map(&:as_env)
  end

  desc <<~TXT
    Save AWS Param Store params to .env file

    See params:read documentation for details on how params
    are fetched.
  TXT
  task pull: ['aws:profile:check'] do
    env_file_path = File.join(Dir.pwd, '.env')

    File.write(env_file_path, get_params.map(&:as_env).join("\n"))
  end
end

Param = Data.define(:name, :value) do
  # /staging-acme/acme/staging/BUGSNAG_API_KEY -> BUGSNAG_API_KEY
  def variable_name
    name.split('/').last
  end

  def as_env
    "#{variable_name}=#{value}"
  end
end

def get_params
  normalize_params(get_params_from_aws)
end

def normalize_params(raw_params)
  raw_params.map do |param|
    Param.new(name: param.fetch('Name'), value: param.fetch('Value'))
  end
end

def get_params_from_aws
  params_path = fetch(:params_path) || default_params_path
  output = run_cmd squish(<<~CMD)
    aws ssm get-parameters-by-path
      --path #{params_path}
      --with-decryption
      --recursive
      --profile #{fetch(:aws_profile)}
      #{'--debug' if debug?}
  CMD

  unless $CHILD_STATUS.success?
    error! "Cannot fetch params from AWS... do you need to log in (use task aws:login)? For more info, add debug=true to command"
  end

  JSON.parse(output).dig('Parameters') || error!('There are no params in the response')
end

def default_params_path
  ensure!(:cluster)

  "/#{fetch(:cluster)}/"
end
