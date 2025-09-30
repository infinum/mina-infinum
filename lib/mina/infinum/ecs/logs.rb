require 'rainbow'
require 'time'
require 'mina/infinum/ecs/aws'

desc <<~TXT
  Print logs from CloudWatch

  Logs are printed from :log_group, which is a CloudWatch log group name.

  Logs are fetched in range :start to :end (both inclusive). Both values must be
  parseable by `Time.parse` (e.g. ISO8601 timestamps). :start is required,
  :end is optional (if omitted, value will be current time).

  Some examples:
  # all logs from 26.9.2025. 14:00 (local time zone) until now
  $ mina logs start="2025-09-26 14:00"

  $ mina logs start="2025-09-26 14:00" end="2025-09-26 15:00"

  # UTC time zone
  $ mina logs start="2025-09-26T14:00Z"
TXT
task logs: ['aws:profile:check'] do
  ensure!(:log_group)
  ensure!(:start)

  start_time = Time.parse(fetch(:start))
  end_time = fetch(:end) ? Time.parse(fetch(:end)) : Time.now

  puts "Printing logs from #{fetch(:log_group)} in range [#{start_time.iso8601},#{end_time.iso8601}]"
  raw_logs = run_cmd squish(<<~CMD)
    aws logs filter-log-events
      --log-group-name #{fetch(:log_group)}
      --profile #{fetch(:aws_profile)}
      --start-time #{start_time.strftime('%s%L')}
      --end-time #{end_time.strftime('%s%L')}
      --output json
      --query "events[].{timestamp: timestamp, message: message}"
  CMD

  next if raw_logs.empty? # response can be empty due to auth issues, user will see error in terminal

  logs = JSON.parse(raw_logs)
  if logs.any?
    logs.each do |log|
      time = Time.at(0, log.fetch('timestamp'), :millisecond)
      puts "#{Rainbow(time.utc.iso8601).green} #{log.fetch('message')}"
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
    from what time recent logs are printed with :start. The value can be an
    ISO 8601 timestamp or a relative time. For example:
    $ mina logs:tail start="2025-09-26T12:00:00"
    or
    $ mina logs:tail start="5m"

    For more info on accepted :start values, see --since options
    https://docs.aws.amazon.com/cli/latest/reference/logs/tail.html#options
  TXT
  task tail: ['aws:profile:check'] do
    ensure!(:log_group)

    puts "Tailing logs from #{fetch(:log_group)}"
    run_cmd squish(<<~CMD), exec: true
      aws logs tail #{fetch(:log_group)}
        --profile #{fetch(:aws_profile)}
        --follow
        --format short
        #{"--since #{fetch(:start)}" if fetch(:start)}
    CMD
  end
end