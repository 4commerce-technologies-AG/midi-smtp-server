require 'gserver'

class MidiSmtpServer < GServer

  def initialize(port = 2525, host = "127.0.0.1", max_connections = 4, do_smtp_server_reverse_lookup = true, *args)
    # call inherited instance
    super(port, host, max_connections, *args)
    # next should prevent (if wished) to auto resolve hostnames and create a delay on connection
    BasicSocket.do_not_reverse_lookup = true
    # save flag if this smtp server should do reverse lookups
    @do_smtp_server_reverse_lookup = do_smtp_server_reverse_lookup
  end
  
  def serve(io)
    # ON CONNECTION
    # 220 <domain> Service ready
    # 421 <domain> Service not available, closing transmission channel
    # Reset and initialize message
    reset_message(true)
    # get local address info
    _, Thread.current[:ctx][:server][:local_port], Thread.current[:ctx][:server][:local_host], Thread.current[:ctx][:server][:local_ip] = @do_smtp_server_reverse_lookup ? io.addr(:hostname) : io.addr(:numeric)
    # get remote partner hostname and address
    _, Thread.current[:ctx][:server][:remote_port], Thread.current[:ctx][:server][:remote_host], Thread.current[:ctx][:server][:remote_ip] = @do_smtp_server_reverse_lookup ? io.peeraddr(:hostname) : io.peeraddr(:numeric)
    # reply welcome
    io.print "220 #{Thread.current[:ctx][:server][:local_host]} says welcome!\r\n"
    # while data handle communication
    begin
      loop do
        if IO.select([io], nil, nil, 0.1)
          data = io.readline
          log("<<< " + data) if(@audit)
          output = process_line(data)
          log(">>> " + output) if(@audit && !output.empty?)
          io.print(output) unless output.empty?
        end
        break if (Thread.current[:cmd_sequence] == :CMD_QUIT) || io.closed?
      end
      # graceful end of connection
      io.print "221 Service closing transmission channel\r\n"

    rescue Exception => e

      # power down connection
      io.print "421 Service not available, closing transmission channel\r\n"
    end

    # always gracefully shutdown connection
    io.close
  end

  def process_line(line)
    # check wether in data or command mode
    if Thread.current[:cmd_sequence] != :CMD_DATA

      # Handle specific messages from the client
      case line
      
      when (/^(HELO|EHLO)/i)
        # HELO
        # 250 Requested mail action okay, completed
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 504 Command parameter not implemented
        # 521 <domain> does not accept mail [rfc1846]
        # 421 <domain> Service not available, closing transmission channel
        # EHLO
        # 250 Requested mail action okay, completed
        # 550 Not implemented
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 504 Command parameter not implemented
        # 421 <domain> Service not available, closing transmission channel
        # ---------
        # check valid command sequence
        if Thread.current[:cmd_sequence] != :CMD_HELO
          return "503 Bad sequence of commands\r\n"
        end
        # handle command
        @cmd_data = line.gsub(/^(HELO|EHLO)\ /i, '').strip
        # call event to handle data
        begin
          on_helo_event(@cmd_data, Thread.current[:ctx])
          # if no error raised, append to message hash
          Thread.current[:ctx][:server][:helo] = @cmd_data
          # set sequence state as RSET
          Thread.current[:cmd_sequence] = :CMD_RSET
          # reply ok
          return "250 OK\r\n"
        rescue Exception => e
          # something was not correct
          return "501 #{e.message}"
        end

      when (/^NOOP/i)
        # NOOP
        # 250 Requested mail action okay, completed
        # 500 Syntax error, command unrecognised
        # 421 <domain> Service not available, closing transmission channel
        return "250 OK\r\n"
      
      when (/^RSET/i)
        # RSET
        # 250 Requested mail action okay, completed
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 421 <domain> Service not available, closing transmission channel
        # ---------
        # check valid command sequence
        if Thread.current[:cmd_sequence] == :CMD_HELO
          return "503 Bad sequence of commands\r\n"
        end
        # handle command
        reset_message
        return "250 OK\r\n"
      
      when (/^QUIT/i)
        # QUIT
        # 221 <domain> Service closing transmission channel
        # 500 Syntax error, command unrecognised
        Thread.current[:cmd_sequence] = :CMD_QUIT
        return ""
      
      when (/^MAIL FROM\:/i)
        # MAIL
        # 250 Requested mail action okay, completed
        # 552 Requested mail action aborted: exceeded storage allocation
        # 451 Requested action aborted: local error in processing
        # 452 Requested action not taken: insufficient system storage
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 421 <domain> Service not available, closing transmission channel
        # ---------
        # check valid command sequence
        if Thread.current[:cmd_sequence] != :CMD_RSET
          return "503 Bad sequence of commands\r\n"
        end
        # handle command
        @cmd_data = line.gsub(/^MAIL FROM\:/i, '').strip
        # call event to handle data
        begin
          on_mail_from_event(@cmd_data, Thread.current[:ctx])
          # if no error raised, append to message hash
          Thread.current[:ctx][:envelope][:from] = @cmd_data
          # set sequence state
          Thread.current[:cmd_sequence] = :CMD_MAIL
          # reply ok
          return "250 OK\r\n"
        rescue Exception => e
          # something was not correct
          return "451 #{e.message}"
        end
      
      when (/^RCPT TO\:/i)
        # RCPT
        # 250 Requested mail action okay, completed
        # 251 User not local; will forward to <forward-path>
        # 550 Requested action not taken: mailbox unavailable
        # 551 User not local; please try <forward-path>
        # 552 Requested mail action aborted: exceeded storage allocation
        # 553 Requested action not taken: mailbox name not allowed
        # 450 Requested mail action not taken: mailbox unavailable
        # 451 Requested action aborted: local error in processing
        # 452 Requested action not taken: insufficient system storage
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 503 Bad sequence of commands
        # 521 <domain> does not accept mail [rfc1846]
        # 421 <domain> Service not available, closing transmission channel
        # ---------
        # check valid command sequence
        if ![ :CMD_MAIL, :CMD_RCPT ].include?(Thread.current[:cmd_sequence])
          return "503 Bad sequence of commands\r\n"
        end
        # handle command
        @cmd_data = line.gsub(/^RCPT TO\:/i, '').strip
        # call event to handle data
        begin
          on_rcpt_to_event(@cmd_data, Thread.current[:ctx])
          # if no error raised, append to message hash
          Thread.current[:ctx][:envelope][:to] << @cmd_data
          # set sequence state
          Thread.current[:cmd_sequence] = :CMD_RCPT
          # reply ok
          return "250 OK\r\n"
        rescue Exception => e
          # something was not correct
          return "521 #{e.message}"
        end
      
      when (/^DATA/i)
        # DATA
        # 354 Start mail input; end with <CRLF>.<CRLF>
        # 451 Requested action aborted: local error in processing
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 503 Bad sequence of commands
        # 250 Requested mail action okay, completed
        # 552 Requested mail action aborted: exceeded storage allocation
        # 554 Transaction failed
        # 421 <domain> Service not available, closing transmission channel received data
        # 451 Requested action aborted: local error in processing
        # 452 Requested action not taken: insufficient system storage
        # ---------
        # check valid command sequence
        if Thread.current[:cmd_sequence] != :CMD_RCPT
          return "503 Bad sequence of commands\r\n"
        end
        # handle command
        # set sequence state
        Thread.current[:cmd_sequence] = :CMD_DATA
        # reply ok / proceed with message data
        return "354 Enter message, ending with \".\" on a line by itself\r\n"
      
      else
        # If we somehow get to this point then
        # we have encountered an error
        return "500 Syntax error, command unrecognised\r\n"
    
    end
      
    else
      # If we are in data mode and the entire message consists
      # solely of a period on a line by itself then we
      # are being told to exit data mode
      if (line.chomp =~ /^\.$/)
        # append last chars to message data
        Thread.current[:ctx][:message] += line
        # remove ending line .
        Thread.current[:ctx][:message].gsub!(/\r\n\Z/, '').gsub!(/\.\Z/, '')
        # call event
        begin
          on_message_data_event(Thread.current[:ctx])
          return "250 Requested mail action okay, completed\r\n"
        rescue
          return "451 Requested action aborted: local error in processing\r\n"
        ensure
          # always start with empty values after finishing incoming message
          # and rset command sequence
          reset_message
        end
      
      else
        # If we are in date mode then we need to add
        # the new data to the message
        Thread.current[:ctx][:message] += line
        return ""
        # command sequence state will stay on :CMD_DATA

      end

    end
  end

  # get event on HELO:
  def on_helo_event(helo_data, ctx)
  end

  # get address send in MAIL FROM:
  def on_mail_from_event(mail_from_data, ctx)
  end

  # get each address send in RCPT TO:
  def on_rcpt_to_event(rcpt_to_data, ctx)
  end

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
  end

  private

  def reset_message(connection_initialize = false)
    # set active command sequence info
    Thread.current[:cmd_sequence] = connection_initialize ? :CMD_HELO : :CMD_RSET
    # test existing of :ctx hash
    Thread.current[:ctx] || Thread.current[:ctx] = {}
    # reset server values (only on connection start)
    if connection_initialize
      # create or rebuild :ctx hash
      Thread.current[:ctx].merge!({
        :server => {
          :local_host => "",
          :local_ip => "",
          :local_port => "",
          :remote_host => "",
          :remote_ip => "",
          :remote_port => "",
          :helo => ""
        }
      })
    end
    # reset envelope values
    Thread.current[:ctx].merge!({ 
      :envelope => {
        :from => "", 
        :to => []
      }
    })
    # reset message data
    Thread.current[:ctx].merge!({
      :message => ""
    })
  end

end
