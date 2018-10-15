# Specs to check the default properties on MidiSmtpServer class

describe MidiSmtpServerTest do
  # initialize before tests
  before do
    @smtpd = MidiSmtpServerTest.new
  end

  describe 'defaults (deprecated) port' do
    it 'must respond with 2525' do
      @smtpd.port.must_equal MidiSmtpServer::DEFAULT_SMTPD_PORT.to_s
    end
  end

  describe 'defaults ports' do
    it 'must respond with [2525]' do
      @smtpd.ports.must_equal [MidiSmtpServer::DEFAULT_SMTPD_PORT.to_s]
    end
  end

  describe 'defaults (deprecated) host' do
    it 'must respond with 127.0.0.1' do
      @smtpd.host.must_equal MidiSmtpServer::DEFAULT_SMTPD_HOST
    end
  end

  describe 'defaults hosts' do
    it 'must respond with [127.0.0.1]' do
      @smtpd.hosts.must_equal [MidiSmtpServer::DEFAULT_SMTPD_HOST]
    end
  end

  describe 'defaults max_processings' do
    it 'must respond with 4' do
      @smtpd.max_processings.must_equal 4
    end
  end

  describe 'defaults max_connections' do
    it 'must respond with nil' do
      @smtpd.max_connections.must_be_nil
    end
  end

  describe 'defaults crlf_mode' do
    it 'must respond with :CRLF_ENSURE' do
      @smtpd.crlf_mode.must_equal MidiSmtpServer::DEFAULT_CRLF_MODE
    end
  end

  describe 'defaults io_cmd_timeout' do
    it 'must respond with 30' do
      @smtpd.io_cmd_timeout.must_equal MidiSmtpServer::DEFAULT_IO_CMD_TIMEOUT
    end
  end

  describe 'defaults io_buffer_chunk_size' do
    it "must respond with #{4 * 1024}" do
      @smtpd.io_buffer_chunk_size.must_equal MidiSmtpServer::DEFAULT_IO_BUFFER_CHUNK_SIZE
    end
  end

  describe 'defaults io_buffer_max_size' do
    it "must respond with #{1 * 1024 * 1024}" do
      @smtpd.io_buffer_max_size.must_equal MidiSmtpServer::DEFAULT_IO_BUFFER_MAX_SIZE
    end
  end

  describe 'defaults do_dns_reverse_lookup' do
    it 'must respond with true' do
      @smtpd.do_dns_reverse_lookup.must_equal true
    end
  end

  describe 'defaults auth_mode' do
    it 'must respond with :AUTH_FORBIDDEN' do
      @smtpd.auth_mode.must_equal MidiSmtpServer::DEFAULT_AUTH_MODE
    end
  end

  describe 'defaults encrypt_mode' do
    it 'must respond with :TLS_FORBIDDEN' do
      @smtpd.encrypt_mode.must_equal MidiSmtpServer::DEFAULT_ENCRYPT_MODE
    end
  end

  describe 'defaults pipelining_extension status' do
    it 'must respond with false' do
      @smtpd.pipelining_extension.must_equal MidiSmtpServer::DEFAULT_PIPELINING_EXTENSION_ENABLED
    end
  end

  describe 'defaults internationalization_extensions status' do
    it 'must respond with false' do
      @smtpd.internationalization_extensions.must_equal MidiSmtpServer::DEFAULT_INTERNATIONALIZATION_EXTENSIONS_ENABLED
    end
  end
end
