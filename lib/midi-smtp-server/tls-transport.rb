# frozen_string_literal: true

# A small and highly customizable ruby SMTP-Server.
module MidiSmtpServer

  # Encryption modes
  ENCRYPT_MODES = [:TLS_FORBIDDEN, :TLS_OPTIONAL, :TLS_REQUIRED].freeze
  DEFAULT_ENCRYPT_MODE = :TLS_FORBIDDEN

  # Encryption ciphers and methods
  # check https://www.owasp.org/index.php/TLS_Cipher_String_Cheat_Sheet
  TLS_CIPHERS_ADVANCED_PLUS = 'DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256'
  TLS_CIPHERS_ADVANCED      = (TLS_CIPHERS_ADVANCED_PLUS + ':DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256')
  TLS_CIPHERS_BROAD_COMP    = (TLS_CIPHERS_ADVANCED + ':ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA')
  TLS_CIPHERS_WIDEST_COMP   = (TLS_CIPHERS_ADVANCED + ':ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA')
  TLS_CIPHERS_LEGACY        = (TLS_CIPHERS_ADVANCED + ':ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA')
  TLS_METHODS_ADVANCED      = 'TLSv1_2'
  TLS_METHODS_LEGACY        = 'TLSv1_1'

  # class for TlsTransport
  class TlsTransport

    def initialize(cert_path, key_path, ciphers, methods, common_names, logger)
      # if need to debug something while working with openssl
      # OpenSSL::debug = true

      # save references
      @logger = logger
      @cert_path = cert_path.nil? ? nil : cert_path.strip
      @key_path = key_path.nil? ? nil : key_path.strip
      # create SSL context
      @ctx = OpenSSL::SSL::SSLContext.new
      @ctx.ciphers = ciphers.to_s != '' ? ciphers : TLS_CIPHERS_ADVANCED_PLUS
      @ctx.ssl_version = methods.to_s != '' ? methods : TLS_METHODS_ADVANCED
      # check cert_path and key_path
      if !@cert_path.nil? || !@key_path.nil?
        # if any is set, test the pathes
        raise "File \”#{@cert_path}\" does not exist or is not a regular file. Could not load certificate." unless File.file?(@cert_path.to_s)
        raise "File \”#{@key_path}\" does not exist or is not a regular file. Could not load private key." unless File.file?(@key_path.to_s)
        # try to load certificate and key
        @ctx.cert = OpenSSL::X509::Certificate.new(File.open(@cert_path.to_s))
        @ctx.key = OpenSSL::PKey::RSA.new(File.open(@key_path.to_s))
      else
        # if none was set, create a test cert
        # and try to setup common name(s) for cert
        @common_names = (['localhost.local', 'localhost', '127.0.0.1', '::1'] + common_names).uniq
        # initialize self certificate and key
        logger.debug('SSL: using self generated test certificate!')
        @ctx.key = OpenSSL::PKey::RSA.new 4096
        @ctx.cert = OpenSSL::X509::Certificate.new
        @ctx.cert.version = 2
        @ctx.cert.serial = 1
        @ctx.cert.subject = OpenSSL::X509::Name.new @common_names.map { |cn| ['CN', cn] }
        @ctx.cert.issuer = @ctx.cert.subject
        @ctx.cert.public_key = @ctx.key
        @ctx.cert.not_before = Time.now
        @ctx.cert.not_after = Time.now + 60 * 60 * 24 * 90
        @ef = OpenSSL::X509::ExtensionFactory.new
        @ef.subject_certificate = @ctx.cert
        @ef.issuer_certificate = @ctx.cert
        @ctx.cert.add_extension(@ef.create_extension('basicConstraints', 'CA:TRUE', true))
        @ctx.cert.add_extension(@ef.create_extension('keyUsage', 'cRLSign,keyCertSign', true))
        @ctx.cert.sign @ctx.key, OpenSSL::Digest::SHA1.new
      end
    end

    # start ssl connection over existing tcpserver socket
    def start(io)
      # start SSL negotiation
      ssl = OpenSSL::SSL::SSLSocket.new(io, @ctx)
      # connect to server socket
      ssl.accept
      # make sure to close also the underlying io
      ssl.sync_close = true
      # return as new io socket
      return ssl
    end

  end

end
