# frozen_string_literal: true

# Specs to check the extended ports and hosts properties on MidiSmtpServer class
describe MidiSmtpServerTest do
  # initialize before tests
  before do
    @smtpd = MidiSmtpServerTest.new(ports: 2525, hosts: '127.0.0.1, ::1')
  end

  describe '1 port 2 hosts' do
    it 'must respond with [2525]' do
      expect(@smtpd.ports).must_equal ['2525']
    end
    it 'must respond with [127.0.0.1, ::1]' do
      expect(@smtpd.hosts).must_equal ['127.0.0.1', '::1']
    end
    it 'must respond with [127.0.0.1:2525, ::1:2525]' do
      expect(@smtpd.addresses).must_equal ['127.0.0.1:2525', '::1:2525']
    end
  end
end

describe MidiSmtpServerTest do
  # initialize before tests
  before do
    @smtpd = MidiSmtpServerTest.new(ports: '2525, 3535', hosts: '127.0.0.1, ::1')
  end

  describe '2 ports 2 hosts' do
    it 'must respond with [2525, 3535]' do
      expect(@smtpd.ports).must_equal ['2525', '3535']
    end
    it 'must respond with [127.0.0.1, ::1]' do
      expect(@smtpd.hosts).must_equal ['127.0.0.1', '::1']
    end
    it 'must respond with [127.0.0.1:2525, ::1:3535]' do
      expect(@smtpd.addresses).must_equal ['127.0.0.1:2525', '::1:3535']
    end
  end
end

describe MidiSmtpServerTest do
  # initialize before tests
  before do
    @smtpd = MidiSmtpServerTest.new(ports: '2525, 2525:3535', hosts: '127.0.0.1, ::1')
  end

  describe '3 ports 2 hosts' do
    it 'must respond with [2525, 2525:3535]' do
      expect(@smtpd.ports).must_equal ['2525', '2525:3535']
    end
    it 'must respond with [127.0.0.1, ::1]' do
      expect(@smtpd.hosts).must_equal ['127.0.0.1', '::1']
    end
    it 'must respond with [127.0.0.1:2525, ::1:2525, ::1:3535]' do
      expect(@smtpd.addresses).must_equal ['127.0.0.1:2525', '::1:2525', '::1:3535']
    end
  end
end
