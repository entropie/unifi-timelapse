#!/usr/bin/env ruby

require File.join(File.dirname(File.expand_path(__FILE__)), "..", "lib/unifi-timelapse")

require "pp"

run = {}

cli = UTL::Cli.options do |opts, c|
  opts.banner = "#{__FILE__} [OPTION...]"


  opts.on("-d", "--day [TIME]", "yyyy-mm-dd set date to process") do |s|
    c[:day] = s
  end

  opts.on("-H", "--hostname HOSTNAME", "hostname/ip of your nvr") do |s|
    c[:address] = s
  end

  opts.on("-C", "--camera CAMERAID", "id of camera (list ids with --list-cameras)") do |s|
    c[:camera] = s
  end

  opts.on("-u", "--ssh-user USER", "sshuser") do |s|
    c[:sshuser] = s
  end

  opts.on("--ssh-opts OPTS", "opt parsed through ssh") do |s|
    c[:sshopts] = s
  end

  opts.on("-W", "--work-dir LOCALDIRECTORY", "local working directory, where files are stored") do |s|
    c[:workdir] = s
  end

  opts.on("--speed-up FLOAT", "factor for ffmpeg for setpts=0.00027777777") do |s|
    c[:speedup] = s
  end

  opts.on("-c", "--list-cameras", "list potential camera IDs") do |s|
    run[:listcameras] = lambda { puts c.list_cameras }
  end

  opts.on("-D", "--process-day", "reads source files from NVR and makes sped up video for <day> in <workdir>") do
    unless c.opts[:day]
      c.opts[:day] = (Time.now - 3600*24).strftime("%Y-%m-%d")
      debug("--day not set, using yesterday: --day #{c.opts[:day]}")
    end
    run[:processday] = lambda { c.process_day}
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    puts "\nCurrent Config '#{UTL::C.config_file}:'"
    c.arguments.arguments.each do |v,k|
      puts "  %15s: '%s'" % [v,k]
    end
    exit
  end
end

cli.parse

run.each {|r,v|
  v.call
}
