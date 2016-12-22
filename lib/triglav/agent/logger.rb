require 'serverengine/daemon_logger'

module Triglav::Agent
  # Logger class
  #
  #     require 'triglav/agent/logger'
  #     logger = Logger.new('STDOUT', opts = {})
  class Logger < ::ServerEngine::DaemonLogger
    def initialize(logdev, *args)
      logdev = STDOUT if logdev == 'STDOUT'
      logdev = STDERR if logdev == 'STDERR'
      super(logdev, *args)
      @formatter = LogFormatter.new
    end

    def write(msg)
      @logdev.write msg
    end
  end

  class LogFormatter
    FORMAT = "%s [%s] %s %s\n"

    def initialize(opts={})
    end

    def call(severity, time, progname, msg)
      FORMAT % [format_datetime(time), severity, format_pid, format_message(msg)]
    end

    private
    def format_datetime(time)
      time.strftime("%Y-%m-%dT%H:%m:%S.%6N%:z")
    end

    def format_pid
      "PID-#{::Process.pid} TID-#{Thread.current.object_id}"
    end

    def format_message(message)
      case message
      when ::Exception
        e = message
        "#{e.class} (#{e.message})\\n  #{e.backtrace.join("\\n  ")}"
      else
        message.to_s.gsub(/\n/, "\\n")
      end
    end
  end
end
