### RFC(2)822 - CR LF modes

There is a difference between the conformity of RFC 2822 and best practise.

In [RFC 2822](https://www.ietf.org/rfc/rfc2822.txt) it says that strictly each line has to end up by CR (code 13) followed by LF (code 10). And in addition that the chars CR (code 13) and LF (code 10) should not be used particulary. If looking on Qmails implementation, they will revoke any traffic which is not conform to the above per default.

In real world, it is established, that also a line ending with single LF (code 10) is good practise. So if trying other mailservers like Exim or Exchange or Gmail, you may enter your message either ended by CRLF or single LF.

Also the DATA ending sequence of CRLF.CRLF (CR LF DOT CR LF) may be send as LF.LF (LF DOT LF).

Since version 2.3.0 the component allows to decide by option `crlf_mode` how to handle the line termination codes. Be aware that `CRLF_ENSURE` is enabled by default.

```rb
# Allow CRLF and LF but always make sure that CRLF is added to message data. _Default_
crlf_mode: CRLF_ENSURE

# Allow CRLF and LF and do not change the incoming data.
crlf_mode: CRLF_LEAVE

# Only allow CRLF otherwise raise an exception
crlf_mode: CRLF_STRICT
```

<br>

<h3>Modes</h3>

To understand the modes in details:

#### CRLF_ENSURE

1. Read input buffer and search for LF (code 10)
2. Use bytes from buffer start to LF as TEXTLINE
3. Heal by deleting any occurence of char CR (code 13) and char LF (code 10) from TEXTLINE
4. Append cleaned TEXTLINE and RFC conform pair of CRLF to message data buffer

* As result you will have a clean RFC 2822 conform message input data
* In best case the data is 100% equal to the original input because that already was CRLF conform
* Other input data maybe have changed for the linebreaks but the message is conform yet

#### CRLF_LEAVE

1. Read input buffer and search for LF (code 10)
2. Use bytes from buffer start to LF as TEXTLINE
3. Append TEXTLINE as is to message data buffer

* As result you may have a non clean RFC 2822 conform message input data
* Other libraries like `Mail` may have parsing errors

#### CRLF_STRICT

1. Read input buffer and search for CRLF (code 13 code 10)
2. Use bytes from buffer start to CRLF as TEXTLINE
3. Raise exception if TEXTLINE contains any single CR or LF
3. Append TEXTLINE as is to message data buffer

* As result you will have a clean RFC 2822 conform message input data
* The data is 100% equal to the original input because that already was CRLF conform
* You maybe drop mails while in real world not all senders are working RFC conform

<br>
