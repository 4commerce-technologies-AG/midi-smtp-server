## Attacks on email communication

You should take care of your project and the communication which it will handle. At least there are a number of attack possibilities even against email communication. It is important to know some of the attacks to write safe codes. Here are just a few starting links about that:

1. [SMTP Injection via recipient (and sender) email addresses](https://www.mbsd.jp/Whitepaper/smtpi.pdf)
1. [Measuring E-Mail Header Injections on the World Wide Web](https://www.cs.ucsb.edu/~vigna/publications/2018_SAC_MailHeaderInjection.pdf)
1. [DDoS Protections for SMTP Servers](https://pdfs.semanticscholar.org/e942/d110f9686a438fccbac1d97db48c24ab84a7.pdf)
1. [Use timeouts to prevent SMTP DoS attacks](https://security.stackexchange.com/a/180267)
1. [Check HELO/EHLO arguments](https://serverfault.com/a/667555)

Be aware that with enabled option of [PIPELINING](https://tools.ietf.org/html/rfc2920) you can't figure out sender or recipient address injection by the SMTP server. From point of security PIPELINING should be disabled as it is per default since version 2.3.0 on this component.

```rb
# PIPELINING ist not allowed (false) per _Default_
pipelining_extension: DEFAULT_PIPELINING_EXTENSION
```

<br>
