## Utilization of connections and processings

The options `max_processings` and `max_connections` allows to define the utilization of the running service. The value of `max_processings` will allow to queue processings while active processings have reached the maximum value. The additional (optional) value of `max_connections` will block any additional concurrent TCP connection and respond with SMTP error code 421 on more connections.

E.g.:

```rb
  server = MySmtpd.new(ports: '2525', hosts: '127.0.0.1', max_processings: 4, max_connections: 100)
```

In this example the service will allow 100 concurrent TCP connections but just process 4 of them simultaneously until all connections have been handled. If there are more than 100 concurrent TCP connections, those will be closed by error `421 Service too busy or not available`. That error code will _normally_ ensure, that the sender would try again after a while.

This allows to calculate the utilization of your service by limiting the connections and processings.

<br>

### Calculate utilization

It depends on the system resources (RAM, CPU) how many threads and connections your service may handle simultaneously but it should reflect also how many messages it has to proceed per time interval.

For processing 1.000.000 mails per 24 hours, it may divided by seconds per day (24 * 60 * 60 = 86.400). This results in 11.5 mails per second. If the average processing time per mail is 15 seconds (long runner), then the service might have an overlap of 15 times 11.5 connections simultaneously. If that is expected, then `max_processings` of 172 should be fine.

If you need 1.000.000 mail per hour than probably 416 simultaneously processed threads should be fine.

The number of `max_connections` should always be equal or higher than `max_processings`. In the above examples it should be fine to use 512 or 1024 if your system does fit with its resources. If an unlimited number of concurrent TCP connections should be allowed, then set the value for `max_connections` to `nil` (which is also the default when not specified).

In addition it is possible to adjust the idle sleep time when no input data is available while in loop for commands and data. Time in fraction of seconds is available thru `io_waitreadable_sleep` option. The default value is `0.1` seconds but can be adjusted to e.g. `0.02` for faster processings.

<br>

## Pre-forking

When running ruby applications on multi-core CPUs, ruby by default will run all its processes and threads per one (1) CORE only, handled by Ruby GIL and executed one thread action after next thread action. The `pre_fork` option enables more cores by forking processes and let each fork handle a number of threads per each core (forked process) to handle simultaneously (parallel) sessions. This pattern is often used to let the operating system load balance connections to several processes without the need of proxies like Apache or HAProxy.

Ruby has a global interpreter lock so if a server has 10 cores then to fully utilize all the cores will require spawning more than one process to listen for connections because threads are not mapped to a process. Here is a good article explaining some of the implementation details of Ruby's threads: [Ruby threads worth it?](https://medium.com/gympass/ruby-threads-worth-it-46167522142b)

!!! Note

    1. GIL (Global Interpreter Lock) or GVL (Global VM Lock), act as a lock around Ruby code
    2. It allows concurrent execution of Ruby code but prevents parallel execution
    3. Each instance of MRI has a GIL
    4. If some of these MRI processes spawn multiple threads, GIL comes in action, preventing parallel execution.

<br>

!!! Warning

    This feature is currently in **beta** while scheduling processes by operating systems are not always balanced. The options `max_connections` and
    `max_processings` are currently limiting only each forked process and not the overall service!

<br>
