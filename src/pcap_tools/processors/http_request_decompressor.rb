#pcap_tools gem does not decompress request bodies
class HttpRequestDecompressor
  CONTENT_ENCODING_HEADER = 'Content-Encoding'
  GZIP_CONTENT_ENCODING = 'gzip'

  def process_stream stream
    stream.each do |index, req, resp|
      begin
        req.body = Zlib::GzipReader.new(StringIO.new(req.body)).read if req[CONTENT_ENCODING_HEADER] == GZIP_CONTENT_ENCODING
      rescue Zlib::GzipFile::Error
        warn "Response body is not in gzip: [#{req.body}]"
      end
    end
    stream
  end

  def finalize
  end
end