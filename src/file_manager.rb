
class FileManager

  def initialize(options)
    @session_name = options[:development_mode] ? 'dev' : Time.now.to_i.to_s
    @index_file = File.join(options[:output_directory], session_name_file)
    @current_file_symlink = File.join(options[:output_directory], "current.html")
    @session_dir = File.join(options[:output_directory], session_name)
    @index = 0
    FileUtils.mkdir_p @session_dir
  end

  attr_reader :index_file, :session_name, :current_file_symlink

  def session_name_file
    "#{session_name}.html"
  end

  def new_output_file(testname, ext)
    File.join(@session_dir, (testname.presence || next_test_name) + ext)
  end

  def next_test_name
    @index += 1
    "test #{@index}"
  end

  def clear_pcap_output_file
    FileUtils.mkdir_p File.dirname pcap_output_file
    FileUtils.rm pcap_output_file if File.exists? pcap_output_file
  end

  def pcap_output_file
    "./tmp/output.pcap"
  end
end
