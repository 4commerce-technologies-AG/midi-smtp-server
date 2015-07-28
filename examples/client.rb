msgstr = <<END_OF_MESSAGE
From: Your Name <your@mail.address>
To: Destination Address <someone@example.com>
Subject: test message
Date: Sat, 23 Jun 2001 16:26:43 +0900
Message-Id: <unique.message.id.string@example.com>

This is a test message.
END_OF_MESSAGE

require 'net/smtp'

smtp = Net::SMTP.start('127.0.0.1', 2525, 'mail.address', 'testuser', 'testpass', :plain)
# smtp = Net::SMTP.start('127.0.0.1', 2525, 'mail.address')
smtp.send_message msgstr, 'your@mail.address', 'someone@example.com'
smtp.finish
