# frozen_string_literal: true

require 'net/smtp'
require 'mail'

# for testing we rely on net/smtp >= 0.3.1
# this will monkey patch Mikel/mail gem with new ssl_context_params from net/smtp
# checkout PR at https://github.com/ruby/net-smtp/pull/22
# changed in net/stmp since release v0.3.1
# need to assign ssl_context_params BEFORE smtp.start

module Mail

  class SMTP

    def build_smtp_session
      Net::SMTP.new(settings[:address], settings[:port]).tap do |smtp|
        if settings[:enable_starttls]
          smtp.enable_starttls
          smtp.ssl_context_params = settings[:ssl_context_params]
        else
          smtp.ssl_context_params = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
        end
      end
    end

  end

end
