require 'model'

require 'active_support'
require 'active_support/core_ext'

class PcapToolsHttpMessageRowMapper
  BROWSER_USER_AGENT_PATTERN = /mozilla/i
  BREAK_LINES_PATTERN = /.{0,100}/

  def initialize(participants)
    @participants_by_port = Hash[participants.select { |participant| participant[:port] }.map { |participant| [participant[:port].to_s, participant[:name]] }]
    @participants_by_user_agent = Hash[participants.map { |participant| [(participant[:user_agent] || participant[:name]), participant[:name]] }]
  end

  def map_from(event)
    if is_http?(event)
      add_component(event)

      source_name = source_name_from(event)
      destination_name = destination_name_from(event)
      body = event[:body]
      content_type = event[:content_type]

      if is_response?(event)
        HttpResponse.new(source_name, destination_name, event[:code], event[:set_cookie], event[:location], content_type, body)
      else
        HttpRequest.new(source_name, destination_name, event[:method], event[:path], body, event[:cookie], content_type)
      end
    elsif is_test_lifecycle?(event)
      testClass, testName = testDetails(event)
      if is_start?(event)
        StartTest.new(testClass, testName)
      else
        FinishTest.new(testClass, testName)
      end
    else
      DoNothing.new
    end
  end

  attr_reader :participants_by_port

  private

  TEST_NAME_REGEX = /\w+ (\w+)\.(\w+)/

  def is_test_lifecycle?(event)
    event[:broadcast].presence && event[:broadcast][TEST_NAME_REGEX]
  end

  def testDetails(event)

    event[:broadcast].match(TEST_NAME_REGEX).captures
  end

  def is_start?(event)
    event[:broadcast][/Starting/].presence
  end

  def is_http?(event)
    event[:request_or_response].presence
  end

  def is_response?(event)
    event[:request_or_response] == "response"
  end

  def destination_name_from(event)
    @participants_by_port[event[:pcap_dst_port]] || event[:pcap_dst_port]
  end

  def source_name_from(event)
    @participants_by_port[event[:pcap_src_port]] || event[:pcap_src_port]
  end

  def user_agent_from(event)
    raw_user_agent = event[:user_agent]
    (raw_user_agent.match BROWSER_USER_AGENT_PATTERN) ? 'User' : raw_user_agent
  end

  def add_component(event)
    source_port = event[:pcap_src_port]
    @participants_by_port[source_port] = @participants_by_user_agent[user_agent_from(event)] unless @participants_by_port.has_key? source_port
  end
end
