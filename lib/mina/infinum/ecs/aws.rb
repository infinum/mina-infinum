require 'English'

set :debug, false

namespace :aws do
  task :ensure_cli_version do
    version = run_cmd "aws --version #{'--debug' if debug?}"

    error! 'AWS CLI version 2 is required' unless version.start_with?('aws-cli/2')

    puts "AWS CLI v2 is intalled. Version: #{version}" if debug?
  end

  desc <<~TXT
    Log in to AWS

    Retrieves an SSO access token from AWS. Prerequisite for any task
    which requires authentication (for example, ecs:connect).

    Logs in with profile :aws_login_profile if defined, otherwise uses
    :aws_source_profile.
  TXT
  task login: [:ensure_cli_version] do
    ensure!(:aws_source_profile)

    login_profile = fetch(:aws_login_profile, fetch(:aws_source_profile))

    run_cmd "aws sso login --profile #{login_profile}", exec: true
  end

  desc <<~TXT
    Open AWS console in the browser

    The console is opened in region :aws_region.
  TXT
  task console: ['profile:check'] do
    ensure!(:aws_region)

    region = fetch(:aws_region)

    run_cmd "open https://#{region}.console.aws.amazon.com/console/home?region=#{region}", exec: true
  end

  namespace :profile do
    task :check do
      next if fetch(:skip_profile)

      ensure!(:aws_profile)

      unless profile_exists?(fetch(:aws_profile))
        error! "Please create AWS profile '#{fetch(:aws_profile)}' first (use task aws:profile:create)"
      end
    end

    desc <<~TXT
      Create AWS profile

      Creates profile :aws_profile on local machine. Prerequisite for
      any task which uses AWS resources (for example, ecs:connect).

      The profile is set up with parameters:
      - source_profile -> :aws_source_profile
      - region -> :aws_region
      - role_arn -> :aws_role_arn
    TXT
    task create: [:ensure_cli_version] do
      ensure!(:aws_profile)
      ensure!(:aws_source_profile)
      ensure!(:aws_region)
      ensure!(:aws_role_arn)

      unless profile_exists?(fetch(:aws_source_profile))
        error! "Please create AWS source profile first - #{fetch(:aws_source_profile)}"
      end

      if profile_exists?(fetch(:aws_profile)) && !fetch(:force)
        puts "Profile '#{fetch(:aws_profile)}' already exists, add 'force=true' to overwrite it"
      else
        puts "Creating profile '#{fetch(:aws_profile)}'..."
        run_cmd "aws configure set source_profile #{fetch(:aws_source_profile)} --profile #{fetch(:aws_profile)} #{'--debug' if debug?}"
        run_cmd "aws configure set region #{fetch(:aws_region)} --profile #{fetch(:aws_profile)} #{'--debug' if debug?}"
        run_cmd "aws configure set role_arn #{fetch(:aws_role_arn)} --profile #{fetch(:aws_profile)} #{'--debug' if debug?}"
        puts 'Done'
      end
    end
  end
end

def profile_exists?(profile)
  profiles = run_cmd "aws configure list-profiles #{'--debug' if debug?}"

  error! 'Cannot list AWS profiles' unless $CHILD_STATUS.success?

  profiles.split("\n").include?(profile)
end

def aws_cli_profile_flag
  fetch(:aws_profile) && !fetch(:skip_profile) ? "--profile #{fetch(:aws_profile)}" : ''
end

desc 'Alias for aws:login'
task :login => 'aws:login'
