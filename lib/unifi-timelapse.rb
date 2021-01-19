require_relative "unifi-timelapse/config.rb"
require_relative "unifi-timelapse/arguments.rb"
require_relative "unifi-timelapse/command.rb"
require_relative "unifi-timelapse/cli.rb"


require "yaml"
require "time"
require "fileutils"


$debug = true

def debug(*args)
  args.each do |a|
    $stdout.puts " !!> #{a}" if $debug
  end
end

def info(*args)
  args.each do |a|
    $stdout.puts " >>> #{a}"
  end
end


module UTL

  def self.date_to_path(date)
    date.split("-").join("/")
  end
  
  def self.date_from_string(datestr)
    Date.parse(datestr)
  end

  def self.dates_from_string(datestr)
    ret = ["%F 00:00:00+0200", "%F 23:59:59+0200"]
    ret.map{|v|
      Date.parse(datestr).strftime(v)
    }
    
  end

  def self.run(cmdarr)
    puts cmdarr
    system cmdarr
  end
end

UTL::C = UTL::Config.new
