# frozen_string_literal: true

require 'mail'

# overloaded midi-smtp-server class for test
class MidiSmtpServerThreadSafetyStressTest < MidiSmtpServerTest

  def on_auth_event(ctx, authorization_id, authentication_id, authentication)
    # do we had already a miss
    if @ev_fail_counter.zero?
      # generate some load
      (rand(1..10) * 5).times do |i|
        100_000.downto(1) do |j|
          Math.sqrt(j) * i / 0.2
        end
      end
    end

    super(ctx, authorization_id, authentication_id, authentication)
  end

  def on_message_data_event(ctx)
    # test if ctx was (partial) overwritten by another thread
    @ev_fail_counter += 1 \
      if ctx[:envelope][:from] != "<#{ctx[:server][:authentication_id]}>" || \
         ctx[:envelope][:from] != ctx[:envelope][:to].first
  end

end

# Unit test to check commands without TCP
class ThreadSafetyStressTest < BaseIntegrationTest

  # initialize before tests
  def setup
    # create some message vars and sources
    super
    # create service instance
    @smtpd = MidiSmtpServerThreadSafetyStressTest.new(
      ports: '5555',
      hosts: '127.0.0.1',
      max_processings: 50,
      do_dns_reverse_lookup: false,
      auth_mode: :AUTH_OPTIONAL,
      tls_mode: :TLS_OPTIONAL,
      pipelining_extension: false,
      internationalization_extensions: true,
      logger_severity: Logger::ERROR
    )
    # start the daemon to run real life integration tests
    @smtpd.start
  end

  ### TEST SUITE

  def test_thread_safety_with_multiple_connections
    threads = []

    100.times do |i|
      email = "administrator_#{i}@local.local"
      threads << Thread.new do
        net_smtp_send_mail email, email, @doc_simple_mail, authentication_id: email, password: 'password', tls_enabled: false
      end
    end

    threads.each(&:join)

    while threads.any?(&:alive?) do end

    assert_predicate @smtpd.ev_fail_counter, :zero?
  end

end
