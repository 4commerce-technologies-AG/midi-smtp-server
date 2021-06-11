# frozen_string_literal: true

require 'net/smtp'
require 'mail'

# this will monkey patch Mikel/mail gem with new ssl_context_params from net/smtp
# checkout PR at https://github.com/ruby/net-smtp/pull/22

module Mail

  class SMTP

    def start_smtp_session(&block)
      if Net::SMTP.const_defined?('VERSION') && (Net::SMTP::VERSION >= '0.2.1')
        build_smtp_session.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication], ssl_context_params: settings[:ssl_context_params], &block)
      else
        build_smtp_session.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication], &block)
      end
    end

  end

end
