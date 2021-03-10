# frozen_string_literal: true

# Specs to check the default properties on MidiSmtpServer class
describe MidiSmtpServerTest do
  # initialize before tests
  before do
    @smtpd = MidiSmtpServerTest.new
  end

  describe 'defaults exception on empty hosts' do
    it 'must raise no hosts defined!' do
      err = expect { MidiSmtpServer::Smtpd.new(ports: 2525, hosts: '') }.must_raise RuntimeError
      assert_match(/No hosts defined!/, err.message)
    end
  end

  describe 'defaults exception on empty host in hosts' do
    it 'must raise empty host defined!' do
      err = expect { MidiSmtpServer::Smtpd.new(ports: 2525, hosts: '1.2.3.4,,5.6.7.8') }.must_raise RuntimeError
      assert_match(/Detected an empty identifier in given hosts!/, err.message)
    end
  end

  describe 'defaults must not respond to port method' do
    it 'must raise NoMethodError' do
      refute_respond_to(@smtpd, 'port')
    end
  end

  describe 'defaults ports' do
    it 'must respond with [2525]' do
      expect(@smtpd.ports).must_equal [MidiSmtpServer::DEFAULT_SMTPD_PORT.to_s]
    end
  end

  describe 'defaults must not respond to host method' do
    it 'must raise NoMethodError' do
      refute_respond_to(@smtpd, 'host')
    end
  end

  describe 'defaults hosts' do
    it 'must respond with [127.0.0.1]' do
      expect(@smtpd.hosts).must_equal [MidiSmtpServer::DEFAULT_SMTPD_HOST]
    end
  end

  describe 'defaults addresses' do
    it 'must respond with [127.0.0.1:2525]' do
      expect(@smtpd.addresses).must_equal ["#{MidiSmtpServer::DEFAULT_SMTPD_HOST}:#{MidiSmtpServer::DEFAULT_SMTPD_PORT}"]
    end
  end

  describe 'defaults max_processings' do
    it 'must respond with 4' do
      expect(@smtpd.max_processings).must_equal 4
    end
  end

  describe 'defaults max_connections' do
    it 'must respond with nil' do
      expect(@smtpd.max_connections).must_be_nil
    end
  end

  describe 'defaults crlf_mode' do
    it 'must respond with :CRLF_ENSURE' do
      expect(@smtpd.crlf_mode).must_equal MidiSmtpServer::DEFAULT_CRLF_MODE
    end
  end

  describe 'defaults io_cmd_timeout' do
    it 'must respond with 30' do
      expect(@smtpd.io_cmd_timeout).must_equal MidiSmtpServer::DEFAULT_IO_CMD_TIMEOUT
    end
  end

  describe 'defaults io_buffer_chunk_size' do
    it "must respond with #{4 * 1024}" do
      expect(@smtpd.io_buffer_chunk_size).must_equal MidiSmtpServer::DEFAULT_IO_BUFFER_CHUNK_SIZE
    end
  end

  describe 'defaults io_buffer_max_size' do
    it "must respond with #{1 * 1024 * 1024}" do
      expect(@smtpd.io_buffer_max_size).must_equal MidiSmtpServer::DEFAULT_IO_BUFFER_MAX_SIZE
    end
  end

  describe 'defaults do_dns_reverse_lookup' do
    it 'must respond with true' do
      expect(@smtpd.do_dns_reverse_lookup).must_equal true
    end
  end

  describe 'defaults auth_mode' do
    it 'must respond with :AUTH_FORBIDDEN' do
      expect(@smtpd.auth_mode).must_equal MidiSmtpServer::DEFAULT_AUTH_MODE
    end
  end

  describe 'defaults encrypt_mode' do
    it 'must respond with :TLS_FORBIDDEN' do
      expect(@smtpd.encrypt_mode).must_equal MidiSmtpServer::DEFAULT_ENCRYPT_MODE
    end
  end

  describe 'defaults pipelining_extension status' do
    it 'must respond with false' do
      expect(@smtpd.pipelining_extension).must_equal MidiSmtpServer::DEFAULT_PIPELINING_EXTENSION_ENABLED
    end
  end

  describe 'defaults internationalization_extensions status' do
    it 'must respond with false' do
      expect(@smtpd.internationalization_extensions).must_equal MidiSmtpServer::DEFAULT_INTERNATIONALIZATION_EXTENSIONS_ENABLED
    end
  end
end
