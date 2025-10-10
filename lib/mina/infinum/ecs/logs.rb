require 'time'
require 'mina/infinum/ecs/aws'

desc <<~TXT
  Print logs from CloudWatch

  Logs are printed from :log_group, which is a CloudWatch log group name.

  Logs are fetched in range :since to :until (both inclusive). Both values must be
  parseable by `Time.parse` (e.g. ISO8601 timestamps). :since is required,
  :until is optional (if omitted, value will be current time).

  If date is ommitted in either value, the current date is assumed.

  Examples:
  # logs since 26.9.2025. 14:00 in local time zone
  $ mina logs since="2025-09-26 14:00"

  # logs on 26.9.2025. between 14:00 and 15:00 in local time zone
  $ mina logs since="2025-09-26 14:00" until="2025-09-26 15:00"

  # logs between 14:00 and 15:00 today in local time zone
  $ mina logs since="14:00" until="15:00"

  # logs between 14:00 and 15:00 today in UTC
  $ mina logs since="14:00Z" until="15:00Z"

  # logs since 26.9.2025. 14:00 in UTC (ISO 8601 format)
  $ mina logs since="2025-09-26T14:00Z"
TXT
task logs: ['aws:profile:check'] do
  ensure!(:log_group)
  ensure!(:since)

  since_time = Time.parse(fetch(:since))
  until_time = fetch(:until) ? Time.parse(fetch(:until)) : Time.now

  puts "Printing logs from #{fetch(:log_group)} in range [#{since_time.iso8601},#{until_time.iso8601}]"
  raw_logs = run_cmd squish(<<~CMD)
    aws logs filter-log-events
      --log-group-name #{fetch(:log_group)}
      #{aws_cli_profile_flag}
      --start-time #{since_time.strftime('%s%L')}
      --end-time #{until_time.strftime('%s%L')}
      --output json
      --query "events[].{timestamp: timestamp, message: message}"
  CMD

  next if raw_logs.empty? # response can be empty due to auth issues, user will see error in terminal

  logs = JSON.parse(raw_logs)
  if logs.any?
    logs.each do |log|
      time = Time.at(0, log.fetch('timestamp'), :millisecond)
      puts "#{green_text(time.utc.iso8601)} #{log.fetch('message')}"
    end
  else
    puts 'There are no logs'
  end
end

namespace :logs do
  desc <<~TXT
    Tail logs from CloudWatch

    Logs are tailed from :log_group, which is a CloudWatch log group name.

    Before new logs are tailed, recent logs are first printed. You can control
    from what time recent logs are printed with :since. The value can be absolute
    time parseable by `Time.parse`, or relative time.

    If date is ommitted in absolute time, the current date is assumed.

    Examples:
    # tail logs since 26.9.2025. 14:00 in local time zone
    $ mina logs:tail since="2025-09-26 14:00"

    # tail logs since 14:00 today in local time zone
    $ mina logs:tail since="14:00"

    # tail logs since 26.9.2025. 14:00 in UTC (ISO 8601 format)
    $ mina logs:tail since="2025-09-26T14:00Z"

    # tail logs since 5 minutes ago
    $ mina logs:tail since="5m"

    For more info on accepted :since values, see --since options
    https://docs.aws.amazon.com/cli/latest/reference/logs/tail.html#options
  TXT
  task tail: ['aws:profile:check'] do
    ensure!(:log_group)

    since_time = fetch(:since)&.strip

    if since_time && !since_time.empty? && !since_time.match?(/\A\d+\w\z/)
      since_time = Time.parse(since_time).iso8601
    end

    puts "Tailing logs from #{fetch(:log_group)}"
    run_cmd squish(<<~CMD), exec: true
      aws logs tail #{fetch(:log_group)}
        #{aws_cli_profile_flag}
        --follow
        --format short
        #{"--since #{since_time}" if since_time}
    CMD
  end
end

def green_text(text)
  "\e[32m#{text}\e[0m"
end
