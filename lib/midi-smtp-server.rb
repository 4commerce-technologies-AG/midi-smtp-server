require 'socket'
require 'thread'
require 'base64'

# A small and highly customizable ruby SMTP-Server.
module MidiSmtpServer

  # default values
  DEFAULT_SMTPD_HOST = '127.0.0.1'.freeze
  DEFAULT_SMTPD_PORT = 2525
  DEFAULT_SMTPD_MAX_CONNECTIONS = 4

  # Authentification modes
  AUTH_MODES = [:AUTH_FORBIDDEN, :AUTH_OPTIONAL, :AUTH_REQUIRED].freeze

  # class for SmtpServer
  class Smtpd

    public

    # Start the server
    def start
      serve_service
    end

    # Stop the server
    def stop(wait_seconds_before_close = 2, gracefully = true)
      # always signal shutdown
      shutdown if gracefully
      # wait if some connection(s) need(s) more time to handle shutdown
      sleep wait_seconds_before_close if connections?
      # drop tcp_server while raising SmtpdStopServiceException
      @connections_mutex.synchronize do
        @tcp_server_thread.raise SmtpdStopServiceException if @tcp_server_thread
      end
      # wait if some connection(s) still need(s) more time to come down
      sleep wait_seconds_before_close if connections?
    end

    # Returns true if the server has stopped.
    def stopped?
      @tcp_server_thread.nil?
    end

    # Schedule a shutdown for the server
    def shutdown
      @shutdown = true
    end

    # test for shutdown state
    def shutdown?
      @shutdown
    end

    # Return the current number of connected clients
    def connections
      @connections.size
    end

    # Return if has connected clients
    def connections?
      @connections.any?
    end

    # Join with the server thread
    # before joining the server wait a few seconds to let the service come up
    def join(sleep_seconds_before_join = 1)
      # check already started server
      return unless @tcp_server_thread
      # otherwise try to join
      begin
        # wait a second
        sleep sleep_seconds_before_join
        # join
        @tcp_server_thread.join

      # catch ctrl-c to stop service
      rescue Interrupt
      end
    end

    # Port on which to listen, as a Fixnum
    attr_reader :port
    # Host on which to bind, as a String
    attr_reader :host
    # Maximum number of connections to accept at a time, as a Fixnum
    attr_reader :max_connections
    # Authentification mode
    attr_reader :auth_mode

    # logging object, may be overrriden by special loggers like YELL or others
    attr_reader :logger

    # Initialize SMTP Server class
    #
    # +port+:: port to listen on
    # +host+:: interface ip to listen on or blank to listen on all interfaces
    # +max_connections+:: maximum number of simultaneous connections
    # +opts+:: optional settings
    # +opts.do_dns_reverse_lookup+:: flag if this smtp server should do reverse lookups on incoming connections
    # +opts.auth_mode+:: enable builtin authentication support (:AUTH_FORBIDDEN, :AUTH_OPTIONAL, :AUTH_REQUIRED)
    # +opts.logger+:: own logger class, otherwise default logger is created
    def initialize(port = DEFAULT_SMTPD_PORT, host = DEFAULT_SMTPD_HOST, max_connections = DEFAULT_SMTPD_MAX_CONNECTIONS, opts = {})
      # logging
      if opts.include?(:logger)
        @logger = opts[:logger]
      else
        require 'logger'
        @logger = Logger.new(STDOUT)
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        @logger.formatter = proc { |severity, datetime, _progname, msg| "#{datetime}: [#{severity}] #{msg.chomp}\n" }
      end
      # initialize class
      @tcp_server_thread = nil
      @port = port
      @host = host
      @max_connections = max_connections
      @connections = []
      @connections_mutex = Mutex.new
      @connections_cv = ConditionVariable.new
      # next should prevent (if wished) to auto resolve hostnames and create a delay on connection
      BasicSocket.do_not_reverse_lookup = true
      # save flag if this smtp server should do reverse lookups
      @do_dns_reverse_lookup = opts.include?(:do_dns_reverse_lookup) ? opts[:do_dns_reverse_lookup] : true
      # check for authentification
      @auth_mode = opts.include?(:auth_mode) ? opts[:auth_mode] : :AUTH_FORBIDDEN
      raise "Unknown authentification mode #{@auth_mode} was given by opts!" unless AUTH_MODES.include?(@auth_mode)
    end

    # get event on CONNECTION
    def on_connect_event(ctx)
      logger.debug("Client connect from #{ctx[:server][:remote_ip]}:#{ctx[:server][:remote_port]}")
    end

    # get event before DISONNECT
    def on_disconnect_event(ctx)
      logger.debug("Client disconnect from #{ctx[:server][:remote_ip]}:#{ctx[:server][:remote_port]}")
    end

    # get event on HELO/EHLO:
    def on_helo_event(ctx, helo_data) end

    # check the authentification on AUTH:
    # if any value returned, that will be used for ongoing processing
    # otherwise the original value will be used for authorization_id
    def on_auth_event(ctx, authorization_id, authentication_id, authentication)
      # if authentification is used, override this event
      # and implement your own user management.
      # otherwise all authentifications are blocked per default
      logger.debug("Deny access from #{ctx[:server][:remote_ip]}:#{ctx[:server][:remote_port]} for #{authentication_id}" + (authorization_id == '' ? '' : "/#{authorization_id}") + " with #{authentication}")
      raise Smtpd535Exception
    end

    # check the status of authentication for a given context
    def authenticated?(ctx)
      ctx[:server][:authenticated] && !ctx[:server][:authenticated].to_s.empty?
    end

    # get address send in MAIL FROM:
    # if any value returned, that will be used for ongoing processing
    # otherwise the original value will be used
    def on_mail_from_event(ctx, mail_from_data) end

    # get each address send in RCPT TO:
    # if any value returned, that will be used for ongoing processing
    # otherwise the original value will be used
    def on_rcpt_to_event(ctx, rcpt_to_data) end

    # get each message after DATA <message> .
    def on_message_data_event(ctx) end

    protected

    # Start the server if it isn't already running
    def serve_service
      raise 'Smtpd instance was already started' unless stopped?

      @shutdown = false
      @tcp_server = TCPServer.new(@host, @port)

      @tcp_server_thread = Thread.new do
        begin
          until shutdown?
            @connections_mutex.synchronize do
              while @connections.size >= @max_connections
                @connections_cv.wait(@connections_mutex)
              end
            end
            client = @tcp_server.accept
            Thread.new(client) do |io|
              @connections << Thread.current
              begin
                serve_client(io)
              rescue SmtpdStopConnectionException
                # ignore this exception due to service shutdown
              rescue StandardError => e
                # log fatal error while handling connection
                logger.fatal(e.backtrace.join("\n"))
              ensure
                begin
                  # always gracefully shutdown connection
                  io.close
                rescue StandardError
                end
                @connections_mutex.synchronize do
                  @connections.delete(Thread.current)
                  @connections_cv.signal
                end
              end
            end
          end
        rescue SmtpdStopServiceException
          # ignore this exception due to service shutdown
        rescue StandardError => e
          # log fatal error while starting new thread
          logger.fatal(e.backtrace.join("\n"))
        ensure
          begin
            @tcp_server.close
          rescue StandardError
          end
          if shutdown?
            @connections_mutex.synchronize do
              @connections_cv.wait(@connections_mutex) until @connections.empty?
            end
          else
            @connections.each { |c| c.raise SmtpdStopConnectionException }
          end
          @tcp_server_thread = nil
        end
      end
    end

    # handle connection
    def serve_client(io)
      # ON CONNECTION
      # 220 <domain> Service ready
      # 421 <domain> Service not available, closing transmission channel
      # Reset and initialize message
      process_reset_ctx(true)
      # get local address info
      _, Thread.current[:ctx][:server][:local_port], Thread.current[:ctx][:server][:local_host], Thread.current[:ctx][:server][:local_ip] = @do_smtp_server_reverse_lookup ? io.addr(:hostname) : io.addr(:numeric)
      # get remote partner hostname and address
      _, Thread.current[:ctx][:server][:remote_port], Thread.current[:ctx][:server][:remote_host], Thread.current[:ctx][:server][:remote_ip] = @do_smtp_server_reverse_lookup ? io.peeraddr(:hostname) : io.peeraddr(:numeric)
      # save connection date/time
      Thread.current[:ctx][:server][:connected] = Time.now.utc
      # check if we want to let this remote station connect us
      on_connect_event(Thread.current[:ctx])
      # handle connection
      begin
        begin
          # reply welcome
          io.print "220 #{Thread.current[:ctx][:server][:local_host]} says welcome!\r\n" unless io.closed?

          # while data handle communication
          loop do
            if IO.select([io], nil, nil, 0.1)

              # read and handle input
              data = io.readline
              # log data, verbosity based on log severity and data type
              logger.debug('<<< ' + data) if Thread.current[:cmd_sequence] != :CMD_DATA

              # process commands and handle special SmtpdExceptions
              begin
                output = process_line(data)

              # defined SmtpdException
              rescue SmtpdException => e
                # log error info if logging
                logger.error("#{e}")
                # get the given smtp dialog result
                output = "#{e.smtpd_result}"

              # Unknown general Exception during processing
              rescue StandardError => e
                # log error info if logging
                logger.error("#{e}")
                # set default smtp server dialog error
                output = "#{Smtpd500Exception.new.smtpd_result}"
              end

              # check result
              unless output.empty?
                # log smtp dialog // message data is stored separate
                logger.debug('>>> ' + output)
                # smtp dialog response
                io.print("#{output}\r\n") unless io.closed?
              end

            end
            # check for valid quit or broken communication
            break if (Thread.current[:cmd_sequence] == :CMD_QUIT) || io.closed? || shutdown?
          end
          # graceful end of connection
          io.print "221 Service closing transmission channel\r\n" unless io.closed? || shutdown?

        # connection was simply closed / aborted by remote closing socket
        rescue EOFError
          # log info but only while debugging otherwise ignore message
          logger.debug('EOFError - Connection lost due abort by client!')

        rescue StandardError => e
          # log error info if logging
          logger.error("#{e}")
          # power down connection
          # ignore IOErrors when sending final smtp abort return code 421
          begin
            io.print "#{Smtpd421Exception.new.smtpd_result}\r\n" unless io.closed?
          rescue StandardError
            logger.debug('IOError - Can\'t send 421 abort code!')
          end
        end

      ensure
        # event for cleanup at end of communication
        on_disconnect_event(Thread.current[:ctx])
      end
    end

    def process_line(line)
      # check whether in auth challenge modes
      if Thread.current[:cmd_sequence] == :CMD_AUTH_PLAIN_VALUES
        # handle authentication
        process_auth_plain(line)

      # check whether in auth challenge modes
      elsif Thread.current[:cmd_sequence] == :CMD_AUTH_LOGIN_USER
        # handle authentication
        process_auth_login_user(line)

      # check whether in auth challenge modes
      elsif Thread.current[:cmd_sequence] == :CMD_AUTH_LOGIN_PASS
        # handle authentication
        process_auth_login_pass(line)

      # check whether in data or command mode
      elsif Thread.current[:cmd_sequence] != :CMD_DATA

        # Handle specific messages from the client
        case line

          when (/^(HELO|EHLO)(\s+.*)?$/i)
            # HELO/EHLO
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # 504 Command parameter not implemented
            # 521 <domain> does not accept mail [rfc1846]
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] != :CMD_HELO
            # handle command
            @cmd_data = line.gsub(/^(HELO|EHLO)\ /i, '').strip
            # call event to handle data
            on_helo_event(Thread.current[:ctx], @cmd_data)
            # if no error raised, append to message hash
            Thread.current[:ctx][:server][:helo] = @cmd_data
            # set sequence state as RSET
            Thread.current[:cmd_sequence] = :CMD_RSET
            # check whether to answer as HELO or EHLO
            case line
              when (/^EHLO/i)
                # reply supported extensions
                return "250-8BITMIME\r\n" +
                       (@auth_mode != :AUTH_FORBIDDEN ? "250-AUTH LOGIN PLAIN\r\n" : '') +
                       '250 OK'
              else
                # reply ok only
                return '250 OK'
            end

          when (/^AUTH(\s+)((LOGIN|PLAIN)(\s+[A-Z0-9=]+)?|CRAM-MD5)\s*$/i)
            # AUTH
            # 235 Authentication Succeeded
            # 432 A password transition is needed
            # 454 Temporary authentication failure
            # 500 Authentication Exchange line is too long
            # 530 Authentication required
            # 534 Authentication mechanism is too weak
            # 535 Authentication credentials invalid
            # 538 Encryption required for requested authentication mechanism
            # ---------
            # check that authentication is enabled
            raise Smtpd503Exception if @auth_mode == :AUTH_FORBIDDEN
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] != :CMD_RSET
            # check that not already authenticated
            raise Smtpd503Exception if authenticated?(Thread.current[:ctx])
            # handle command line
            @auth_data = line.gsub(/^AUTH\ /i, '').strip.gsub(/\s+/, ' ').split(' ')
            # handle auth command
            case @auth_data[0]

              when (/PLAIN/i)
                # check if only command was given
                if @auth_data.length == 1
                  # set sequence for next command input
                  Thread.current[:cmd_sequence] = :CMD_AUTH_PLAIN_VALUES
                  # response code include post ending with a space
                  return '334 '
                else
                  # handle authentication with given auth_id and password
                  process_auth_plain(@auth_data.length == 2 ? @auth_data[1] : [])
                end

              when (/LOGIN/i)
                # check if auth_id was sent too
                if @auth_data.length == 1
                  # reset auth_challenge
                  Thread.current[:auth_challenge] = {}
                  # set sequence for next command input
                  Thread.current[:cmd_sequence] = :CMD_AUTH_LOGIN_USER
                  # response code with request for Username
                  return '334 ' + Base64.strict_encode64('Username:')
                elsif @auth_data.length == 2
                  # handle next sequence
                  process_auth_login_user(@auth_data[1])
                else
                  raise Smtpd500Exception
                end

              when (/CRAM-MD5/i)
                # not supported in case of also unencrypted data delivery
                # instead of supporting password encryption only, we will
                # provide optional SMTPS service instead
                # read discussion on https://github.com/4commerce-technologies-AG/midi-smtp-server/issues/3#issuecomment-126898711
                raise Smtpd500Exception

              else
                # unknown auth method
                raise Smtpd500Exception

            end

          when (/^NOOP\s*$/i)
            # NOOP
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel
            # 500 Syntax error, command unrecognised
            return '250 OK'

          when (/^RSET\s*$/i)
            # RSET
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] == :CMD_HELO
            # handle command
            process_reset_ctx
            return '250 OK'

          when (/^QUIT\s*$/i)
            # QUIT
            # 221 <domain> Service closing transmission channel
            # 500 Syntax error, command unrecognised
            Thread.current[:cmd_sequence] = :CMD_QUIT
            return ''

          when (/^MAIL FROM\:/i)
            # MAIL
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel
            # 451 Requested action aborted: local error in processing
            # 452 Requested action not taken: insufficient system storage
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # 552 Requested mail action aborted: exceeded storage allocation
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] != :CMD_RSET
            # check that authentication is enabled
            raise Smtpd530Exception if @auth_mode == :AUTH_REQUIRED && !authenticated?(Thread.current[:ctx])
            # handle command
            @cmd_data = line.gsub(/^MAIL FROM\:/i, '').strip
            # call event to handle data
            return_value = on_mail_from_event(Thread.current[:ctx], @cmd_data)
            if return_value
              # overwrite data with returned value
              @cmd_data = return_value
            end
            # if no error raised, append to message hash
            Thread.current[:ctx][:envelope][:from] = @cmd_data
            # set sequence state
            Thread.current[:cmd_sequence] = :CMD_MAIL
            # reply ok
            return '250 OK'

          when (/^RCPT TO\:/i)
            # RCPT
            # 250 Requested mail action okay, completed
            # 251 User not local; will forward to <forward-path>
            # 421 <domain> Service not available, closing transmission channel
            # 450 Requested mail action not taken: mailbox unavailable
            # 451 Requested action aborted: local error in processing
            # 452 Requested action not taken: insufficient system storage
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # 503 Bad sequence of commands
            # 521 <domain> does not accept mail [rfc1846]
            # 550 Requested action not taken: mailbox unavailable
            # 551 User not local; please try <forward-path>
            # 552 Requested mail action aborted: exceeded storage allocation
            # 553 Requested action not taken: mailbox name not allowed
            # ---------
            # check valid command sequence
            raise Smtpd503Exception unless [:CMD_MAIL, :CMD_RCPT].include?(Thread.current[:cmd_sequence])
            # check that authentication is enabled
            raise Smtpd530Exception if @auth_mode == :AUTH_REQUIRED && !authenticated?(Thread.current[:ctx])
            # handle command
            @cmd_data = line.gsub(/^RCPT TO\:/i, '').strip
            # call event to handle data
            return_value = on_rcpt_to_event(Thread.current[:ctx], @cmd_data)
            if return_value
              # overwrite data with returned value
              @cmd_data = return_value
            end
            # if no error raised, append to message hash
            Thread.current[:ctx][:envelope][:to] << @cmd_data
            # set sequence state
            Thread.current[:cmd_sequence] = :CMD_RCPT
            # reply ok
            return '250 OK'

          when (/^DATA\s*$/i)
            # DATA
            # 354 Start mail input; end with <CRLF>.<CRLF>
            # 250 Requested mail action okay, completed
            # 421 <domain> Service not available, closing transmission channel received data
            # 451 Requested action aborted: local error in processing
            # 452 Requested action not taken: insufficient system storage
            # 500 Syntax error, command unrecognised
            # 501 Syntax error in parameters or arguments
            # 503 Bad sequence of commands
            # 552 Requested mail action aborted: exceeded storage allocation
            # 554 Transaction failed
            # ---------
            # check valid command sequence
            raise Smtpd503Exception if Thread.current[:cmd_sequence] != :CMD_RCPT
            # check that authentication is enabled
            raise Smtpd530Exception if @auth_mode == :AUTH_REQUIRED && !authenticated?(Thread.current[:ctx])
            # handle command
            # set sequence state
            Thread.current[:cmd_sequence] = :CMD_DATA
            # reply ok / proceed with message data
            return '354 Enter message, ending with "." on a line by itself'

          else
            # If we somehow get to this point then
            # we have encountered an error
            raise Smtpd500Exception

        end

      else
        # If we are in date mode then ...

        # ... we need to add always the new message data (line) to the message
        Thread.current[:ctx][:message][:data] << line

        # ... and the entire new message data (line) does NOT consists
        # solely of a period (.) on a line by itself then we are being
        # told to continue data mode and the command sequence state
        # will stay on :CMD_DATA
        return '' unless line.chomp =~ /^\.$/

        # otherwise the entire new message data (line) consists
        # solely of a period on a line by itself then we are being
        # told to finish data mode

        # remove ending line period (.)
        Thread.current[:ctx][:message][:data].gsub!(/\r\n\Z/, '').gsub!(/\.\Z/, '')
        # save delivered UTC time
        Thread.current[:ctx][:message][:delivered] = Time.now.utc
        # save bytesize of message data
        Thread.current[:ctx][:message][:bytesize] = Thread.current[:ctx][:message][:data].bytesize
        # call event to process message
        begin
          on_message_data_event(Thread.current[:ctx])
          return '250 Requested mail action okay, completed'

        # test for SmtpdException
        rescue SmtpdException
          # just re-raise exception set by app
          raise

        # test all other Exceptions
        rescue StandardError => e
          # send correct aborted message to smtp dialog
          raise Smtpd451Exception, e

        ensure
          # always start with empty values after finishing incoming message
          # and rset command sequence
          process_reset_ctx
        end

      end
    end

    # reset the context of current smtpd dialog
    def process_reset_ctx(connection_initialize = false)
      # set active command sequence info
      Thread.current[:cmd_sequence] = connection_initialize ? :CMD_HELO : :CMD_RSET
      # drop any auth challenge
      Thread.current[:auth_challenge] = {}
      # test existing of :ctx hash
      Thread.current[:ctx] || Thread.current[:ctx] = {}
      # reset server values (only on connection start)
      if connection_initialize
        # create or rebuild :ctx hash
        Thread.current[:ctx].merge!(
          server: {
            local_host: '',
            local_ip: '',
            local_port: '',
            remote_host: '',
            remote_ip: '',
            remote_port: '',
            helo: '',
            connected: '',
            authorization_id: '',
            authentication_id: '',
            authenticated: ''
          }
        )
      end
      # reset envelope values
      Thread.current[:ctx].merge!(
        envelope: {
          from: '',
          to: []
        }
      )
      # reset message data
      Thread.current[:ctx].merge!(
        message: {
          delivered: -1,
          bytesize: -1,
          data: ''
        }
      )
    end

    # handle plain authentification
    def process_auth_plain(encoded_auth_response)
      begin
        # extract auth id (and password)
        @auth_values = Base64.decode64(encoded_auth_response).split("\x00")
        # check for valid credentials parameters
        raise Smtpd500Exception unless @auth_values.length == 3
        # call event function to test credentials
        return_value = on_auth_event(Thread.current[:ctx], @auth_values[0], @auth_values[1], @auth_values[2])
        if return_value
          # overwrite data with returned value as authorization id
          @auth_values[0] = return_value
        end
        # save authentication information to ctx
        Thread.current[:ctx][:server][:authorization_id] = @auth_values[0].to_s.empty? ? @auth_values[1] : @auth_values[0]
        Thread.current[:ctx][:server][:authentication_id] = @auth_values[1]
        Thread.current[:ctx][:server][:authenticated] = Time.now.utc
        # response code
        return '235 OK'

      ensure
        # whatever happens in this check, reset next sequence
        Thread.current[:cmd_sequence] = :CMD_RSET
      end
    end

    def process_auth_login_user(encoded_auth_response)
      # save challenged auth_id
      Thread.current[:auth_challenge][:authorization_id] = ''
      Thread.current[:auth_challenge][:authentication_id] = Base64.decode64(encoded_auth_response)
      # set sequence for next command input
      Thread.current[:cmd_sequence] = :CMD_AUTH_LOGIN_PASS
      # response code with request for Password
      return '334 ' + Base64.strict_encode64('Password:')
    end

    def process_auth_login_pass(encoded_auth_response)
      begin
        # extract auth id (and password)
        @auth_values = [
          Thread.current[:auth_challenge][:authorization_id],
          Thread.current[:auth_challenge][:authentication_id],
          Base64.decode64(encoded_auth_response)
        ]
        # check for valid credentials
        return_value = on_auth_event(Thread.current[:ctx], @auth_values[0], @auth_values[1], @auth_values[2])
        if return_value
          # overwrite data with returned value as authorization id
          @auth_values[0] = return_value
        end
        # save authentication information to ctx
        Thread.current[:ctx][:server][:authorization_id] = @auth_values[0].to_s.empty? ? @auth_values[1] : @auth_values[0]
        Thread.current[:ctx][:server][:authentication_id] = @auth_values[1]
        Thread.current[:ctx][:server][:authenticated] = Time.now.utc
        # response code
        return '235 OK'

      ensure
        # whatever happens in this check, reset next sequence
        Thread.current[:cmd_sequence] = :CMD_RSET
        # and reset auth_challenge
        Thread.current[:auth_challenge] = {}
      end
    end

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
      super msg, 421, 'Service not available, closing transmission channel'
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

end
