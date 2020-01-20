# frozen_string_literal: true

# Unit test to check commands without TCP
class PortsAndConnectionsIntegrationTest < Minitest::Test

  # overloaded midi-smtp-server class for test
  class MidiSmtpServerPortsAndConnectionsTest < MidiSmtpServerTest
  end

  # Runs tests in alphabetical order, instead of random order.
  i_suck_and_my_tests_are_order_dependent!

  # initialize before tests
  def setup
    # create service instance
    @smtpd = MidiSmtpServerPortsAndConnectionsTest.new(
      '5555',
      '127.0.0.1',
      1,
      max_connections: 2,
      do_dns_reverse_lookup: false
    )
    # start the daemon to run real life integration tests
    @smtpd.start
  end

  def teardown
    @smtpd.stop
  end

  ### TEST SUITE

  MSG_WELCOME = "220 127.0.0.1 says welcome!\r\n"
  MSG_ABORT = "421 Service too busy or not available, closing transmission channel\r\n"

  def test_010_tcp_1_connect
    channel1 = create_socket
    result1 = get_blocked_socket(channel1)
    assert_equal MSG_WELCOME, result1
    close_socket(channel1)
  end

  def test_020_tcp_2_simultan_connects
    channel1 = create_socket
    channel2 = create_socket
    result1 = get_blocked_socket(channel1)
    assert_equal MSG_WELCOME, result1
    assert_raises(IO::WaitReadable) { result2 = get_nonblocked_socket(channel2) }
    close_socket(channel1)
    result2 = get_blocked_socket(channel2)
    assert_equal MSG_WELCOME, result2
    close_socket(channel2)
  end

  def test_030_tcp_3_simultan_connects_and_1_abort
    channel1 = create_socket
    channel2 = create_socket
    channel3 = create_socket
    result1 = get_blocked_socket(channel1)
    assert_equal MSG_WELCOME, result1
    assert_raises(IO::WaitReadable) { result2 = get_nonblocked_socket(channel2) }
    close_socket(channel1)
    result2 = get_blocked_socket(channel2)
    assert_equal MSG_WELCOME, result2
    close_socket(channel2)
    result3 = get_blocked_socket(channel3)
    assert_equal MSG_ABORT, result3
    assert_raises(Errno::EPIPE) { 100.times { send_blocked_socket(channel3, "NOOP\r\n") } }
    assert_raises(Errno::ECONNRESET) { 100.times { get_nonblocked_socket(channel3, 1000) } }
    close_socket(channel3)
  end

  ### HELPERS

  def create_socket
    sleep 1
    TCPSocket.new('127.0.0.1', 5555)
  end

  def close_socket(channel)
    channel.close
  end

  def get_blocked_socket(channel)
    channel.gets
  end

  def get_nonblocked_socket(channel, count = 1, timeout = 0.25)
    sleep(timeout)
    channel.recv_nonblock(count)
  end

  def send_blocked_socket(channel, msg)
    channel.send(msg, 0)
  end

end
