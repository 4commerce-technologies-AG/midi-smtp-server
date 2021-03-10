# frozen_string_literal: true

require 'logger'

# A small and highly customizable ruby SMTP-Server.
module MidiSmtpServer

  # class for Logging and support of on_logging_event
  class ForwardingLogger

    def initialize(on_logging_event)
      @on_logging_event = on_logging_event
    end

    def info(msg)
      @on_logging_event.call(nil, Logger::INFO, msg)
    end

    def warn(msg)
      @on_logging_event.call(nil, Logger::WARN, msg)
    end

    def error(msg)
      @on_logging_event.call(nil, Logger::ERROR, msg)
    end

    def fatal(msg)
      @on_logging_event.call(nil, Logger::FATAL, msg)
    end

    def debug(msg)
      @on_logging_event.call(nil, Logger::DEBUG, msg)
    end

  end

end
