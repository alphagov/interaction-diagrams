require_relative 'processors/http_message_chronicler'
require_relative 'processors/http_request_decompressor'

class PcapToolsHttpMessageParser
  def parse_file(pcap_file_path)
    processor = PcapTools::TcpProcessor.new
    processor.add_stream_processor PcapTools::TcpStreamRebuilder.new
    processor.add_stream_processor PcapTools::HttpExtractor.new
    processor.add_stream_processor HttpRequestDecompressor.new
    http_events_capture_processor = HttpMessageChronicler.new
    processor.add_stream_processor http_events_capture_processor

    PcapTools::Loader::load_file(pcap_file_path, {:accepted_protocols => ['ipv6']}) do |index, packet|
      processor.inject index, packet
    end

    http_events_capture_processor.chronological_messages
  end
end