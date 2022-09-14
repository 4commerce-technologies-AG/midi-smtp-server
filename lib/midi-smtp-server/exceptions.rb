# frozen_string_literal: true

# A small and highly customizable ruby SMTP-Server.
module MidiSmtpServer

  private

  # special internal exception to signal timeout
  # while waiting for incoming data line
  class SmtpdIOTimeoutException < RuntimeError
  end

  # special internal exception to signal buffer size exceeding
  # while waiting for incoming data line
  class SmtpdIOBufferOverrunException < RuntimeError
  end

  # special internal exception to signal service stop
  # without creating a fatal error message
  class SmtpdStopServiceException < RuntimeError
  end

  # special internal exception to signal connection stop while
  # server shutdown without creating a fatal error message
  class SmtpdStopConnectionException < RuntimeError
  end

  public

  # generic smtp server exception class
  class SmtpdException < RuntimeError

    attr_reader :smtpd_return_code
    attr_reader :smtpd_return_text

    def initialize(msg, smtpd_return_code, smtpd_return_text)
      # save reference for smtp dialog
      @smtpd_return_code = smtpd_return_code
      @smtpd_return_text = smtpd_return_text
      # call inherited constructor
      super msg
    end

    def smtpd_result
      return "#{@smtpd_return_code} #{@smtpd_return_text}"
    end

  end

  # 421 <domain> Service not available, closing transmission channel
  class Smtpd421Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 421, 'Service too busy or not available, closing transmission channel'
    end

  end

  # 450 Requested mail action not taken: mailbox unavailable
  #     e.g. mailbox busy
  class Smtpd450Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 450, 'Requested mail action not taken: mailbox unavailable'
    end

  end

  # 451 Requested action aborted: local error in processing
  class Smtpd451Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 451, 'Requested action aborted: local error in processing'
    end

  end

  # 452 Requested action not taken: insufficient system storage
  class Smtpd452Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 452, 'Requested action not taken: insufficient system storage'
    end

  end

  # 500 Syntax error, command unrecognised or error in parameters or arguments.
  #     This may include errors such as command line too long
  class Smtpd500Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 500, 'Syntax error, command unrecognised or error in parameters or arguments'
    end

  end

  # 501 Syntax error in parameters or arguments
  class Smtpd501Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 501, 'Syntax error in parameters or arguments'
    end

  end

  # 502 Command not implemented
  class Smtpd502Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 502, 'Command not implemented'
    end

  end

  # 503 Bad sequence of commands
  class Smtpd503Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 503, 'Bad sequence of commands'
    end

  end

  # 504 Command parameter not implemented
  class Smtpd504Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 504, 'Command parameter not implemented'
    end

  end

  # 521 <domain> does not accept mail [rfc1846]
  class Smtpd521Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 521, 'Service does not accept mail'
    end

  end

  # 550 Requested action not taken: mailbox unavailable
  #     e.g. mailbox not found, no access
  class Smtpd550Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 550, 'Requested action not taken: mailbox unavailable'
    end

  end

  # 552 Requested mail action aborted: exceeded storage allocation
  class Smtpd552Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 552, 'Requested mail action aborted: exceeded storage allocation'
    end

  end

  # 553 Requested action not taken: mailbox name not allowed
  class Smtpd553Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 553, 'Requested action not taken: mailbox name not allowed'
    end

  end

  # 554 Transaction failed
  class Smtpd554Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 554, 'Transaction failed'
    end

  end

  # Status when using authentication

  # 432 Password transition is needed
  class Smtpd432Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 432, 'Password transition is needed'
    end

  end

  # 454 Temporary authentication failure
  class Smtpd454Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 454, 'Temporary authentication failure'
    end

  end

  # 530 Authentication required
  class Smtpd530Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 530, 'Authentication required'
    end

  end

  # 534 Authentication mechanism is too weak
  class Smtpd534Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 534, 'Authentication mechanism is too weak'
    end

  end

  # 535 Authentication credentials invalid
  class Smtpd535Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 535, 'Authentication credentials invalid'
    end

  end

  # 538 Encryption required for requested authentication mechanism
  class Smtpd538Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 538, 'Encryption required for requested authentication mechanism'
    end

  end

  # Status when using encryption

  # 454 TLS not available
  class Tls454Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 454, 'TLS not available'
    end

  end

  # 530 Encryption required
  class Tls530Exception < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 530, 'Encryption required, must issue STARTTLS command first'
    end

  end

  # Status when disabled PIPELINING

  # 500 Bad input, no PIPELINING
  class Smtpd500PipeliningException < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 500, 'Bad input, PIPELINING is not allowed'
    end

  end

  # Status when expecting CRLF sequence as line breaks (RFC(2)822)

  # 500 Bad input, missing CRLF line termination
  class Smtpd500CrLfSequenceException < SmtpdException

    def initialize(msg = nil)
      # call inherited constructor
      super msg, 500, 'Bad input, Lines must be terminated by CRLF sequence'
    end

  end

end
