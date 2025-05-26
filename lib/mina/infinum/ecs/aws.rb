require 'English'

set :debug, false

namespace :aws do
  task :ensure_cli_version do
    version = `aws --version #{'--debug' if debug?}`

    error! 'AWS CLI version 2 is required' unless version.start_with?('aws-cli/2')

    puts "AWS CLI v2 is intalled. Version: #{version}" if debug?
  end

  desc 'Log in to AWS'
  task login: [:ensure_cli_version] do
    ensure!(:aws_source_profile)

    login_profile = fetch(:aws_login_profile, fetch(:aws_source_profile))

    Kernel.exec "aws sso login --profile #{login_profile}"
  end

  desc 'Open AWS console in the browser'
  task console: ['profile:check'] do
    ensure!(:aws_region)

    region = fetch(:aws_region)

    Kernel.exec "open https://#{region}.console.aws.amazon.com/console/home?region=#{region}"
  end

  namespace :profile do
    task :check do
      ensure!(:aws_profile)

      unless profile_exists?(fetch(:aws_profile))
        error! "Please create AWS profile '#{fetch(:aws_profile)}' first (use `aws:profile:create` task)"
      end
    end

    desc 'Create AWS profile'
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
        `aws configure set source_profile #{fetch(:aws_source_profile)} --profile #{fetch(:aws_profile)} #{'--debug' if debug?}`
        `aws configure set region #{fetch(:aws_source_profile)} --profile #{fetch(:aws_profile)} #{'--debug' if debug?}`
        `aws configure set role_arn #{fetch(:aws_source_profile)} --profile #{fetch(:aws_profile)} #{'--debug' if debug?}`
        puts 'Done'
      end
    end
  end
end

def profile_exists?(profile)
  profiles = `aws configure list-profiles #{'--debug' if debug?}`

  error! 'Cannot list AWS profiles' unless $CHILD_STATUS.success?

  profiles.split("\n").include?(profile)
end

def debug?
  fetch(:debug, false)
end
