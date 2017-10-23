#! /usr/bin/env ruby

$LOAD_PATH << "./src"

require 'optparse'
require 'fileutils'
require 'yaml'
require 'application'

configuration = {
    :participants => YAML.load_file('participants.yml').map { |participant| Hash[participant.map { |k,v| [k.to_sym,v] }] },
    :participants_to_monitor => [],
    :output_directory => './out',
    :display_request_bodies => true,
    :display_response_bodies => true,
    :display_cookies => true,
    :skip_capture => false,
    :verbose => false
}

OptionParser.new do |o|
  o.banner = 'Usage: ./generate_html.rb [options]'

  o.on('-d', 'Run in development mode (overwrites dev.html)') do |development_mode|
    configuration[:development_mode] = development_mode
  end

  o.on('-o OUTPUT_DIR', "Output directory (defaults to '#{configuration[:output_directory]}')") do |output_directory|
    configuration[:output_directory] = output_directory
  end

  o.on('--hide_request_body', "Don't display request bodies") do
    configuration[:display_request_bodies] = false
  end

  o.on('--hide_response_body', "Don't display response bodies") do
    configuration[:display_response_bodies] = false
  end

  o.on('--hide_cookies', "Don't display cookie information") do
    configuration[:display_cookies] = false
  end

  participants = configuration[:participants].map { |participant| participant[:name] }
  o.on('-p PARTICIPANT', participants, 'Participant to capture (defaults to all)') do |participant|
    configuration[:participants_to_monitor] << participant
  end

  o.on('--skip_capture', 'Do not capture network traffic, re-use the results of a previous capture instead') do
    configuration[:skip_capture] = true
  end

  o.on('-v', 'verbose') do
    configuration[:verbose] = true
  end

  configuration[:test_events] = true
  o.on('-n', 'do not expect "Starting and Finishing" events') do
    configuration[:test_events] = false
  end

  o.on('-f', 'only display participants defined in participants.yml') do
    configuration[:strict_participants] = true
  end

  o.separator ''
  o.separator "#{o.summary_indent}Available Participants"
  o.separator "#{o.summary_indent}----------------------"
  configuration[:participants].each { |participant| o.separator("#{o.summary_indent}#{participant[:name]}") }
  o.separator ''

end::parse!

puts "Monitoring #{(configuration[:participants_to_monitor].empty? ? 'all participants' : configuration[:participants_to_monitor].join(', '))}" if configuration[:verbose]

Application.generate_diagrams(configuration)
