# Specs to check the default properties on MidiSmtpServer class

describe MidiSmtpServerTest do
  # initialize before tests
  before do
    @smtpd = MidiSmtpServerTest.new
  end

  describe 'default (deprecated) port' do
    it 'must respond with 2525' do
      @smtpd.port.must_equal MidiSmtpServer::DEFAULT_SMTPD_PORT.to_s
    end
  end

  describe 'default ports' do
    it 'must respond with [2525]' do
      @smtpd.ports.must_equal [MidiSmtpServer::DEFAULT_SMTPD_PORT.to_s]
    end
  end

  describe 'default (deprecated) host' do
    it 'must respond with 127.0.0.1' do
      @smtpd.host.must_equal MidiSmtpServer::DEFAULT_SMTPD_HOST
    end
  end

  describe 'default hosts' do
    it 'must respond with [127.0.0.1]' do
      @smtpd.hosts.must_equal [MidiSmtpServer::DEFAULT_SMTPD_HOST]
    end
  end

  describe 'default max_connections' do
    it 'must respond with 4' do
      @smtpd.max_connections.must_equal 4
    end
  end

  describe 'default io_cmd_timeout' do
    it 'must respond with 30' do
      @smtpd.io_cmd_timeout.must_equal MidiSmtpServer::DEFAULT_IO_CMD_TIMEOUT
    end
  end

  describe 'default io_buffer_chunk_size' do
    it "must respond with #{4 * 1024}" do
      @smtpd.io_buffer_chunk_size.must_equal MidiSmtpServer::DEFAULT_IO_BUFFER_CHUNK_SIZE
    end
  end

  describe 'default io_buffer_max_size' do
    it "must respond with #{1 * 1024 * 1024}" do
      @smtpd.io_buffer_max_size.must_equal MidiSmtpServer::DEFAULT_IO_BUFFER_MAX_SIZE
    end
  end

  describe 'default do_dns_reverse_lookup' do
    it 'must respond with true' do
      @smtpd.do_dns_reverse_lookup.must_equal true
    end
  end

  describe 'default auth_mode' do
    it 'must respond with :AUTH_FORBIDDEN' do
      @smtpd.auth_mode.must_equal MidiSmtpServer::DEFAULT_AUTH_MODE
    end
  end

  describe 'default encrypt_mode' do
    it 'must respond with :TLS_FORBIDDEN' do
      @smtpd.encrypt_mode.must_equal MidiSmtpServer::DEFAULT_ENCRYPT_MODE
    end
  end

  describe 'default pipelining_extension status' do
    it 'must respond with false' do
      @smtpd.pipelining_extension.must_equal MidiSmtpServer::DEFAULT_PIPELINING_EXTENSION_ENABLED
    end
  end

  describe 'default internationalization_extensions status' do
    it 'must respond with false' do
      @smtpd.internationalization_extensions.must_equal MidiSmtpServer::DEFAULT_INTERNATIONALIZATION_EXTENSIONS_ENABLED
    end
  end
end
