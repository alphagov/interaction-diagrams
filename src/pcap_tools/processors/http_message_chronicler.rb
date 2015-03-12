class HttpMessageChronicler
  def initialize
    @messages_in_time = {}
  end

  def process_stream stream
    stream.each do |index, req, resp|
      @messages_in_time[req.time.to_f] = req

      resp['pcap-src-port'] = req['pcap-dst-port']
      resp['pcap-dst-port'] = req['pcap-src-port']

      @messages_in_time[resp.time.to_f] = resp
    end

    stream
  end

  def chronological_messages
    @messages_in_time.sort.map { |time, event| event }
  end

  def finalize
  end

end