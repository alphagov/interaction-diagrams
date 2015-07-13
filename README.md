Microservice interaction diagrams
---------------------------------

Which microservices talk to each other?

This tool attempts to answer that question by using wireshark to capture the traffic that passes between microservices during end to end runs, and then generating a [sequence diagrams](https://bramp.github.io/js-sequence-diagrams/) per test.

Prerequisites
--------------
You need to have wireshark's command-line application (tshark) in your path. Install the [development release](https://www.wireshark.org/download.html#development-rel) of wireshark, or ensure the version that is already installed [has lua enabled](https://wiki.wireshark.org/Lua).

Wireshark must be on the path, and able to listen to your local loopback interface (lo0). You may need to run the interaction diagram script with sudo to enable it to do this.

You should ensure that you have [bundler](http://bundler.io/) set up, and ensure you have all required gem dependencies after a pull. From the root directory, run:

    bundle install

End to end tests
----------------

Given the `--tests` flag, the tool will generate a diagram per test.
It looks for two UDP packets in the stream to decide when a test begins and ends, where the `data` section contains like the following string:

```
  Starting TestClass.testName
  Stopping TestClass.testName
```

All http packets between these two markers are considered part of the `TestClass.testName` test.

*Everything else is discarded.*

Usage
-----
Create a YAML configuration file named "participants.yml" in the root directory.
This is a list of the HTTP clients and servers you wish to capture, in the order you wish them to appear in the diagram. The format is as follows:

```yaml
    - name: <name of first participant>
      user_agent: <user agent header value used by participant when it makes http requests> [optional, defaults to <name>]
      port: <port participant listens on>
    - name: User
    - name: <name of second participant>
      port: <port participant listens on>
```
User agents are required for everything that acts as a client to another microservice.

A special participant named "User" can be placed anywhere in the configuration file to indicate where traffic from the browser should appear in the diagram.

For usage information and available options, run:

    ./generate_html.rb --help

Filtering
---------

The tool filters out all request/responses that are just simple static asset lookups (eg css or js files, images etc).
