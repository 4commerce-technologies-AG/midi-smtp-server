# frozen_string_literal: true

require 'net/smtp'
require 'mail'

# this will monkey patch Mikel/mail gem with new ssl_context_params from net/smtp
# checkout PR at https://github.com/ruby/net-smtp/pull/22

module Mail
  class SMTP
    def start_smtp_session(&block)
      build_smtp_session.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication], ssl_context_params: settings[:ssl_context_params], &block)
    end
  end
end
