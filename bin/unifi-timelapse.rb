#!/usr/bin/env ruby

require File.join(File.dirname(File.expand_path(__FILE__)), "..", "lib/unifi-timelapse")

require "pp"


cli = UTL::Cli.options do |opts, c|
  opts.on("", "--day %s", "day") do |s|
    c[:day] = s
  end

  # opts.on("-O", "--dest %s", "destination root dir") do |s|
  #   c[:dest] = s
  # end

  opts.on("-D", "--process-day", "reads source files from NVR and makes sped up video for <day> in <workdir>") do
    unless c.opts[:day]
      c.opts[:day] = (Time.now - 3600*24).strftime("%Y-%m-%d")
      debug("--day not set, using yesterday: --day #{c.opts[:day]}")
    end
    c.process_day
  end

end


cli.parse


