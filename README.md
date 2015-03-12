Prerequisites
-------------
You need to have wireshark's command-line application (tshark) in your path. To install it on Mac, run:

    brew install wireshark

Wireshark must be able to listen to your local loopback interface (lo0). You may need to run the interaction diagram script with sudo to enable this.

You should also ensure you have all required gem dependencies after a pull. From the root directory, run:

    bundle install

Usage
-----
You need to include a YAML configuration file named "participants.yml" in the root directory. List the HTTP clients and servers you wish to capture, in the order you wish them to appear. The format is as follows:

    - name: <name of first participant>
      user_agent: <user agent header value used by participant when it makes http requests> [optional]
      port: <port participant listens on>
    - name: User
    - name: <name of second participant>
      port: <port participant listens on>

A special participant named "User" can be placed anywhere in the configuration file to indicate where traffic from the browser should appear in the diagram.

For usage information, run:

    ./generate_html.rb --help
