#! /usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'yaml'
require_relative './src/application'

configuration = {
    :participants => YAML.load_file('participants.yml').map { |participant| Hash[participant.map { |k,v| [k.to_sym,v] }] },
    :participants_to_monitor => [],
    :output_directory => './out',
    :display_request_bodies => true,
    :display_response_bodies => true
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

  participants = configuration[:participants].map { |participant| participant[:name] }
  o.on('-p PARTICIPANT', participants, 'Participant to capture (defaults to all)') do |participant|
    configuration[:participants_to_monitor] << participant
  end

  o.separator ''
  o.separator "#{o.summary_indent}Available Participants"
  o.separator "#{o.summary_indent}----------------------"
  configuration[:participants].each { |participant| o.separator("#{o.summary_indent}#{participant[:name]}") }
  o.separator ''

end::parse!

puts "Monitoring #{(configuration[:participants_to_monitor].empty? ? 'all participants' : configuration[:participants_to_monitor].join(', '))}"

FileUtils.mkdir_p configuration[:output_directory]
file_name = File.join(configuration[:output_directory], "#{configuration[:development_mode] ? 'dev' : Time.now.to_i.to_s}.html")

Application.generate_html_file(file_name, configuration)